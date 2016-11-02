import UIKit

open class ButtonWithTitleAdjustment: UIButton {
	@IBInspectable open var adjustmentLineSpacing: CGFloat = 0 {
		didSet {
			updateAdjustedTitles()
		}
	}
	@IBInspectable open var adjustmentKerning: CGFloat = 0 {
		didSet {
			updateAdjustedTitles()
		}
	}

	open func setAdjustedTitle(_ title: String?, for state: UIControlState) {
		guard let title = title else {
			self.setAttributedTitle(nil, for: state)
			return
		}
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = self.adjustmentLineSpacing
		let titleColor = self.titleColor(for: state) ?? .black
		let attributes: [String: Any] = [
			NSParagraphStyleAttributeName: paragraphStyle,
			NSKernAttributeName: self.adjustmentKerning,
			NSForegroundColorAttributeName: titleColor
		]
		let attributedTitle = NSAttributedString(string: title, attributes: attributes)
		self.setAttributedTitle(attributedTitle, for: state)
	}

	open func updateAdjustedTitles() {
		let states: [UIControlState] = [.normal, .highlighted, .selected, .disabled, [.selected, .highlighted], [.selected, .disabled]]
		for state in states {
			let title = self.title(for: state)
			setAdjustedTitle(title, for: state)
		}
	}
}
