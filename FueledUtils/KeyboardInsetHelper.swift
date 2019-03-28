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

///
/// Binds keyboard appearance and metrics to scroll view content and scroll bar insets and/or a layout constraint
/// relative to reference view. This object can be created and linked in a sotryboard.
///
open class KeyboardInsetHelper: NSObject {
	///
	/// **Deprecated**: Please use `minimumInset` instead.
	///
	/// Refer to the documentation for `minimumInset` for more info.
	///
	@available(*, deprecated, renamed: "minimumInset")
	@IBInspectable public var baseInset: CGFloat {
		get {
			return minimumInset
		}
		set {
			minimumInset = newValue
		}
	}

	///
	/// The minimum inset value. Inset values below this value are clamped to `minimumInset`.
	/// Defaults to `0`
	///
	@IBInspectable public var minimumInset: CGFloat = 0
	///
	/// The inset and constraint constant will be calculated in the coordinates of this view.
	/// This variable must be non-`nil`, otherwise the insets won't get updated.
	///
	@IBOutlet public weak var referenceView: UIView?
	///
	/// Scroll view to adjust content inset at. When the keyboard appears or disappears, the inset will be adjusted to
	/// align the bottom of the scroll view's content with the top of the keyboard (`minimumInset` takes priority).
	///
	@IBOutlet public weak var scrollView: UIScrollView?
	///
	/// When the keyboard appears or disappears, the constraint's constant will be set to the distance between the bottom of the
	/// reference view and the top of the keyboard but no less than `minimumInset`.
	///
	@IBOutlet public weak var constraint: NSLayoutConstraint?

	private var isCallingDeprecatedMethod = false

	///
	/// Initializes a new KeyboardInsetHelper with default values.
	///
	public override init() {
		super.init()
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(handleKeyboardNotification(_:)),
			name: UIResponder.keyboardWillShowNotification,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(handleKeyboardNotification(_:)),
			name: UIResponder.keyboardWillHideNotification,
			object: nil
		)
	}

	deinit {
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
		let baseInset = referenceView.bounds.maxY - keyboardFrame.minY
		let inset = max(minimumInset, baseInset)
		UIView.performWithoutAnimation {
			self.referenceView?.window?.layoutIfNeeded()
		}
		UIView.animate(
			withDuration: duration,
			delay: 0,
			options: animationOptions,
			animations: { self.updateForInset(inset, base: baseInset) },
			completion: nil
		)
	}

	///
	/// **Deprecated**: Please use `updateForInset(_:, base:)` instead.
	///
	/// Refer to the documentation for `updateForInset(_:, base:)` for more info.
	///
	@available(*, deprecated, renamed: "updateForInset(_:base:)")
	@objc open func updateForInset(_ inset: CGFloat) {
		if !self.isCallingDeprecatedMethod {
			self.updateForInset(inset, base: inset)
		}
	}

	///
	/// Do the default actions when the keyboard insets change.
	///
	/// The default implementation of this method:
	/// - Updates the `scrollView`'s `contentInset.bottom` and `scrollIndicatorInsets.bottom` to that of the `inset` parameter
	/// - Sets the `constraint`'s `constant` to the `inset` parameter
	/// - Call `layoutIfNeeded` on the reference view
	///
	/// - Parameter:
	///   - inset: The current keyboard `inset`, clamped by `minimumInset`.
	///   - baseInset: The base inset before it is clamped by `minimumInset`
	///
	open func updateForInset(_ inset: CGFloat, base baseInset: CGFloat) {
		// Just to avoid the deprecation warning that would otherwise display... and it's required for backward compatibility
		self.isCallingDeprecatedMethod = true
		self.perform(#selector(NoDeprecationWarningsHelper.updateForInset(_:)), with: inset as NSNumber)
		self.isCallingDeprecatedMethod = false
		scrollView?.contentInset.bottom = inset
		scrollView?.scrollIndicatorInsets.bottom = inset
		constraint?.constant = inset
		referenceView?.layoutIfNeeded()
	}
}

@objc private final class NoDeprecationWarningsHelper: NSObject {
	@objc func updateForInset(_ inset: CGFloat) {
	}
}
