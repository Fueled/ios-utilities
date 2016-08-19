import Foundation
import UIKit

public final class DimmingButton: UIButton {
	@IBOutlet public weak var dimmingView: UIView?

	override public func awakeFromNib() {
		super.awakeFromNib()
		self.addTarget(self, action: #selector(DimmingButton.dim), forControlEvents: .TouchDown)
		self.addTarget(self, action: #selector(DimmingButton.dim), forControlEvents: .TouchDragEnter)
		self.addTarget(self, action: #selector(DimmingButton.undim), forControlEvents: .TouchDragExit)
		self.addTarget(self, action: #selector(DimmingButton.undim), forControlEvents: .TouchUpInside)
		self.addTarget(self, action: #selector(DimmingButton.undim), forControlEvents: .TouchCancel)
	}

	@objc private func dim() {
		(self.dimmingView ?? self).alpha = 0.4
	}

	@objc private func undim() {
		(self.dimmingView ?? self).alpha = 1
	}
}
