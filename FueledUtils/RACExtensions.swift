import Foundation
import ReactiveSwift
import Result

public final class Function<A, B> {
	let f: (A) -> B
	init(_ f: @escaping (A) -> B) {
		self.f = f
	}
}

public extension SignalProtocol {
	func merge(with signal2: Signal<Value, Error>) -> Signal<Value, Error> {
		return Signal { observer in
			let disposable = CompositeDisposable()
			disposable += self.observe(observer)
			disposable += signal2.observe(observer)
			return disposable
		}
	}
	public func observe(context: @escaping (Function<Void, Void>) -> Void) -> Signal<Value, Error> {
		return Signal { observer in
			return self.observe { event in
				switch event {
				case .value:
					context(Function { observer.action(event) })
				default:
					observer.action(event)
				}
			}
		}
	}
}

public func animatingContext(
	_ duration: TimeInterval,
	delay: TimeInterval = 0,
	options: UIViewAnimationOptions = [],
	layoutView: UIView? = nil,
	completion: ((Bool) -> Void)? = nil)
	-> ((Function<Void, Void>) -> Void)
{
	return { [weak layoutView] animations in
		layoutView?.layoutIfNeeded()
		UIView.animate(
			withDuration: duration,
			delay: delay,
			options: options,
			animations: {
				animations.f()
				layoutView?.layoutIfNeeded()
			},
			completion: completion)
	}
}

public extension SignalProducerProtocol {
	public func ignoreError() -> SignalProducer<Value, NoError> {
		return self.flatMapError { _ in
			SignalProducer<Value, NoError>.empty
		}
	}
	public func delayStart(_ interval: TimeInterval, on scheduler: DateSchedulerProtocol) -> ReactiveSwift.SignalProducer<Value, Error> {
		return SignalProducer<(), Error>(value: ())
			.delay(interval, on: scheduler)
			.flatMap(.latest) { _ in self.producer }
	}
	public func observe(context: @escaping (Function<Void, Void>) -> Void) -> SignalProducer<Value, Error> {
		return lift { $0.observe(context: context) }
	}
}

public extension SignalProducerProtocol where Error == NoError {

	public func chain<U>(_ transform: @escaping (Value) -> Signal<U, NoError>) -> SignalProducer<U, NoError> {
		return flatMap(.latest, transform: transform)
	}

	public func chain<U>(_ transform: @escaping (Value) -> SignalProducer<U, NoError>) -> SignalProducer<U, NoError> {
		return flatMap(.latest, transform: transform)
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

public extension PropertyProtocol {

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

extension Reactive where Base: NSObject {
	public func target<U>(action: @escaping (Base, U) -> Void) -> BindingTarget<U> {
		return BindingTarget(on: ImmediateScheduler(), lifetime: lifetime) {
			[weak base = self.base] value in
			if let base = base {
				action(base, value)
			}
		}
	}
}

extension Reactive where Base: NSLayoutConstraint {
	public var isActive: BindingTarget<Bool> {
		return target { $0.isActive = $1 }
	}
	public var constant: BindingTarget<CGFloat> {
		return target { $0.constant = $1 }
	}
}

extension Reactive where Base: LabelWithTitleAdjustment {
	public var adjustedText: BindingTarget<String?> {
		return target { $0.setAdjustedText($1) }
	}
	public var adjustedAttributedText: BindingTarget<NSAttributedString?> {
		return target { $0.setAdjustedAttributedText($1) }
	}
}

extension Reactive where Base: ButtonWithTitleAdjustment {
	public func adjustedTitle(for state: UIControlState) -> BindingTarget<String?> {
		return target { $0.setAdjustedTitle($1, for: state) }
	}
}

extension Reactive where Base: UISearchBar {
	public var text: BindingTarget<String?> {
		return target { $0.text = $1 }
	}
}

extension Reactive where Base: UIView {
	public var backgroundColor: BindingTarget<UIColor?> {
		return target { $0.backgroundColor = $1 }
	}
}

extension Reactive where Base: UIViewController {
	public var title: BindingTarget<String?> {
		return target { $0.title = $1 }
	}
	public var performSegue: BindingTarget<(String, AnyObject?)> {
		return target { $0.performSegue(withIdentifier: $1.0, sender: $1.1) }
	}
}

extension Reactive where Base: UIBarItem {
	public var title: BindingTarget<String?> {
		return target { $0.title = $1 }
	}
}
