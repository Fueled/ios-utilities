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
#if canImport(UIKit) && !os(watchOS)
import ReactiveCocoa
import ReactiveSwift
#if canImport(FueledUtilsUIKit)
import FueledUtilsUIKit
#endif

private var tapActionStorage: UInt8 = 0
private var tapActionKey: UInt8 = 0

extension Reactive where Base: ControlProtocol {
	///
	/// The action to be triggered when the button is tapped.
	/// This mirrors the `pressed` property native in `ReactiveCocoa`, but uses a
	/// protocol to represents the button rather than hardcode it to classes,
	/// allowing for any `UIControl` to use this method.
	///
	public var tapped: ReactiveTapAction<Base>? {
		get {
			self.tapActionStorage?.tapAction
		}
		nonmutating set {
			self.tapActionStorage = nil

			if let newValue = newValue {
				let tapActionStorage = TapActionStorage(newValue)
				tapActionStorage.disposable += self.makeBindingTarget { control, isEnabled in
					control.isEnabled = isEnabled
				} <~ newValue.isEnabled
				if self.base is ControlLoadingProtocol {
					tapActionStorage.disposable += self.makeBindingTarget { control, isExecuting in
						(control as! ControlLoadingProtocol).isLoading = isExecuting
					} <~ newValue.isExecuting
				}
				self.base.removeTarget(newValue, action: ReactiveTapAction<Base>.selector, for: .primaryActionTriggered)
				self.base.addTarget(newValue, action: ReactiveTapAction<Base>.selector, for: .primaryActionTriggered)
				self.tapActionStorage = tapActionStorage
			}
		}
	}

	private var tapActionStorage: TapActionStorage<Base>? {
		get {
			objc_getAssociatedObject(self.base, &tapActionKey) as? TapActionStorage
		}
		nonmutating set {
			objc_setAssociatedObject(self.base, &tapActionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
}

private final class TapActionStorage<Control: ControlProtocol> {
	let tapAction: ReactiveTapAction<Control>
	let disposable = ScopedDisposable(CompositeDisposable())

	init(_ tapAction: ReactiveTapAction<Control>) {
		self.tapAction = tapAction
	}
}
#endif
