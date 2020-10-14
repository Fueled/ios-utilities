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

import Combine

private var cancellablesKey: UInt8 = 0

extension CombineExtensions {
	public var cancellables: Set<AnyCancellable> {
		get {
			objc_getAssociatedObject(self.base, &cancellablesKey) as? Set<AnyCancellable> ?? {
				let cancellables = Set<AnyCancellable>()
				self.cancellables = cancellables
				return cancellables
			}()
		}
		set {
			objc_setAssociatedObject(self.base, &cancellablesKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
		}
	}
}
