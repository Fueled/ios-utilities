import Foundation
import ReactiveCocoa
import Result
import UIKit

public final class SignalingAlert<T> {

	public let controller: UIAlertController
	public let signal: Signal<T, NoError>
	private let observer: Signal<T, NoError>.Observer

	public init(title: String?, message: String?, preferredStyle: UIAlertControllerStyle) {
		(signal, observer) = Signal<T, NoError>.pipe()
		controller = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
		controller.rac_willDeallocSignal().toSignalProducer().startWithCompleted { [observer] in
			observer.sendInterrupted()
		}
	}

	public func addAction(title title: String, style: UIAlertActionStyle, event: Event<T, NoError>) {
		controller.addAction(UIAlertAction(title: title, style: style) { [observer] _ in
			observer.action(event)
		})
	}

	public func addAction(title title: String, style: UIAlertActionStyle, value: T) {
		controller.addAction(UIAlertAction(title: title, style: style) { [observer] _ in
			observer.sendNext(value)
			observer.sendCompleted()
		})
	}

	public static func producer(
		title title: String? = nil,
		message: String? = nil,
		preferredStyle: UIAlertControllerStyle,
		presentingController: UIViewController,
		sourceView: UIView,
		configure: SignalingAlert -> () = { _ in })
		-> SignalProducer<T, NoError>
	{
		return SignalProducer { observer, disposable in
			let alert = SignalingAlert(
				title: title,
				message: message,
				preferredStyle: preferredStyle)
			disposable += alert.signal.observe(observer)
			configure(alert)
			if let ppc = alert.controller.popoverPresentationController {
				ppc.sourceView = sourceView
				ppc.sourceRect = sourceView.bounds
			}
			presentingController.presentViewController(alert.controller, animated: true, completion: nil)
			disposable += ActionDisposable { [weak presentingController, weak alert] in
				if let presentingController = presentingController,
					alert = alert where
					alert.controller.presentingViewController == presentingController
				{
					presentingController.dismissViewControllerAnimated(true, completion: nil)
				}
			}
		}
	}

}
