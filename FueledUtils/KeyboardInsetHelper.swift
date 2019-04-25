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
import UIKit

/// Binds keyboard appearance and metrics to scroll view content and scroll bar insets and/or a layout constraint \
/// relative to reference view. This object can be created and linked in a sotryboard.
open class KeyboardInsetHelper: NSObject {
	/// Minimum inset
	@IBInspectable public var baseInset: CGFloat = 0
	/// The inset and constraint constant will be calculated in the coordinates of this view.
	@IBOutlet public weak var referenceView: UIView?
	/// Scroll view to adjust content inset at. When the keyboard appears or disappears, the inset will be adjusted to \
	/// align the bottom of the scroll view's content with the top of the keyboard (minimum `baseInset` takes priority).
	@IBOutlet public weak var scrollView: UIScrollView?
	/// When the keyboard appears or disappears, the constraint's constant will be set to the distance between the bottom of the \
	/// reference view and the top of the keyboard but no less than `baseInset`.
	@IBOutlet public weak var constraint: NSLayoutConstraint?

	public override init() {
		super.init()
		let nc = NotificationCenter.default
		nc.addObserver(
			self,
			selector: #selector(handleKeyboardNotification(_:)),
			name: UIResponder.keyboardWillShowNotification,
			object: nil
		)
		nc.addObserver(
			self,
			selector: #selector(handleKeyboardNotification(_:)),
			name: UIResponder.keyboardWillHideNotification,
			object: nil
		)
	}

	deinit {
		let nc = NotificationCenter.default
		nc.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		nc.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}

	@objc fileprivate func handleKeyboardNotification(_ notification: Notification) {
		guard let referenceView = referenceView,
			let userInfo = (notification as NSNotification).userInfo,
			let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
			let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
			let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
			else { return }
		let keyboardFrame = referenceView.convert(keyboardFrameValue.cgRectValue, from: referenceView.window)
		let curveOption = UIView.AnimationOptions(rawValue: curve << 16)
		let animationOptions = curveOption.union(.beginFromCurrentState)
		let inset = max(baseInset, referenceView.bounds.maxY - keyboardFrame.minY)
		UIView.performWithoutAnimation {
			self.referenceView?.window?.layoutIfNeeded()
		}
		UIView.animate(
			withDuration: duration,
			delay: 0,
			options: animationOptions,
			animations: { self.updateForInset(inset) },
			completion: nil
		)
	}

	open func updateForInset(_ inset: CGFloat) {
		scrollView?.contentInset.bottom = inset
		scrollView?.scrollIndicatorInsets.bottom = inset
		constraint?.constant = inset
		referenceView?.layoutIfNeeded()
	}
}
