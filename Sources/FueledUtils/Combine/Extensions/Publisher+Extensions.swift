// Copyright © 2024 Fueled Digital Media, LLC
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

// MARK: - Helpers Functions
public extension Publisher {
	///
	/// Ignores all errors received from this publisher.
	/// This function will catch any error from an upstream publisher and replace it with an `Empty` publisher.
	///
	func ignoreErrors() -> AnyPublisher<Output, Never> {
		self.catch { _ in
			Empty()
		}
		.eraseToAnyPublisher()
	}

	///
	/// Transforms the output of the publisher into an optional value.
	/// This function maps each emitted value to an `Optional`, effectively wrapping the output in an optional.
	/// If the original publisher emits a value, it will be wrapped in `Optional.some(value)`.
	///
	func promoteOptional() -> AnyPublisher<Output?, Failure> {
		map { value in
			Optional.some(value)
		}
		.eraseToAnyPublisher()
	}
}

// MARK: - Sink
public extension Publisher {
	///
	/// Creates a subscriber that receives values from the publisher,
	/// but does not take any action on the emitted values or completion events.
	/// The `receiveCompletion` closure is provided but does not perform any operations
	/// when the publisher completes, and the `receiveValue` closure ignores
	/// the emitted values entirely.
	///
	/// Returns an `AnyCancellable` that can be used to cancel the subscription.
	///
	func sink() -> AnyCancellable {
		sink(
			receiveCompletion: { _ in },
			receiveValue: { _ in }
		)
	}

	///
	/// Subscribes to the publisher and stores the cancellable in the specified object's cancellables collection.
	/// This function sets up a subscription that lasts for the lifetime of the provided object.
	/// The cancellable is stored in `object.combineExtensions.cancellables`, allowing the subscription
	/// to be automatically cancelled when the object is deallocated.
	///
	/// - Parameter object: An instance conforming to `CombineExtensionsProvider` that provides a storage
	///   for cancellable subscriptions.
	///
	func sinkForLifetimeOf<Object: CombineExtensionsProvider>(_ object: Object) {
		sink()
			.store(in: &object.combineExtensions.cancellables)
	}

	///
	/// Subscribes to the publisher and forwards emitted values to the specified closure while managing the subscription's lifetime.
	/// This function sets up a subscription that calls the provided `receiveValue` closure whenever the publisher emits a value.
	/// The cancellable is stored in `object.combineExtensions.cancellables`, ensuring that the subscription
	/// is automatically cancelled when the provided object is deallocated.
	///
	/// - Parameter object: An instance conforming to `CombineExtensionsProvider` that provides a storage
	///   for cancellable subscriptions.
	/// - Parameter receiveValue: A closure that is called with each value emitted by the publisher.
	///
	/// This function is limited to publishers that cannot fail (`Failure == Never`).
	///
	func sinkForLifetimeOf<Object: CombineExtensionsProvider>(
		_ object: Object,
		receiveValue: @escaping (Self.Output) -> Void
	) where Failure == Never {
		sink(receiveValue: receiveValue)
			.store(in: &object.combineExtensions.cancellables)
	}

	///
	/// Subscribes to the publisher and forwards emitted values and completion events to the specified closures while managing the subscription's lifetime.
	/// This function sets up a subscription that calls the provided `receiveValue` closure whenever the publisher emits a value,
	/// and the `receiveCompletion` closure when the publisher finishes or encounters an error.
	/// The cancellable is stored in `object.combineExtensions.cancellables`, ensuring that the subscription
	/// is automatically cancelled when the provided object is deallocated.
	///
	/// - Parameter object: An instance conforming to `CombineExtensionsProvider` that provides a storage
	///   for cancellable subscriptions.
	/// - Parameter receiveCompletion: A closure that is called with the completion event of the publisher,
	///   which can either be `.finished` or `.failure(error)`.
	/// - Parameter receiveValue: A closure that is called with each value emitted by the publisher.
	///
	func sinkForLifetimeOf<Object: CombineExtensionsProvider>(
		_ object: Object,
		receiveCompletion: @escaping (Subscribers.Completion<Self.Failure>) -> Void,
		receiveValue: @escaping ((Self.Output) -> Void)
	) {
		sink(
			receiveCompletion: receiveCompletion,
			receiveValue: receiveValue
		)
			.store(in: &object.combineExtensions.cancellables)
	}
}

// MARK: - Then
public extension Publisher {
	///
	/// Subscribes to the publisher and forwards success or failure events to the specified closure.
	/// This function sets up a subscription that calls the provided `receiveResult` closure
	/// with a `Result<Output, Failure>` whenever the publisher emits a value or encounters an error.
	///
	/// - Parameter receiveResult: A closure that is called with the result of the publisher's output.
	///   It receives a `.success(value)` if the publisher emits a value, or a `.failure(error)` if the publisher fails.
	///
	/// Returns an `AnyCancellable` that can be used to cancel the subscription.
	///
	func then(receiveResult: @escaping (Result<Output, Failure>) -> Void) -> AnyCancellable {
		sink(
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

	///
	/// Subscribes to the publisher and forwards success or failure events to the specified closure while managing the subscription's lifetime.
	/// This function sets up a subscription that calls the provided `receiveResult` closure with a `Result<Self.Output, Self.Failure>`
	/// whenever the publisher emits a value or encounters an error.
	/// The cancellable is stored in `object.combineExtensions.cancellables`, ensuring that the subscription
	/// is automatically cancelled when the provided object is deallocated.
	///
	/// - Parameter object: An instance conforming to `CombineExtensionsProvider` that provides a storage
	///   for cancellable subscriptions.
	/// - Parameter receiveResult: A closure that is called with the result of the publisher's output.
	///   It receives a `.success(value)` if the publisher emits a value, or a `.failure(error)` if the publisher fails.
	///
	func thenForLifetimeOf<Object: CombineExtensionsProvider>(
		_ object: Object,
		receiveResult: @escaping (Result<Self.Output, Self.Failure>) -> Void
	) {
		then(receiveResult: receiveResult)
			.store(in: &object.combineExtensions.cancellables)
	}
}

// MARK: - Perform During Life Time
public extension Publisher {
	///
	/// Subscribes to the publisher and performs a specified action with the emitted values during the lifetime of the provided object.
	/// This function ignores any errors emitted by the publisher, and for each value emitted, it calls the provided `action`
	/// closure with the object and the emitted value. The subscription is automatically cancelled when the provided object is deallocated.
	///
	/// - Parameter object: An instance conforming to both `CombineExtensionsProvider` and `AnyObject`,
	///   which provides storage for cancellable subscriptions and allows for weak references.
	/// - Parameter action: A closure that is called with the object and each emitted value from the publisher.
	///
	func performDuringLifetimeOf<Object: CombineExtensionsProvider & AnyObject>(
		_ object: Object,
		action: @escaping (Object, Output) -> Void
	) {
		ignoreErrors()
			.sinkForLifetimeOf(object) { [weak object] value in
				guard let object else {
					return
				}
				action(object, value)
			}
	}

	///
	/// Subscribes to the publisher and performs a specified action with the emitted values during the lifetime of the provided object.
	/// This function allows the action to be a curried closure, meaning it can first take the object as an argument
	/// and return a closure that takes the emitted value as its argument.
	/// The subscription is automatically cancelled when the provided object is deallocated.
	///
	/// - Parameter object: An instance conforming to both `CombineExtensionsProvider` and `AnyObject`,
	///   which provides storage for cancellable subscriptions and allows for weak references.
	/// - Parameter action: A curried closure that first takes the object and returns another closure,
	///   which is then called with each emitted value from the publisher.
	///
	func performDuringLifetimeOf<Object: CombineExtensionsProvider & AnyObject>(
		_ object: Object,
		action: @escaping (Object) -> (Output) -> Void
	) {
		performDuringLifetimeOf(object) { object, output in
			action(object)(output)
		}
	}
}

// MARK: - Assign
public extension Publisher where Failure == Never {
	///
	/// Subscribes to the publisher and assigns emitted values to the specified key path of the provided object
	/// without retaining the object strongly. This function uses a weak reference to the object, ensuring that
	/// it does not extend the lifetime of the object unnecessarily.
	///
	/// When a new value is emitted by the publisher, it is assigned to the property specified by the given
	/// `keyPath` on the object, as long as the object still exists.
	///
	/// - Parameter keyPath: A reference writable key path that specifies the property of the object
	///   to which the emitted values will be assigned.
	/// - Parameter object: An instance of the object to which the emitted values will be assigned.
	///   This object is captured weakly to prevent strong reference cycles.
	///
	/// - Returns: An `AnyCancellable` that represents the ongoing subscription, allowing it to be cancelled
	///   when no longer needed.
	///
	func assign<Object: AnyObject>(
		to keyPath: ReferenceWritableKeyPath<Object, Output>,
		withoutRetaining object: Object
	) -> AnyCancellable {
		sink { [weak object] in
			object?[keyPath: keyPath] = $0
		}
	}

	///
	/// Subscribes to the publisher and assigns emitted values to the specified key path of the provided object
	/// for the lifetime of the object. This function uses a weak reference to the object to avoid strong
	/// reference cycles while ensuring that the emitted values are assigned to the property specified by the
	/// given `keyPath` as long as the object exists. The subscription is automatically cancelled when the
	/// object is deallocated, preventing memory leaks.
	///
	/// - Parameter keyPath: A reference writable key path that specifies the property of the object
	///   to which the emitted values will be assigned.
	/// - Parameter object: An instance of the object to which the emitted values will be assigned.
	///   This object is captured weakly to prevent strong reference cycles, but its cancellables are stored
	///   to maintain the subscription for its lifetime.
	///
	/// - Returns: This function does not return a value, as the assignment is performed directly on the object.
	///
	func assign<Object: CombineExtensionsProvider & AnyObject>(
		to keyPath: ReferenceWritableKeyPath<Object, Output>,
		forLifetimeOf object: Object
	) {
		sink { [weak object] in
			object?[keyPath: keyPath] = $0
		}
		.store(in: &object.combineExtensions.cancellables)
	}
}

// MARK: - Ignore Nils
public extension Publisher where Output: OptionalProtocol {
	///
	/// Transforms an optional publisher into a non-optional publisher by ignoring nil values.
	/// If the upstream publisher emits a non-nil value, it wraps that value in a `Just` publisher.
	/// If a nil value is emitted, it replaces it with an `Empty` publisher, ensuring that the
	/// downstream subscriber only receives non-optional values.
	///
	/// This function effectively filters out any nil values from the output stream, allowing only
	/// valid (non-nil) values to be processed downstream. It maintains the original failure type
	/// of the publisher.
	///
	/// - Returns: An `AnyPublisher<Output.Wrapped, Failure>` that emits non-optional values
	///   (if available) or completes without emitting any values if nil is encountered.
	///
	func ignoreNils() -> AnyPublisher<Output.Wrapped, Failure> {
		flatMap { optionalPublisher in
			let wrappedPublisher = optionalPublisher.wrapped.map {
				Just($0).eraseToAnyPublisher()
			}

			let finalPublisher = wrappedPublisher ?? Empty().eraseToAnyPublisher()
			return finalPublisher
				.setFailureType(to: Failure.self)
		}
		.eraseToAnyPublisher()
	}
}
