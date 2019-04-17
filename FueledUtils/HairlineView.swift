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
/// A view with an intrinsic content size of 1px by 1px
///
open class HairlineView: UIView {
	///
	/// Please refer to the documentation for `UIView.intrinsicContentSize`
	///
	override open var intrinsicContentSize: CGSize {
		let pixel = 1.0 / UIScreen.main.scale
		return CGSize(width: pixel, height: pixel)
	}

	///
	/// Please refer to the documentation for `UIView.backgroundColor`
	///
	override open var backgroundColor: UIColor? {
		set {
			// prevent backgroundColor becoming clearColor on parent UITableViewCell selection
			if newValue != UIColor.clear {
				super.backgroundColor = newValue
			}
		}
		get {
			return super.backgroundColor
		}
	}
}
