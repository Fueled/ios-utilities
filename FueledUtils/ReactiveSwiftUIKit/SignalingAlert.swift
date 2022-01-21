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

#if canImport(UIKit)
import Foundation
import ReactiveCocoa
import ReactiveSwift
import UIKit

///
/// A UIAlertController wrapper that sends values associated with alert actions to its output signal that emits values of type `T`.
///
public final class SignalingAlert<T> {
	///
	/// The underlying `UIAlertController` of the class is associated with.
	///
	public let controller: UIAlertController
	///
	/// The output signal the class is associated with.
	///
	public let signal: Signal<T, Never>
	fileprivate let observer: Signal<T, Never>.Observer

	///
	/// Initialize a `SignalingAlert` with the given `title`, `message` and `preferredStyle`.
	///
	public init(title: String?, message: String?, preferredStyle: UIAlertController.Style) {
		(signal, observer) = Signal<T, Never>.pipe()
		controller = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
		Lifetime.of(controller).ended.observeCompleted { [observer] in
			observer.sendInterrupted()
		}
	}

	///
	/// Add an action to the alert, sending the `event` when the user taps the action.
	///
	public func addAction(title: String, style: UIAlertAction.Style, event: Signal<T, Never>.Event) {
		controller.addAction(UIAlertAction(title: title, style: style) { [observer] _ in
			observer.send(event)
		})
	}

	///
	/// Add an action to the alert, sending the `event` when the user taps the action.
	///
	public func addAction(title: String, style: UIAlertAction.Style, value: T) {
		controller.addAction(UIAlertAction(title: title, style: style) { [observer] _ in
			observer.send(value: value)
			observer.sendCompleted()
		})
	}

	///
	/// Ahelper  factory method allowing to display a `SignalingAlert` on screen.
	///
	/// - Parameters:
	///   - title: The title of the alert
	///   - message: The message of the alert
	///   - preferredStyle: The preferred style of the alert
	///   - presentingController: The view controller to present the alert from
	///   - sourceView: The view that presents the alert, if on ipad and wanted to use a popover style
	///     Keep in mind that using a `sourceView` is **required** if using the `actionSheet` style.
	///   - configure: A closure allowing to customize the `SignalingAlert`, for example to add actions.
	/// - Returns: A `SignalProducer` that when started, will display the alert on screen.
	///   Note that this `SignalProducer` will retain all the parameters given in `producer` until it is started.
	///
	public static func producer(
		title: String? = nil,
		message: String? = nil,
		preferredStyle: UIAlertController.Style,
		presentingController: UIViewController,
		sourceView: UIView?,
		configure: ((SignalingAlert) -> Void)? = nil)
		-> SignalProducer<T, Never>
	{
		return SignalProducer { observer, disposable in
			let alert = SignalingAlert(
				title: title,
				message: message,
				preferredStyle: preferredStyle)
			disposable += alert.signal.observe(observer)
			configure?(alert)
			if let popoverPresentationController = alert.controller.popoverPresentationController {
				popoverPresentationController.sourceView = sourceView
				popoverPresentationController.sourceRect = sourceView?.bounds ?? .zero
			}
			presentingController.present(alert.controller, animated: true, completion: nil)
			disposable += AnyDisposable { [weak presentingController, weak alert] in
				if let presentingController = presentingController,
					let alert = alert,
					alert.controller.presentingViewController == presentingController
				{
					presentingController.dismiss(animated: true, completion: nil)
				}
			}
		}
	}
}
#endif
