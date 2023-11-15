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
import FueledUtilsCore

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class Action<Input, Output, Failure: Swift.Error> {
	@Published public private(set) var isExecuting: Bool = false
	@Published public private(set) var isEnabled: Bool = false

	public let values: AnyPublisher<Output, Never>
	public let errors: AnyPublisher<Failure, Never>

	fileprivate let execute: (Action, Input) -> AnyPublisher<Output, ActionError<Failure>>

	fileprivate var cancellables = Set<AnyCancellable>([])

	public convenience init<ExecutePublisher: Combine.Publisher>(
		execute: @escaping (Input) -> ExecutePublisher
	) where ExecutePublisher.Output == Output, ExecutePublisher.Failure == Failure {
		self.init(enabledIf: Just(true), execute: execute)
	}

	public init<EnabledIfPublisher: Combine.Publisher, ExecutePublisher: Combine.Publisher>(
		enabledIf isEnabled: EnabledIfPublisher,
		execute: @escaping (Input) -> ExecutePublisher
	) where
		EnabledIfPublisher.Output == Bool,
		EnabledIfPublisher.Failure == Never,
		ExecutePublisher.Output == Output,
		ExecutePublisher.Failure == Failure
	{
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
					receiveCompletion: { completion in
						switch completion {
						case .finished:
							break
						case .failure(let error):
							errors.send(error)
						}
					},
					receiveTermination: { [weak action] in
						isExecutingLock.lock()
						action?.isExecuting = false
						isExecutingLock.unlock()
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

	fileprivate init<EnabledIfPublisher: Combine.Publisher>(
		enabledIf isEnabled: EnabledIfPublisher,
		values: AnyPublisher<Output, Never>,
		errors: AnyPublisher<Failure, Never>,
		execute: @escaping (Action, Input) -> AnyPublisher<Output, ActionError<Failure>>
	) where
		EnabledIfPublisher.Output == Bool,
		EnabledIfPublisher.Failure == Never
	{
		self.values = values
		self.errors = errors
		self.execute = execute

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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Action {
	public static func constant(_ value: Output) -> Action<Input, Output, Failure> {
		self.constant(inputType: Input.self, value: value)
	}

	public static func constant(inputType: Input.Type, value: Output) -> Action<Input, Output, Failure> {
		Action { _ in Just(value).setFailureType(to: Failure.self) }
	}

	// Please note that the actions created with the `mapXxx` family are interweaved together - starting one
	// will update the other, and vice versa.
	// For example, on use case is to type-erase an Action.
	@available(*, deprecated, message: "Use `AnyAction` instead")
	public func mapInput<NewInput>(_ mapper: @escaping (NewInput) -> Input) -> Action<NewInput, Output, Failure> {
		self.mapAll(
			mapInput: mapper,
			map: { $0 },
			mapError: { $0 }
		)
	}

	@available(*, deprecated, message: "Use `AnyAction` instead")
	public func map<NewOutput>(_ mapper: @escaping (Output) -> NewOutput) -> Action<Input, NewOutput, Failure> {
		self.mapAll(
			mapInput: { $0 },
			map: mapper,
			mapError: { $0 }
		)
	}

	@available(*, deprecated, message: "Use `AnyAction` instead")
	public func mapError<NewFailure: Swift.Error>(_ mapper: @escaping (Failure) -> NewFailure) -> Action<Input, Output, NewFailure> {
		self.mapAll(
			mapInput: { $0 },
			map: { $0 },
			mapError: mapper
		)
	}

	@available(*, deprecated, message: "Use `AnyAction` instead")
	public func mapAll<NewInput, NewOutput, NewFailure: Swift.Error>(
		mapInput: @escaping (NewInput) -> (Input),
		map: @escaping (Output) -> (NewOutput),
		mapError: @escaping (Failure) -> (NewFailure)
	) -> Action<NewInput, NewOutput, NewFailure> {
		let action = Action<NewInput, NewOutput, NewFailure>(
			enabledIf: self.$isEnabled,
			values: self.values.map(map).eraseToAnyPublisher(),
			errors: self.errors.map(mapError).eraseToAnyPublisher()
		) { (action, input) -> AnyPublisher<NewOutput, ActionError<NewFailure>> in
			return self.execute(self, mapInput(input))
				.map(map)
				.mapError { $0.map { mapError($0) } }
				.eraseToAnyPublisher()
		}

		self.$isExecuting
			.assign(to: \.isExecuting, withoutRetaining: action)
			.store(in: &action.cancellables)

		return action
	}
}
