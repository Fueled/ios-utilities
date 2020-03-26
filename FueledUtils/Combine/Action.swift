// Copyright © 2020, Fueled Digital Media, LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Combine

public protocol ActionErrorProtocol {
	associatedtype InnerError: Swift.Error

	var innerError: InnerError? { get }
}

public enum ActionError<Error: Swift.Error>: Swift.Error {
	case disabled
	case failure(Error)
}

extension ActionError: ActionErrorProtocol {
	public var innerError: Error? {
		if case .failure(let error) = self {
			return error
		}
		return nil
	}
}

public final class Action<Input, Output, Failure: Swift.Error> {
	@Published public private(set) var isExecuting: Bool = false
	@Published public private(set) var isEnabled: Bool = false

	public let values: AnyPublisher<Output, Never>
	public let errors: AnyPublisher<Failure, Never>

	private let execute: (Action, Input) -> AnyPublisher<Output, ActionError<Failure>>

	private var cancellables = Set<AnyCancellable>([])

	public convenience init<ExecutePublisher: Combine.Publisher>(
		execute: @escaping (Input) -> ExecutePublisher
	) where ExecutePublisher.Output == Output, ExecutePublisher.Failure == Failure {
		self.init(enabledIf: Just(true), execute: execute)
	}

	public init<EnabledIfPublisher: Combine.Publisher, ExecutePublisher: Combine.Publisher>(
		enabledIf isEnabled: EnabledIfPublisher,
		execute: @escaping (Input) -> ExecutePublisher
	) where EnabledIfPublisher.Output == Bool,
		EnabledIfPublisher.Failure == Never,
		ExecutePublisher.Output == Output,
		ExecutePublisher.Failure == Failure {
		let values = PassthroughSubject<Output, Never>()
		let errors = PassthroughSubject<Failure, Never>()

		self.values = values.eraseToAnyPublisher()
		self.errors = errors.eraseToAnyPublisher()

		let isExecutingLock = Lock()
		self.execute = { action, input -> AnyPublisher<Output, ActionError<Failure>> in
			isExecutingLock.lock()

			if !action.isEnabled || action.isExecuting {
				isExecutingLock.unlock()
				return Fail(error: .disabled)
					.eraseToAnyPublisher()
			}

			action.isExecuting = true
			isExecutingLock.unlock()
			return execute(input)
				.handleEvents(
					receiveOutput: { value in
						values.send(value)
					},
					receiveCompletion: { [weak action] completion in
						switch completion {
						case .finished:
							isExecutingLock.lock()
							action?.isExecuting = false
							isExecutingLock.unlock()
						case .failure(let error):
							errors.send(error)
						}
					}
				)
				.mapError { .failure($0) }
				.eraseToAnyPublisher()
		}

		Publishers.CombineLatest(
			isEnabled,
			self.$isExecuting
		)
			.map { $0 && !$1 }
			.assign(to: \.isEnabled, withoutRetaining: self)
			.store(in: &self.cancellables)
	}

	public func apply(_ input: Input) -> AnyPublisher<Output, ActionError<Failure>> {
		self.execute(self, input)
	}
}

extension Action where Input == Void {
	public func apply() -> AnyPublisher<Output, ActionError<Failure>> {
		self.apply(())
	}
}

extension Publisher where Failure: ActionErrorProtocol {
	public func unwrappingActionError() -> AnyPublisher<Output, Failure.InnerError> {
		self.catch { actionError -> AnyPublisher<Output, Failure.InnerError> in
			if let innerError = actionError.innerError {
				return Fail(error: innerError).eraseToAnyPublisher()
			}
			return Empty(completeImmediately: false).eraseToAnyPublisher()
		}
		.eraseToAnyPublisher()
	}
}
