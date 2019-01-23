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
import Foundation
import UIKit

///
/// A button that dims a view when highlighted.
///
public final class DimmingButton: UIButton {
	///
	/// The view to dim while highlighted
	///
	/// - Note: If `dimmingView` is `nil`, the button itself is dimmed.
	///
	@IBOutlet public weak var dimmingView: UIView? {
		willSet {
			self.updateDimmedAmount(for: self.dimmingView, dimAmount: 1.0)
		}
		didSet {
			self.updateDimmedViewAmount()
		}
	}
	///
	/// The alpha to set the view to when dimmed. Defaults to `0.4`
	///
	@IBInspectable public var dimAmount: CGFloat = 0.4 {
		didSet {
			self.updateDimmedViewAmount()
		}
	}

	public override var isHighlighted: Bool {
		didSet {
			self.updateDimmedViewAmount()
		}
	}

	private func updateDimmedViewAmount() {
		self.updateDimmedAmount(for: self.dimmingView, dimAmount: self.isHighlighted ? self.dimAmount : 1.0)
	}

	private func updateDimmedAmount(for view: UIView?, dimAmount: CGFloat) {
		(view ?? self).alpha = dimAmount
	}
}
