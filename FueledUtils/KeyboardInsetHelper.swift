import Foundation
import UIKit

public final class KeyboardInsetHelper: NSObject {
	@IBInspectable public var baseInset: CGFloat = 0
	@IBOutlet public weak var referenceView: UIView?
	@IBOutlet public weak var scrollView: UIScrollView?
	@IBOutlet public weak var constraint: NSLayoutConstraint?

	override public func awakeFromNib() {
		super.awakeFromNib()
		let nc = NSNotificationCenter.defaultCenter()
		nc.addObserver(
			self,
			selector: #selector(handleKeyboardNotification(_:)),
			name: UIKeyboardWillShowNotification,
			object: nil)
		nc.addObserver(
			self,
			selector: #selector(handleKeyboardNotification(_:)),
			name: UIKeyboardWillHideNotification,
			object: nil)
	}

	deinit {
		let nc = NSNotificationCenter.defaultCenter()
		nc.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
		nc.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
	}

	@objc private func handleKeyboardNotification(notification: NSNotification) {
		guard let referenceView = referenceView,
			userInfo = notification.userInfo,
			curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
			duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double,
			keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue
			else { return }
		let keyboardFrame = referenceView.convertRect(keyboardFrameValue.CGRectValue(), fromView: referenceView.window)
		let curveOption = UIViewAnimationOptions(rawValue: curve << 16)
		let animationOptions = curveOption.union(.BeginFromCurrentState)
		let inset = max(baseInset, referenceView.bounds.maxY - keyboardFrame.minY)
		UIView.performWithoutAnimation {
			self.referenceView?.window?.layoutIfNeeded()
		}
		UIView.animateWithDuration(
			duration,
			delay: 0,
			options: animationOptions,
			animations: { self.updateForInset(inset) },
			completion: nil)
	}

	public func updateForInset(inset: CGFloat) {
		scrollView?.contentInset.bottom = inset
		scrollView?.scrollIndicatorInsets.bottom = inset
		constraint?.constant = inset
		referenceView?.layoutIfNeeded()
	}
}
