import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result

/// Use with `observe(context:)` function below to animate all changes made by observers of the signal returned from `observe(context:)`.
public func animatingContext(
	_ duration: TimeInterval,
	delay: TimeInterval = 0,
	options: UIViewAnimationOptions = [],
	layoutView: UIView? = nil,
	completion: ((Bool) -> Void)? = nil)
	-> ((@escaping () -> Void) -> Void)
{
	return { [weak layoutView] animations in
		layoutView?.layoutIfNeeded()
		UIView.animate(
			withDuration: duration,
			delay: delay,
			options: options,
			animations: {
				animations()
				layoutView?.layoutIfNeeded()
			},
			completion: completion)
		}
}

public func transitionContext(
	with view: UIView,
	duration: TimeInterval,
	delay: TimeInterval = 0,
	options: UIViewAnimationOptions = [],
	completion: ((Bool) -> Void)? = nil)
	-> ((@escaping () -> Void) -> Void)
{
	return { animations in
		UIView.transition(
			with: view,
			duration: duration,
			options: options,
			animations: animations,
			completion: completion)
		}
}

public extension SignalProtocol {
	/**
	The original purpose of this method is to allow triggering animations in response to signal values.
	- Returns: a signal of which observers will receive values in the context defined by `context` function.
	- Parameters:
		- context: defines a context in which observers of the resulting signal will be called.
	## Example
	The following code
		self.constraint.reactive.constant <~ viewModel.constraintConstantValue.signal.observe(context: animatingContext)
	will result in all changes to `constraintConstantValue` in `viewModel` to be reflected in the constraint and animated.
	*/
	public func observe(context: @escaping (@escaping () -> Void) -> Void) -> Signal<Value, Error> {
		return Signal { observer in
			return self.signal.observe { event in
				switch event {
				case .value:
					context({ observer.action(event) })
				default:
					observer.action(event)
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
	/// - seealso: `debounce`, `throttle`
	///
	/// - note: If multiple values are received before the interval has elapsed,
	///         they will all be sent at once.
	///
	/// - note: If the input signal terminates while a value is being debounced, 
	///         that value will be discarded and the returned signal will 
	///         terminate immediately.
	///
	/// - precondition: `interval` must be non-negative number.
	///
	/// - parameters:
	///   - interval: A number of seconds to wait before sending a value.
	///   - scheduler: A scheduler to send values on.
	///
	/// - returns: A signal that sends values that are sent from `self` at least
	///            `interval` seconds apart.
	///
	func minimum(interval: TimeInterval, on scheduler: DateScheduler) -> Signal<Value, Error> {
		return Signal { observer in
			let semaphore = DispatchSemaphore(value: 1)
			var events: [Signal<Value, Error>.Event] = []
			var forwardEvents = false
			let disposable = CompositeDisposable()
			func sendEvents() {
				semaphore.wait()
				events.forEach { observer.action($0) }
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
					observer.action(event)
					return
				}
				if forwardEvents {
					observer.action(event)
				} else {
					semaphore.wait()
					events.append(event)
					semaphore.signal()
				}
			}
			return disposable
		}
	}
}

public extension SignalProducerProtocol {
	public func ignoreError() -> SignalProducer<Value, NoError> {
		return self.producer.flatMapError { _ in
			SignalProducer<Value, NoError>.empty
		}
	}
	public func delayStart(_ interval: TimeInterval, on scheduler: DateScheduler) -> ReactiveSwift.SignalProducer<Value, Error> {
		return SignalProducer<(), Error>(value: ())
			.delay(interval, on: scheduler)
			.flatMap(.latest) { _ in self.producer }
	}
	public func observe(context: @escaping (@escaping () -> Void) -> Void) -> SignalProducer<Value, Error> {
		return self.producer.lift { $0.observe(context: context) }
	}
	/// See `Signal.minimum` for documentation
	func minimum(interval: TimeInterval, on scheduler: DateScheduler) -> SignalProducer<Value, Error> {
		return self.producer.lift { $0.minimum(interval: interval, on: scheduler) }
	}
}

public extension SignalProducer where Error == NoError {

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

extension Reactive where Base: NSLayoutConstraint {
	public var isActive: BindingTarget<Bool> {
		return makeBindingTarget { $0.isActive = $1 }
	}
}

extension Reactive where Base: UIView {
	var animatedAlpha: BindingTarget<Float> {
		return self.animatedAlpha()
	}

	func animatedAlpha(duration: TimeInterval = 0.35) -> BindingTarget<Float> {
		return makeBindingTarget { view, alpha in
			UIView.animate(withDuration: duration) {
				view.alpha = CGFloat(alpha)
			}
		}
	}
}

extension Reactive where Base: UILabel {
	var animatedText: BindingTarget<String> {
		return makeBindingTarget { label, text in
			label.setText(text, animated: true)
		}
	}
	var animatedAttributedText: BindingTarget<NSAttributedString> {
		return makeBindingTarget { label, text in
			label.setAttributedText(text, animated: true)
		}
	}
}

extension Reactive where Base: UILabel {
	public var textAlignment: BindingTarget<NSTextAlignment> {
		return makeBindingTarget { $0.textAlignment = $1 }
	}
}

extension Reactive where Base: UIViewController {
	public var title: BindingTarget<String?> {
		return makeBindingTarget { $0.title = $1 }
	}
	public var performSegue: BindingTarget<(String, Any?)> {
		return makeBindingTarget { $0.performSegue(withIdentifier: $1.0, sender: $1.1) }
	}
}

@available(iOS 9.0, *)
extension Reactive where Base: UIStackView {
	public func isArranged(_ subview: UIView, at index: Int) -> BindingTarget<Bool> {
		return makeBindingTarget { stackView, isArrangedSubview in
			if isArrangedSubview {
				stackView.insertArrangedSubview(subview, at: index)
			} else {
				stackView.removeArrangedSubview(subview)
			}
		}
	}
}

extension Reactive where Base: UINavigationItem {
	public func hidesBackButton(animated: Bool) -> BindingTarget<Bool> {
		return makeBindingTarget { $0.setHidesBackButton($1, animated: animated) }
	}
	public func rightBarButtonItem(animated: Bool) -> BindingTarget<UIBarButtonItem?> {
		return makeBindingTarget { $0.setRightBarButton($1, animated: animated) }
	}
	public func rightBarButtonItems(animated: Bool) -> BindingTarget<[UIBarButtonItem]> {
		return makeBindingTarget { $0.setRightBarButtonItems($1, animated: animated) }
	}
	public func leftBarButtonItem(animated: Bool) -> BindingTarget<UIBarButtonItem?> {
		return makeBindingTarget { $0.setLeftBarButton($1, animated: animated) }
	}
	public func leftBarButtonItems(animated: Bool) -> BindingTarget<[UIBarButtonItem]> {
		return makeBindingTarget { $0.setLeftBarButtonItems($1, animated: animated) }
	}
	public var rightBarButtonItem: BindingTarget<UIBarButtonItem?> {
		return makeBindingTarget { $0.rightBarButtonItem = $1 }
	}
	public var rightBarButtonItems: BindingTarget<[UIBarButtonItem]> {
		return makeBindingTarget { $0.rightBarButtonItems = $1 }
	}
	public var leftBarButtonItem: BindingTarget<UIBarButtonItem?> {
		return makeBindingTarget { $0.leftBarButtonItem = $1 }
	}
	public var leftBarButtonItems: BindingTarget<[UIBarButtonItem]> {
		return makeBindingTarget { $0.leftBarButtonItems = $1 }
	}
}
