// Copyright © 2020 Fueled Digital Media, LLC
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

#if canImport(Combine)
import Combine
#if canImport(FueledUtilsReactiveCommon)
import Foundation
import FueledUtilsCore
import FueledUtilsReactiveCommon
#endif

private var cancellablesKey: UInt8 = 0

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CombineExtensions {
	public var cancellables: Set<AnyCancellable> {
		get {
			self.cancellablesHelper.map { Set($0.map(\.cancellable)) } ?? {
				let cancellables = Set<AnyCancellable>()
				self.cancellables = cancellables
				return cancellables
			}()
		}
		set {
			self.cancellablesHelper = newValue.map { CancellableHolder($0) }
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
			objc_getAssociatedObject(self.base, &cancellablesKey) as? [CancellableHolder]
		}
		set {
			objc_setAssociatedObject(self.base, &cancellablesKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
		}
	}
}

#endif
