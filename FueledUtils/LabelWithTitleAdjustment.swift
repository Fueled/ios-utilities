import UIKit
import Foundation

open class LabelWithTitleAdjustment: UILabel {
	@IBInspectable public var adjustmentLineSpacing: CGFloat = 0.0 {
		didSet {
			self.setAdjustedText(self.text)
		}
	}

	@IBInspectable public var adjustmentKerning: CGFloat = 0.0 {
		didSet {
			self.setAdjustedText(self.text)
		}
	}

	override open var text: String? {
		get {
			return super.text
		}
		set {
			super.text = newValue
			self.setAdjustedText(newValue)
		}
	}

	override open var attributedText: NSAttributedString? {
		get {
			return super.attributedText
		}
		set {
			super.attributedText = newValue
			self.setAdjustedAttributedText(newValue)
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setAdjustedText(self.text)
	}

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.setAdjustedText(self.text)
	}

	private func setAdjustedAttributedText(_ text: NSAttributedString?) {
		guard let text = text else {
			super.attributedText = nil
			return
		}

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineBreakMode = self.lineBreakMode
		paragraphStyle.lineSpacing = self.adjustmentLineSpacing
		paragraphStyle.alignment = self.textAlignment
		let attributedString = NSMutableAttributedString(attributedString: text)
		attributedString.addAttributes(
			[
				NSAttributedString.Key.paragraphStyle: paragraphStyle,
				NSAttributedString.Key.kern: self.adjustmentKerning,
			],
			range: NSRange(location: 0, length: attributedString.string.utf16.count))
		super.attributedText = attributedString
	}

	private func setAdjustedText(_ text: String?) {
		self.setAdjustedAttributedText(text.map { NSAttributedString(string: $0) })
	}
}
