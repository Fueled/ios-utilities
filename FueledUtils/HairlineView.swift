import Foundation
import UIKit

public class HairlineView: UIView {
	override public func intrinsicContentSize() -> CGSize {
		let pixel = 1.0 / UIScreen.mainScreen().scale
		return CGSize(width: pixel, height: pixel)
	}

	// prevent backgroundColor becoming clearColor on parent UITableViewCell selection
	override public var backgroundColor: UIColor? {
		set {
			if newValue != UIColor.clearColor() {
				super.backgroundColor = newValue
			}
		}
		get {
			return super.backgroundColor
		}
	}
}
