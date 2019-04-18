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
import ReactiveCocoa
import ReactiveSwift
import UIKit

///
/// Use with `SignalProtocol.observe(context:)` or  `SignalProducerProtocol.observe(context:)` below to animate
/// all changes made by observers of the signal returned from `observe(context:)`.
///
public func animatingContext(
	_ duration: TimeInterval,
	delay: TimeInterval = 0,
	options: UIView.AnimationOptions = [],
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

///
/// Use with `SignalProtocol.observe(context:)` or  `SignalProducerProtocol.observe(context:)` below to animate
/// all changes made by observers of the signal returned from `observe(context:)`.
///
public func transitionContext(
	with view: UIView,
	duration: TimeInterval,
	delay: TimeInterval = 0,
	options: UIView.AnimationOptions = [],
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

extension Reactive where Base: NSLayoutConstraint {
	///
	/// Set whether the constant is active or not in its hierarchy.
	///
	public var isActive: BindingTarget<Bool> {
		return makeBindingTarget { $0.isActive = $1 }
	}
}

extension Reactive where Base: UIView {
	///
	/// Update the `alpha` property of the view with an animation.
	///
	var animatedAlpha: BindingTarget<Float> {
		return self.animatedAlpha()
	}

	///
	/// Update the `alpha` property of the view with an animation.
	///
	/// - Parameters:
	///   - duration: The duration of the animation.
	///
	func animatedAlpha(duration: TimeInterval = 0.35) -> BindingTarget<Float> {
		return makeBindingTarget { view, alpha in
			UIView.animate(withDuration: duration) {
				view.alpha = CGFloat(alpha)
			}
		}
	}
}

extension Reactive where Base: UILabel {
	///
	/// Update the `text` property of the label with an animation.
	///
	var animatedText: BindingTarget<String> {
		return makeBindingTarget { label, text in
			label.setText(text, animated: true)
		}
	}
	///
	/// Update the `attributedText` property of the label with an animation.
	///
	var animatedAttributedText: BindingTarget<NSAttributedString> {
		return makeBindingTarget { label, text in
			label.setAttributedText(text, animated: true)
		}
	}

	///
	/// Update the `textAlignment` property of the label with an animation.
	///
	public var textAlignment: BindingTarget<NSTextAlignment> {
		return makeBindingTarget { $0.textAlignment = $1 }
	}
}

extension Reactive where Base: UIViewController {
	///
	/// Update the `title` property of the receiver.
	///
	public var title: BindingTarget<String?> {
		return makeBindingTarget { $0.title = $1 }
	}
	///
	/// Perform a segue with the specified identifier and sender.
	///
	public var performSegue: BindingTarget<(String, Any?)> {
		return makeBindingTarget { $0.performSegue(withIdentifier: $1.0, sender: $1.1) }
	}
}

@available(iOS 9.0, *)
extension Reactive where Base: UIStackView {
	///
	/// **Unavailable**: Use `subview.reactive.isHidden <~ <Binding Source>` instead.
	/// Add/remove/modify the order of the arranged subviews by specified the subview.
	///
	@available(*, unavailable, message: "Use `subview.reactive.isHidden <~ <Binding Source>` instead")
	public func isArranged(_ subview: UIView, at index: Int) -> BindingTarget<Bool> {
		fatalError()
	}
}

#if os(iOS)
extension Reactive where Base: UINavigationItem {
	///
	/// Show/hide the back button, optionally with an animation.
	///
	public func hidesBackButton(animated: Bool) -> BindingTarget<Bool> {
		return makeBindingTarget { $0.setHidesBackButton($1, animated: animated) }
	}
	///
	/// Show/hide the right bar button item, optionally with an animation.
	///
	public func rightBarButtonItem(animated: Bool) -> BindingTarget<UIBarButtonItem?> {
		return makeBindingTarget { $0.setRightBarButton($1, animated: animated) }
	}
	///
	/// Show/hide the right bar button items, optionally with an animation.
	///
	public func rightBarButtonItems(animated: Bool) -> BindingTarget<[UIBarButtonItem]> {
		return makeBindingTarget { $0.setRightBarButtonItems($1, animated: animated) }
	}
	///
	/// Show/hide the left bar button item, optionally with an animation.
	///
	public func leftBarButtonItem(animated: Bool) -> BindingTarget<UIBarButtonItem?> {
		return makeBindingTarget { $0.setLeftBarButton($1, animated: animated) }
	}
	///
	/// Show/hide the left bar button items, optionally with an animation.
	///
	public func leftBarButtonItems(animated: Bool) -> BindingTarget<[UIBarButtonItem]> {
		return makeBindingTarget { $0.setLeftBarButtonItems($1, animated: animated) }
	}
	///
	/// Show/hide the right bar button item without any animations.
	///
	public var rightBarButtonItem: BindingTarget<UIBarButtonItem?> {
		return makeBindingTarget { $0.rightBarButtonItem = $1 }
	}
	///
	/// Show/hide the right bar button items without any animations.
	///
	public var rightBarButtonItems: BindingTarget<[UIBarButtonItem]> {
		return makeBindingTarget { $0.rightBarButtonItems = $1 }
	}
	///
	/// Show/hide the left bar button item without any animations.
	///
	public var leftBarButtonItem: BindingTarget<UIBarButtonItem?> {
		return makeBindingTarget { $0.leftBarButtonItem = $1 }
	}
	///
	/// Show/hide the left bar button items without any animations.
	///
	public var leftBarButtonItems: BindingTarget<[UIBarButtonItem]> {
		return makeBindingTarget { $0.leftBarButtonItems = $1 }
	}
}
#endif
