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
extension Collection {
	///
	/// **Deprecated**: Please use `getSafely(at:)` instead.
	///
	/// Refer to the documentation for `getSafely(at:)` for more info.
	///
	@available(*, deprecated, renamed: "getSafely(at:)")
	public func getSafely(_ index: Self.Index) -> Self.Iterator.Element? {
		if !self.indices.contains(index) {
			return nil
		}
		return self[index]
	}

	///
	/// Try to get the item at index `index`. If the index is out of bounds, `nil` is returned.
	///
	/// Parameter index: The index of the item to tentatively get.
	/// Returns: The element as a wrapped optional if the `index` is in the `indices` of the collection, `nil` otherwise
	///
	public func getSafely(at index: Self.Index) -> Self.Iterator.Element? {
		if !self.indices.contains(index) {
			return nil
		}
		return self[index]
	}

	///
	/// Returns a collection with same element, and information as to whether the element is the first or the last, or both.
	///
	public func withPositionInformation() -> [(element: Self.Element, isFirstElement: Bool, isLastElement: Bool)] {
		return self.enumerated().map { ($0.element, $0.offset == 0, $0.offset == self.count - 1) }
	}
}
