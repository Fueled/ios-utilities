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

#if canImport(Combine)
import Combine
#if canImport(FueledUtilsReactiveCommon)
import FueledUtilsCore
import FueledUtilsReactiveCommon
#endif

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
	public func ignoreError() -> AnyPublisher<Output, Never> {
		self.catch { _ in Empty() }.eraseToAnyPublisher()
	}

	public func promoteOptional() -> AnyPublisher<Output?, Failure> {
		self.map { Optional.some($0) }.eraseToAnyPublisher()
	}

	public func sink() -> AnyCancellable {
		self.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
	}

	public func then(receiveResult: @escaping ((Result<Self.Output, Self.Failure>) -> Void)) -> AnyCancellable {
		self.sink(
			receiveCompletion: { completion in
				if case .failure(let error) = completion {
					receiveResult(.failure(error))
				}
			},
			receiveValue: { value in
				receiveResult(.success(value))
			}
		)
	}

	public func sinkForLifetimeOf<Object: CombineExtensionsProvider>(_ object: Object) {
		self.sink()
			.store(in: &object.combineExtensions.cancellables)
	}

	public func sinkForLifetimeOf<Object: CombineExtensionsProvider>(_ object: Object, receiveValue: @escaping ((Self.Output) -> Void)) where Failure == Never {
		self.sink(receiveValue: receiveValue)
			.store(in: &object.combineExtensions.cancellables)
	}

	public func sinkForLifetimeOf<Object: CombineExtensionsProvider>(_ object: Object, receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void), receiveValue: @escaping ((Self.Output) -> Void)) {
		self.sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
			.store(in: &object.combineExtensions.cancellables)
	}

	public func thenForLifetimeOf<Object: CombineExtensionsProvider>(_ object: Object, receiveResult: @escaping ((Result<Self.Output, Self.Failure>) -> Void)) {
		self.then(receiveResult: receiveResult)
			.store(in: &object.combineExtensions.cancellables)
	}
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
	public func performDuringLifetimeOf<Object: CombineExtensionsProvider & AnyObject>(_ object: Object, action: @escaping (Object, Output) -> Void) {
		self
			.ignoreError()
			.sinkForLifetimeOf(object) { [weak object] value in
				guard let object = object else {
					return
				}
				action(object, value)
			}
	}

	public func performDuringLifetimeOf<Object: CombineExtensionsProvider & AnyObject>(_ object: Object, action: @escaping (Object) -> (Output) -> Void) {
		self.performDuringLifetimeOf(object) { object, output in
				action(object)(output)
			}
	}
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Failure == Never {
	public func assign<Object: AnyObject>(to keyPath: ReferenceWritableKeyPath<Object, Output>, withoutRetaining object: Object) -> AnyCancellable {
		self.sink { [weak object] in
			object?[keyPath: keyPath] = $0
		}
	}

	public func assign<Object: CombineExtensionsProvider & AnyObject>(to keyPath: ReferenceWritableKeyPath<Object, Output>, forLifetimeOf object: Object) -> Void {
		self.sink { [weak object] in
			object?[keyPath: keyPath] = $0
		}
			.store(in: &object.combineExtensions.cancellables)
	}
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Output: OptionalProtocol {
	public func ignoreNil() -> AnyPublisher<Output.Wrapped, Failure> {
		self.flatMap { ($0.wrapped.map { Just($0).eraseToAnyPublisher() } ?? Empty().eraseToAnyPublisher()).setFailureType(to: Failure.self) }.eraseToAnyPublisher()
	}
}

#endif
