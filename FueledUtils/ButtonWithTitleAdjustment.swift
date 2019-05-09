/*
Copyright © 2019 Fueled Digital Media, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
import UIKit

///
/// A subclass of `UIButton` allowing to easily specify line spacing and kerning.
///
/// This class exposes properties allowing to customize the title in Interface Builder.
/// Internally, this class works by setting `setAttributedTitle(_:, for:)`. **Do not use**
/// this class if you're using `setAttributedTitle(_:, for:)` anywhere.
///
open class ButtonWithTitleAdjustment: UIButton {
	///
	/// The line spacing to apply to the button's title.
	///
	/// Negative values are **unsupported**. Please refer to the documentation for `NSAttributedString.Key.lineSpacing` for more info.
	///
	@IBInspectable public var adjustmentLineSpacing: CGFloat = 0.0 {
		didSet {
			self.updateAdjustedTitles()
		}
	}

	///
	/// The kern value to apply to the button's title.
	///
	/// Please refer to the documentation for `NSAttributedString.Key.kernValue` for info about the possible values.
	///
	@IBInspectable public var adjustmentKerning: CGFloat = 0.0 {
		didSet {
			self.updateAdjustedTitles()
		}
	}

	///
	/// Please refer to the documentation for `UIButton.init(frame:)`
	///
	override public init(frame: CGRect) {
		super.init(frame: frame)
		self.updateAdjustedTitles()
	}

	///
	/// Please refer to the documentation for `UIButton.init(coder:)`
	///
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.updateAdjustedTitles()
	}

	///
	/// Please refer to the documentation for `UIButton.setTitleColor(_:, for:)`
	///
	override open func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
		super.setTitleColor(color, for: state)
		self.updateAdjustedTitles()
	}

	///
	/// Please refer to the documentation for `UIButton.setTitle(_:, for:)`
	///
	override open func setTitle(_ title: String?, for state: UIControl.State) {
		super.setTitle(title, for: state)
		self.updateAdjustedTitles()
	}

	private func updateAdjustedTitles() {
		let states: [UIControl.State] = [.normal, .focused, .highlighted, .selected, .disabled, [.selected, .highlighted], [.selected, .disabled]]
		for state in states {
			self.setAdjustedTitle(self.title(for: state), for: state)
		}
	}

	private func setAdjustedTitle(_ title: String?, for state: UIControl.State) {
		let adjustedString = title.map { title -> NSAttributedString in
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = self.adjustmentLineSpacing
			if let titleLabel = self.titleLabel {
				paragraphStyle.lineBreakMode = titleLabel.lineBreakMode
				paragraphStyle.alignment = titleLabel.textAlignment
			}
			var attributes: [NSAttributedString.Key: Any] = [
				.paragraphStyle: paragraphStyle,
				.kern: self.adjustmentKerning
			]
			if let titleColor = self.titleColor(for: state) {
				attributes[.foregroundColor] = titleColor
			}
			return NSAttributedString(string: title, attributes: attributes)
		}
		self.setAttributedTitle(adjustedString, for: state)
	}
}
