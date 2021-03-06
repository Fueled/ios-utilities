// Copyright © 2020, Fueled Digital Media, LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import ReactiveSwift
import UIKit

extension Reactive where Base: UILabel {
	///
	/// Update the `text` property of the label with an animation.
	///
	public var animatedText: BindingTarget<String> {
		return makeBindingTarget { label, text in
			label.setText(text, animated: true)
		}
	}
	///
	/// Update the `attributedText` property of the label with an animation.
	///
	public var animatedAttributedText: BindingTarget<NSAttributedString> {
		return makeBindingTarget { label, text in
			label.setAttributedText(text, animated: true)
		}
	}
}
