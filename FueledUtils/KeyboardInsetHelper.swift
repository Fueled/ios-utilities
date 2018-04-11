import Foundation
import ReactiveSwift
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
	/// This property is automatically updated based on the current inset calculated by the inset helper.
	/// It it changed right before the referenceView's is called.
	public let keyboardInset: Property<CGFloat>

	private let keyboardInsetMutable = MutableProperty<CGFloat>(0.0)

	public override init() {
		self.keyboardInset = Property(self.keyboardInsetMutable)
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

	open func updateForInset(_ inset: CGFloat) {
		scrollView?.contentInset.bottom = inset
		scrollView?.scrollIndicatorInsets.bottom = inset
		constraint?.constant = inset
		keyboardInsetMutable.value = inset
		referenceView?.layoutIfNeeded()
	}
}
