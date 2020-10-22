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

///
/// A type-erased Action that allows to store any `ActionProtocol`
/// (loosing any type information at the same time)
///
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class AnyAction: ActionProtocol {
	public typealias Input = Any
	public typealias Output = Any
	public typealias Failure = Error
	public typealias IsExecutingPublisher = AnyPublisher<Bool, Never>
	public typealias IsEnabledPublisher = AnyPublisher<Bool, Never>
	public typealias ValuesPublisher = AnyPublisher<Any, Never>
	public typealias ErrorsPublisher = AnyPublisher<Error, Never>
	public typealias ApplyPublisher = AnyPublisher<Any, Error>
	public typealias ApplyFailure = Error

	private let applyClosure: (Any) -> AnyPublisher<Any, Error>
	private var cancellables = Set<AnyCancellable>()

	public init<Action: ActionProtocol>(_ action: Action) {
		self.isEnabled = action.isEnabled
		self.isExecuting = action.isExecuting
		self.applyClosure = { action.apply($0 as! Action.Input).map { $0 }.mapError { $0 }.eraseToAnyPublisher() }
		self.values = action.values.map { $0 }.eraseToAnyPublisher()
		self.errors = action.errors.map { $0 }.eraseToAnyPublisher()
		action.isEnabledPublisher.assign(to: \.isEnabled, withoutRetaining: self)
			.store(in: &self.cancellables)
		action.isExecutingPublisher.assign(to: \.isExecuting, withoutRetaining: self)
			.store(in: &self.cancellables)
	}

	@Published public private(set) var isEnabled: Bool
	@Published public private(set) var isExecuting: Bool

	public var isEnabledPublisher: AnyPublisher<Bool, Never> {
		self.$isEnabled.eraseToAnyPublisher()
	}

	public var isExecutingPublisher: AnyPublisher<Bool, Never> {
		self.$isExecuting.eraseToAnyPublisher()
	}

	public let values: AnyPublisher<Any, Never>
	public let errors: AnyPublisher<Error, Never>

	public func apply(_ input: Any) -> AnyPublisher<Any, Error> {
		self.applyClosure(input)
	}
}
