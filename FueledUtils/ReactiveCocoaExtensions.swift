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
import Result

///
/// Use with `observe(context:)` function below to animate all changes made by observers of the signal returned from `observe(context:)`.
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
	@available(*, deprecated, message: "Use `subview.reactive.isHidden <~ <Binding Source>` instead")
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
