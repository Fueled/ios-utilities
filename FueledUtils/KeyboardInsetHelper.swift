import Foundation
import UIKit

public final class KeyboardInsetHelper: NSObject {
	@IBInspectable public var baseInset: CGFloat = 0
	@IBOutlet public weak var referenceView: UIView?
	@IBOutlet public weak var scrollView: UIScrollView?
	@IBOutlet public weak var constraint: NSLayoutConstraint?

	public override init() {
		super.init()
		let nc = NotificationCenter.default
		nc.addObserver(
			self,
			selector: #selector(handleKeyboardNotification(_:)),
			name: NSNotification.Name.UIKeyboardWillShow,
			object: nil
		)
		nc.addObserver(
			self,
			selector: #selector(handleKeyboardNotification(_:)),
			name: NSNotification.Name.UIKeyboardWillHide,
			object: nil
		)
	}

	deinit {
		let nc = NotificationCenter.default
		nc.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		nc.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}

	@objc fileprivate func handleKeyboardNotification(_ notification: Notification) {
		guard let referenceView = referenceView,
			let userInfo = (notification as NSNotification).userInfo,
			let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
			let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double,
			let keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue
			else { return }
		let keyboardFrame = referenceView.convert(keyboardFrameValue.cgRectValue, from: referenceView.window)
		let curveOption = UIViewAnimationOptions(rawValue: curve << 16)
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

	public func updateForInset(_ inset: CGFloat) {
		scrollView?.contentInset.bottom = inset
		scrollView?.scrollIndicatorInsets.bottom = inset
		constraint?.constant = inset
		referenceView?.layoutIfNeeded()
	}
}
