import Foundation
import ReactiveCocoa
import Result

public extension SignalType {
	public func observeWithContext(context: (Void -> Void) -> Void) -> Signal<Value, Error> {
		return Signal { observer in
			return self.observe { event in
				switch event {
				case .Next:
					context({ observer.action(event) })
				default:
					observer.action(event)
				}
			}
		}
	}
}

public func animatingContext(
	duration: NSTimeInterval,
	delay: NSTimeInterval = 0,
	options: UIViewAnimationOptions = [],
	layoutView: UIView? = nil,
	completion: ((Bool) -> Void)? = nil)
	-> ((Void -> Void) -> Void)
{
	return { [weak layoutView] animations in
		layoutView?.layoutIfNeeded()
		UIView.animateWithDuration(
			duration,
			delay: delay,
			options: options,
			animations: {
				animations()
				layoutView?.layoutIfNeeded()
			},
			completion: completion)
	}
}

public extension SignalProducerType {
	@warn_unused_result(message="Did you forget to call `start` on the producer?")
	public func ignoreError() -> SignalProducer<Value, NoError> {
		return self.flatMapError { _ in
			SignalProducer<Value, NoError>.empty
		}
	}

	@warn_unused_result(message="Did you forget to call `start` on the producer?")
	public func delayStart(interval: NSTimeInterval, onScheduler scheduler: DateSchedulerType) -> ReactiveCocoa.SignalProducer<Value, Error> {
		return SignalProducer<(), Error>(value: ())
			.delay(interval, onScheduler: scheduler)
			.flatMap(.Latest) { _ in self.producer }
	}

	@warn_unused_result(message="Did you forget to call `start` on the producer?")
	public func observeWithContext(context: (Void -> Void) -> Void) -> SignalProducer<Value, Error> {
		return lift { $0.observeWithContext(context) }
	}
}

public extension SignalProducerType where Error == NoError {

	public func chain<U>(transform: Value -> Signal<U, NoError>) -> SignalProducer<U, NoError> {
		return flatMap(.Latest, transform: transform)
	}

	public func chain<U>(transform: Value -> SignalProducer<U, NoError>) -> SignalProducer<U, NoError> {
		return flatMap(.Latest, transform: transform)
	}

	public func chain<P: PropertyType>(transform: Value -> P) -> SignalProducer<P.Value, NoError> {
		return flatMap(.Latest) { transform($0).producer }
	}

	public func chain<U>(transform: Value -> Signal<U, NoError>?) -> SignalProducer<U, NoError> {
		return flatMap(.Latest) { transform($0) ?? Signal<U, NoError>.never }
	}

	public func chain<U>(transform: Value -> SignalProducer<U, NoError>?) -> SignalProducer<U, NoError> {
		return flatMap(.Latest) { transform($0) ?? SignalProducer<U, NoError>.empty }
	}

	public func chain<P: PropertyType>(transform: Value -> P?) -> SignalProducer<P.Value, NoError> {
		return flatMap(.Latest) { transform($0)?.producer ?? SignalProducer<P.Value, NoError>.empty }
	}

}

public extension PropertyType {

	public func chain<U>(transform: Value -> Signal<U, NoError>) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}

	public func chain<U>(transform: Value -> SignalProducer<U, NoError>) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}

	public func chain<P: PropertyType>(transform: Value -> P) -> SignalProducer<P.Value, NoError> {
		return producer.chain(transform)
	}

	public func chain<U>(transform: Value -> Signal<U, NoError>?) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}

	public func chain<U>(transform: Value -> SignalProducer<U, NoError>?) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}

	public func chain<P: PropertyType>(transform: Value -> P?) -> SignalProducer<P.Value, NoError> {
		return producer.chain(transform)
	}

}

infix operator <~> {
	associativity right
	precedence 93
}

public func <~> <P1: MutablePropertyType, P2: MutablePropertyType where P1.Value == P2.Value>(property1: P1, property2: P2) -> Disposable {
	let disposable = CompositeDisposable()
	var inObservation = false
	disposable += property2.producer.start {
		[weak property1] event in
		switch event {
		case let .Next(value):
			if !inObservation {
				inObservation = true
				property1?.value = value
				inObservation = false
			}
		case .Completed:
			disposable.dispose()
		default:
			break
		}
	}
	disposable += property1.producer.start {
		[weak property2] event in
		switch event {
		case let .Next(value):
			if !inObservation {
				inObservation = true
				property2?.value = value
				inObservation = false
			}
		case .Completed:
			disposable.dispose()
		default:
			break
		}
	}
	return disposable
}
