// Copyright © 2024 Fueled Digital Media, LLC
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

import Combine
import Foundation

nonisolated(unsafe) private var cancellablesKey: UInt8 = 0

extension CombineExtensions {
	public var cancellables: Set<AnyCancellable> {
		get {
			cancellablesHelper.map { Set($0.map(\.cancellable)) } ?? {
				let cancellables = Set<AnyCancellable>()
				self.cancellables = cancellables
				return cancellables
			}()
		}
		set {
			cancellablesHelper = newValue.map(CancellableHolder.init)
		}
	}

	private final class CancellableHolder: NSObject {
		let cancellable: AnyCancellable

		init(_ cancellable: AnyCancellable) {
			self.cancellable = cancellable
		}
	}

	private var cancellablesHelper: [CancellableHolder]? {
		get {
			objc_getAssociatedObject(base, &cancellablesKey) as? [CancellableHolder]
		}
		set {
			objc_setAssociatedObject(base, &cancellablesKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
		}
	}
}
