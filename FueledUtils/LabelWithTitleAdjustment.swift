import UIKit

public class LabelWithTitleAdjustment: UILabel {
	@IBInspectable public var adjustmentLineSpacing: CGFloat = 0 {
		didSet {
			setAdjustedText(text)
		}
	}
	@IBInspectable public var adjustmentKerning: CGFloat = 0 {
		didSet {
			setAdjustedText(text)
		}
	}

	public func setAdjustedText(text: String?) {
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
		]
		self.attributedText = NSAttributedString(string: text, attributes: attributes)
	}
}
