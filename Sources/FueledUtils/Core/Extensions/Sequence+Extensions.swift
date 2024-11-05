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

extension Sequence {
	///
	/// Transforms the sequence into a dictionary grouped by the specified Key type.
	///
	/// ## Example
	///
	/// Given the following `Person` struct:
	/// ```swift
	/// struct Person {
	///   let firstName: String
	///   let lastName: String
	/// }
	/// ```
	/// This method allows to easily group a list of `Person` by their last name:
	/// ```swift
	/// let people = [Person(firstName: "Stephane", lastName: "Foo"), Person(firstName: "Leonty", lastName: "Bar"), Person(firstName: "Bastien", lastName: "Bar")]
	/// let groupedByLastNamesPeople = people.collate { $0.lastName }
	/// print(groupedByLastNamesPeople)
	/// ```
	/// This will output:
	/// ```
	/// [
	///   "Foo": [
	///     Person(firstName: "Stephane", lastName: "Foo"),
	///   ],
	///   "Bar": [
	///     Person(firstName: "Leonty", lastName: "Bar"),
	///     Person(firstName: "Bastien", lastName: "Bar"),
	///   ]
	/// ]
	/// ```
	///
	/// - Parameters:
	///   - key: The key to use for the given element of the sequence. If the key returned is `nil`,
	///     the element will be ignored and not be included in the result dictionary.
	/// - Returns: The values in the sequence grouped by keys as specified in the `key` closure.
	///
	public func collate<Key: Hashable>(_ key: (Iterator.Element) -> Key?) -> [Key: [Iterator.Element]] {
		var result: [Key: [Iterator.Element]] = [:]
		for value in self {
			if let key = key(value) {
				result[key, default: []].append(value)
			}
		}
		return result
	}

	///
	/// Split the sequence according to the given closure.
	///
	/// The sequence i
	///
	/// - Parameters:
	///   - areSeparated: The closure used to separate the list.
	///     The closure takes 2 parameters, the first is the previous element and the second is the
	///     current element. If `true` is returned to the closure, all previous elements that weren't
	///     added to the subsequence array are added to it.
	/// - Returns: An array of subsequences, split according to the given closure.
	///
	/// - Complexity: O(*n*), where *n* is the length of the sequence.
	///
	public func splitBetween(_ areSeparated: (Iterator.Element, Iterator.Element) throws -> Bool) rethrows -> [[Iterator.Element]] {
		var result: [[Iterator.Element]] = []
		var chunk: [Iterator.Element] = []
		var last: Iterator.Element?
		for element in self {
			if let last = last, try areSeparated(last, element) {
				result.append(chunk)
				chunk = []
			}
			chunk.append(element)
			last = element
		}
		if !chunk.isEmpty {
			result.append(chunk)
		}
		return result
	}
}
