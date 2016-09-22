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

	open func setAdjustedText(_ text: String?) {
		guard let text = text else {
			self.attributedText = nil
			return
		}
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = self.adjustmentLineSpacing
		paragraphStyle.alignment = self.textAlignment
		let attributes = [
			NSParagraphStyleAttributeName: paragraphStyle,
			NSKernAttributeName: self.adjustmentKerning
		] as [String : Any]
		self.attributedText = NSAttributedString(string: text, attributes: attributes)
	}
}
