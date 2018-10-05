import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result
import UIKit

/// A UIAlertController wrapper that sends values associated with alert actions to its output signal.
public final class SignalingAlert<T> {

	public let controller: UIAlertController
	public let signal: Signal<T, NoError>
	fileprivate let observer: Signal<T, NoError>.Observer

	public init(title: String?, message: String?, preferredStyle: UIAlertController.Style) {
		(signal, observer) = Signal<T, NoError>.pipe()
		controller = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
		controller.reactive.lifetime.ended.observeCompleted { [observer] in
			observer.sendInterrupted()
		}
	}

	public func addAction(title: String, style: UIAlertAction.Style, event: Signal<T, NoError>.Event) {
		controller.addAction(UIAlertAction(title: title, style: style) { [observer] _ in
			observer.send(event)
		})
	}

	public func addAction(title: String, style: UIAlertAction.Style, value: T) {
		controller.addAction(UIAlertAction(title: title, style: style) { [observer] _ in
			observer.send(value: value)
			observer.sendCompleted()
		})
	}

	public static func producer(
		title: String? = nil,
		message: String? = nil,
		preferredStyle: UIAlertController.Style,
		presentingController: UIViewController,
		sourceView: UIView,
		configure: @escaping (SignalingAlert) -> () = { _ in })
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
			presentingController.present(alert.controller, animated: true, completion: nil)
			disposable += AnyDisposable { [weak presentingController, weak alert] in
				if let presentingController = presentingController,
					let alert = alert ,
					alert.controller.presentingViewController == presentingController
				{
					presentingController.dismiss(animated: true, completion: nil)
				}
			}
		}
	}

}
