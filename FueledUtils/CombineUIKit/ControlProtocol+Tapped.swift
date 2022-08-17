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

#if canImport(UIKit) && !os(watchOS) && canImport(Combine)
import Combine

private var tapActionStorage: UInt8 = 0
private var tapActionKey: UInt8 = 0

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ControlProtocol {
	///
	/// The action to be triggered when the button is tapped.
	/// This mirrors the `pressed` property native in `ReactiveCocoa`, but uses a
	/// protocol to represents the button rather than hardcode it to classes,
	/// allowing for any `UIControl` to use this method.
	///
	public var tapped: TapAction<Self>? {
		get {
			self.tapActionStorage?.tapAction
		}
		set {
			self.tapActionStorage = nil

			if let newValue = newValue {
				let tapActionStorage = TapActionStorage(newValue)
				newValue.$isEnabled.assign(to: \.isEnabled, withoutRetaining: self)
					.store(in: &tapActionStorage.cancellables)
				if let self = self as? ControlLoadingProtocol {
					newValue.$isExecuting.sink { [weak self] in
						self?.isLoading = $0
					}
						.store(in: &tapActionStorage.cancellables)
				}
				self.removeTarget(newValue, action: TapAction<Self>.selector, for: .primaryActionTriggered)
				self.addTarget(newValue, action: TapAction<Self>.selector, for: .primaryActionTriggered)
				self.tapActionStorage = tapActionStorage
			}
		}
	}

	private var tapActionStorage: TapActionStorage<Self>? {
		get {
			objc_getAssociatedObject(self, &tapActionKey) as? TapActionStorage
		}
		set {
			objc_setAssociatedObject(self, &tapActionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private final class TapActionStorage<Control: ControlProtocol> {
	let tapAction: TapAction<Control>
	var cancellables = Set<AnyCancellable>()

	init(_ tapAction: TapAction<Control>) {
		self.tapAction = tapAction
	}
}

#endif
