import UIKit

public class LabelWithTitleAdjustment: UILabel {
	@IBInspectable public var matadorLineSpacing: CGFloat = 0 {
		didSet {
			setAdjustedText(text)
		}
	}
	@IBInspectable public var matadorKerning: CGFloat = 0 {
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
		paragraphStyle.lineSpacing = self.matadorLineSpacing
		paragraphStyle.alignment = self.textAlignment
		let attributes = [
			NSParagraphStyleAttributeName: paragraphStyle,
			NSKernAttributeName: self.matadorKerning
		]
		self.attributedText = NSAttributedString(string: text, attributes: attributes)
	}
}
