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
