import Foundation
import UIKit

/// A button that dims a view when highlighted.
public final class DimmingButton: UIButton {
	/// A view to dim while highlited
	@IBOutlet public weak var dimmingView: UIView?

	override public func awakeFromNib() {
		super.awakeFromNib()
		self.addTarget(self, action: #selector(DimmingButton.dim), for: .touchDown)
		self.addTarget(self, action: #selector(DimmingButton.dim), for: .touchDragEnter)
		self.addTarget(self, action: #selector(DimmingButton.undim), for: .touchDragExit)
		self.addTarget(self, action: #selector(DimmingButton.undim), for: .touchUpInside)
		self.addTarget(self, action: #selector(DimmingButton.undim), for: .touchCancel)
	}

	@objc fileprivate func dim() {
		(self.dimmingView ?? self).alpha = 0.4
	}

	@objc fileprivate func undim() {
		(self.dimmingView ?? self).alpha = 1
	}
}
