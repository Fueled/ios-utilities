import UIKit

open class ButtonWithTitleAdjustment: UIButton {
	@IBInspectable public var adjustmentLineSpacing: CGFloat = 0 {
		didSet {
			self.updateAdjustedTitles()
		}
	}

	@IBInspectable public var adjustmentKerning: CGFloat = 0 {
		didSet {
			self.updateAdjustedTitles()
		}
	}

	override public init(frame: CGRect) {
		super.init(frame: frame)
		self.updateAdjustedTitles()
	}

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.updateAdjustedTitles()
	}

	override open func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
		super.setTitleColor(color, for: state)
		self.updateAdjustedTitles()
	}

	override open func setTitle(_ title: String?, for state: UIControl.State) {
		super.setTitle(title, for: state)
		self.updateAdjustedTitles()
	}

	private func updateAdjustedTitles() {
		let states: [UIControl.State] = [.normal, .highlighted, .selected, .disabled, [.selected, .highlighted], [.selected, .disabled]]
		for state in states {
			self.setAdjustedTitle(self.title(for: state), for: state)
		}
	}

	private func setAdjustedTitle(_ title: String?, for state: UIControl.State) {
		let adjustedString = title.map { title -> NSAttributedString in
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = self.adjustmentLineSpacing
			var attributes: [NSAttributedString.Key: Any] = [
				NSAttributedString.Key.paragraphStyle: paragraphStyle,
				NSAttributedString.Key.kern: self.adjustmentKerning,
			]
			if let titleColor = self.titleColor(for: state) {
				attributes[NSAttributedString.Key.foregroundColor] = titleColor
			}
			return NSAttributedString(string: title, attributes: attributes)
		}
		self.setAttributedTitle(adjustedString, for: state)
	}
}
