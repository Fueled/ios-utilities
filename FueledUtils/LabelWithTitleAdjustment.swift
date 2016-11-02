import UIKit

open class LabelWithTitleAdjustment: UILabel {
	@IBInspectable open var adjustmentLineSpacing: CGFloat = 0 {
		didSet {
			setAdjustedText(text)
		}
	}
	@IBInspectable open var adjustmentKerning: CGFloat = 0 {
		didSet {
			setAdjustedText(text)
		}
	}

	open func setAdjustedAttributedText(_ text: NSAttributedString?) {
		guard let text = text else {
			self.attributedText = nil
			return
		}
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = adjustmentLineSpacing
		paragraphStyle.alignment = textAlignment
		let attributedString = NSMutableAttributedString(attributedString: text)
		attributedString.addAttributes(
			[NSParagraphStyleAttributeName: paragraphStyle, NSKernAttributeName: self.adjustmentKerning],
			range: attributedString.string.fullRange
		)
		self.attributedText = attributedString
	}

	open func setAdjustedText(_ text: String?) {
		setAdjustedAttributedText(text.map { NSAttributedString(string: $0) })
	}
}
