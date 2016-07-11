import UIKit

public class ButtonWithTitleAdjustment: UIButton {
	@IBInspectable public var adjustmentLineSpacing: CGFloat = 0 {
		didSet {
			updateAdjustedTitles()
		}
	}
	@IBInspectable public var adjustmentKerning: CGFloat = 0 {
		didSet {
			updateAdjustedTitles()
		}
	}

	public func setAdjustedTitle(title: String?, forState state: UIControlState) {
		guard let title = title else {
			self.setAttributedTitle(nil, forState: state)
			return
		}
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = self.adjustmentLineSpacing
		let titleColor = self.titleColorForState(state) ?? .blackColor()
		let attributes = [
			NSParagraphStyleAttributeName: paragraphStyle,
			NSKernAttributeName: self.adjustmentKerning,
			NSForegroundColorAttributeName: titleColor
		]
		let attributedTitle = NSAttributedString(string: title, attributes: attributes)
		self.setAttributedTitle(attributedTitle, forState: state)
	}

	public func updateAdjustedTitles() {
		let states: [UIControlState] = [
			.Normal,
			.Highlighted,
			.Selected,
			.Disabled,
			[.Selected, .Highlighted],
			[.Selected, .Disabled]
		]
		for state in states {
			let title = self.titleForState(state)
			setAdjustedTitle(title, forState: state)
		}
	}
}
