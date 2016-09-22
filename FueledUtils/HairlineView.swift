import Foundation
import UIKit

open class HairlineView: UIView {
	override open var intrinsicContentSize : CGSize {
		let pixel = 1.0 / UIScreen.main.scale
		return CGSize(width: pixel, height: pixel)
	}

	// prevent backgroundColor becoming clearColor on parent UITableViewCell selection
	override open var backgroundColor: UIColor? {
		set {
			if newValue != UIColor.clear {
				super.backgroundColor = newValue
			}
		}
		get {
			return super.backgroundColor
		}
	}
}
