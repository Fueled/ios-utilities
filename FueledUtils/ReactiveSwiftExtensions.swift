/*
Copyright © 2019 Fueled Digital Media, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
import Foundation
import ReactiveSwift
import Result

extension SignalProtocol {
	///
	/// Make the `Signal` output optional `Value`.
	///
	public func promoteOptional() -> Signal<Value?, Error> {
		return self.signal.map { $0 }
	}

	/// The original purpose of this method is to allow triggering animations in response to signal values.
	///
	/// - Parameters:
	/// 	- context: Defines a context in which observers of the resulting signal will be called.
	/// - Returns: A signal of which observers will receive values in the context defined by `context` function.
	///
	/// ## Example
	/// The following code
	/// ```swift
	/// self.constraint.reactive.constant <~ viewModel.constraintConstantValue.signal.observe(context: animatingContext)
	/// ```
	/// will result in all changes to `constraintConstantValue` in `viewModel` to be reflected in the constraint and animated.
	public func observe(context: @escaping (@escaping () -> Void) -> Void) -> Signal<Value, Error> {
		return Signal { observer, disposable in
			disposable += self.signal.observe { event in
				switch event {
				case .value:
					context({ observer.send(event) })
				default:
					observer.send(event)
				}
			}
		}
	}

	/// All events (except .interrupted) are sent after the minimum interval.
	/// If interrupted is received, the signal is interrupted (regardless of the interval), and
	/// all values received beforehand are sent, after which `.interrupted` is sent.
	///
	/// This is different from `debounce` in the following way: if the signal sends values/error
	/// before `interval` has passed, it will wait for `interval`, and then send all values in the
	/// order they were received.
	/// (With `debounce`, values received before `interval` are never sent, and errors are sent right away)
	///
	/// ### Example: ###
	/// ````
	/// // Make the action lasts at least 1.0, even if it takes less than that
	/// let actionProducer = SignalProducer { ... }
	/// let fetchAction = Action { actionProducer.minimum(interval: 1, on: QueueScheduler.main) }
	/// // The activity indicator will display for at least 1 second
	/// self.activityIndicator.reactive.isHidden <~ fetchAction.isExecuting.negate()
	/// self.activityIndicator.reactive.isAnimating <~ fetchAction.isExecuting/
	/// // Or making sure that we don't perform segues too early
	/// <viewController>.reactive.performSegue <~ fetchAction.values.map { ("myAwesomeSuccessSegue", nil) }
	/// <viewController>.reactive.performSegue <~ fetchAction.errors.map { ("myAwesomeFailureSegue", nil) }
	/// ````
	///
	/// - SeeAlso: `debounce`, `throttle`
	///
	/// - Note: If multiple values are received before the interval has elapsed,
	///         they will all be sent at once.
	///
	/// - Note: If the input signal terminates while a value is being debounced,
	///         that value will be discarded and the returned signal will 
	///         terminate immediately.
	///
	/// - Precondition: `interval` must be non-negative number.
	///
	/// - Parameters:
	///   - interval: A number of seconds to wait before sending a value.
	///   - scheduler: A scheduler to send values on.
	///
	/// - Returns: A signal that sends values that are sent from `self` at least
	///            `interval` seconds apart.
	///
	public func minimum(interval: TimeInterval, on scheduler: DateScheduler) -> Signal<Value, Error> {
		return Signal { observer, disposable in
			let semaphore = DispatchSemaphore(value: 1)
			var events: [Signal<Value, Error>.Event] = []
			var forwardEvents = false
			func sendEvents() {
				semaphore.wait()
				events.forEach { observer.send($0) }
				events.removeAll()
				forwardEvents = true
				semaphore.signal()
			}
			disposable += scheduler.schedule(after: scheduler.currentDate.addingTimeInterval(interval)) {
				sendEvents()
			}
			disposable += self.signal.observe { event in
				if case .interrupted = event {
					sendEvents()
					observer.send(event)
					return
				}
				if forwardEvents {
					observer.send(event)
				} else {
					semaphore.wait()
					events.append(event)
					semaphore.signal()
				}
			}
		}
	}

	///
	/// Applies `transform` to errors from the producer and forwards errors with non `nil` results unwrapped.
	///
	/// - Parameters:
	///   - transform: A closure that accepts an error from the `failed` event and
	///                returns a new optional error.
	/// - Returns: A producer that will send new errors, that are non `nil` after the transformation.
	///
	public func filterMapError<NewError: Swift.Error>(_ transform: @escaping (Error) -> NewError?) -> Signal<Value, NewError> {
		return Signal { observer, disposable in
			disposable += self.signal.observe { event in
				switch event {
				case .value(let value):
					observer.send(.value(value))
				case .failed(let error):
					if let error = transform(error) {
						observer.send(.failed(error))
					}
				case .completed:
					observer.send(.completed)
				case .interrupted:
					observer.send(.interrupted)
				}
			}
		}
	}

	///
	/// Returns a Signal which cannot fail. Errors that would be otherwise be sent in the original signal are ignored.
	///
	public func ignoreError() -> Signal<Value, NoError> {
		return self.filterMapError { _ in nil }
	}
}

extension SignalProducerProtocol {
	///
	/// Make the `SignalProducer` output optional `Value`.
	///
	public func promoteOptional() -> SignalProducer<Value?, Error> {
		return self.producer.lift { $0.promoteOptional() }
	}

	///
	/// Make the `Signal` output optional `Value`, and prefix it with `nil`.
	///
	public func prefixNil() -> SignalProducer<Value?, Error> {
		return self.producer.promoteOptional().prefix(value: nil)
	}

	///
	/// Returns a SignalProducer which cannot fail. Errors that would be otherwise be sent in the original producer are ignored.
	///
	public func ignoreError() -> SignalProducer<Value, NoError> {
		return self.producer.lift { $0.ignoreError() }
	}

	///
	/// Returns a SignalProducer that when started will delay starting of the original producer on given scheduler.
	///
	/// - Parameters:
	///   - interval: The time interval after which to start the `SignalProducer`
	///   - scheduler: The scheduler on which to start the `SignalProducer` after the delay has passed
	///
	public func delayStart(_ interval: TimeInterval, on scheduler: DateScheduler) -> ReactiveSwift.SignalProducer<Value, Error> {
		return SignalProducer<(), Error>(value: ())
			.delay(interval, on: scheduler)
			.flatMap(.latest) { _ in self.producer }
	}

	public func observe(context: @escaping (@escaping () -> Void) -> Void) -> SignalProducer<Value, Error> {
		return self.producer.lift { $0.observe(context: context) }
	}

	///
	/// See `Signal.minimum` for documentation
	///
	public func minimum(interval: TimeInterval, on scheduler: DateScheduler) -> SignalProducer<Value, Error> {
		return self.producer.lift { $0.minimum(interval: interval, on: scheduler) }
	}
}

extension PropertyProtocol {
	///
	/// Make the `Property` have an optional `Value`.
	///
	public func promoteOptional() -> Property<Value?> {
		return Property(initial: self.value, then: self.signal)
	}
}

extension SignalProducer where Error == NoError {
	public func chain<U>(_ transform: @escaping (Value) -> Signal<U, NoError>) -> SignalProducer<U, NoError> {
		return flatMap(.latest, transform)
	}

	public func chain<U>(_ transform: @escaping (Value) -> SignalProducer<U, NoError>) -> SignalProducer<U, NoError> {
		return flatMap(.latest, transform)
	}

	public func chain<P: PropertyProtocol>(_ transform: @escaping (Value) -> P) -> SignalProducer<P.Value, NoError> {
		return flatMap(.latest) { transform($0).producer }
	}

	public func chain<U>(_ transform: @escaping (Value) -> Signal<U, NoError>?) -> SignalProducer<U, NoError> {
		return flatMap(.latest) { transform($0) ?? Signal<U, NoError>.never }
	}

	public func chain<U>(_ transform: @escaping (Value) -> SignalProducer<U, NoError>?) -> SignalProducer<U, NoError> {
		return flatMap(.latest) { transform($0) ?? SignalProducer<U, NoError>.empty }
	}

	public func chain<P: PropertyProtocol>(_ transform: @escaping (Value) -> P?) -> SignalProducer<P.Value, NoError> {
		return flatMap(.latest) { transform($0)?.producer ?? SignalProducer<P.Value, NoError>.empty }
	}
}

extension PropertyProtocol {
	public func chain<U>(_ transform: @escaping (Value) -> Signal<U, NoError>) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}

	public func chain<U>(_ transform: @escaping (Value) -> SignalProducer<U, NoError>) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}

	public func chain<P: PropertyProtocol>(_ transform: @escaping (Value) -> P) -> SignalProducer<P.Value, NoError> {
		return producer.chain(transform)
	}

	public func chain<U>(_ transform: @escaping (Value) -> Signal<U, NoError>?) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}

	public func chain<U>(_ transform: @escaping (Value) -> SignalProducer<U, NoError>?) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}

	public func chain<P: PropertyProtocol>(_ transform: @escaping (Value) -> P?) -> SignalProducer<P.Value, NoError> {
		return producer.chain(transform)
	}
}

infix operator <~> : AssignmentPrecedence

///
/// Perform a two-way binding between 2 mutable properties.
///
@discardableResult public func <~> <P1: MutablePropertyProtocol, P2: MutablePropertyProtocol>(property1: P1, property2: P2) -> Disposable where P1.Value == P2.Value {
	let disposable = CompositeDisposable()
	var inObservation = false
	disposable += property2.producer.start {
		[weak property1] event in
		switch event {
		case let .value(value):
			if !inObservation {
				inObservation = true
				property1?.value = value
				inObservation = false
			}
		case .completed:
			disposable.dispose()
		default:
			break
		}
	}
	disposable += property1.producer.start {
		[weak property2] event in
		switch event {
		case let .value(value):
			if !inObservation {
				inObservation = true
				property2?.value = value
				inObservation = false
			}
		case .completed:
			disposable.dispose()
		default:
			break
		}
	}
	return disposable
}

extension ActionProtocol {
	///
	/// A signal of all values or errors generated from all units of work of the `Action`.
	///
	/// In other words, this sends every `Result` from every unit of work that the `Action`
	/// executes.
	///
	public var results: Signal<Result<OutputType, ErrorType>, NoError> {
		return Signal.merge(
			self.values.map { .success($0) },
			self.errors.map { .failure($0) }
		)
	}
}
