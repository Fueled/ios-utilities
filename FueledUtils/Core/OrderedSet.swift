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

// From https://github.com/apple/swift-package-manager/blob/4f69f1931b5a28bcac7a41bdb1eaddcb1223eeec/TSC/Sources/TSCBasic/OrderedSet.swift
/// An ordered set is an ordered collection of instances of `Element` in which
/// uniqueness of the objects is guaranteed.
public struct OrderedSet<E: Hashable>: Equatable, RangeReplaceableCollection {
	public typealias Element = E
	public typealias Index = Int
	public typealias Indices = Range<Int>

	private var array: [Element]
	private var set: Set<Element>

	/// Creates an empty ordered set.
	public init() {
		self.array = []
		self.set = Set()
	}

	/// Creates an ordered set with the contents of `array`.
	///
	/// If an element occurs more than once in `element`, only the first one
	/// will be included.
	public init(_ array: [Element]) {
		self.init()
		for element in array {
			self.append(element)
		}
	}

	// MARK: Working with an ordered set

	/// The number of elements the ordered set stores.
	public var count: Int {
		self.array.count
	}

	/// Returns `true` if the set is empty.
	public var isEmpty: Bool {
		self.array.isEmpty
	}

	/// Returns the contents of the set as an array.
	public var contents: [Element] {
		self.array
	}

	/// Returns `true` if the ordered set contains `member`.
	public func contains(_ member: Element) -> Bool {
		self.set.contains(member)
	}

	/// Adds an element to the ordered set.
	///
	/// If it already contains the element, then the set is unchanged.
	///
	/// - returns: True if the item was inserted.
	@discardableResult
	public mutating func append(_ newElement: Element) -> Bool {
		let inserted = self.set.insert(newElement).inserted
		if inserted {
			self.array.append(newElement)
		}
		return inserted
	}

	public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C) where C: Collection, R: RangeExpression, Element == C.Element, Index == R.Bound {
		self.array.replaceSubrange(subrange, with: newElements)
		self.set = Set(self.array)
	}

	/// Remove and return the element at the beginning of the ordered set.
	public mutating func removeFirst() -> Element {
		let firstElement = self.array.removeFirst()
		self.set.remove(firstElement)
		return firstElement
	}

	/// Remove and return the element at the end of the ordered set.
	public mutating func removeLast() -> Element {
		let lastElement = self.array.removeLast()
		self.set.remove(lastElement)
		return lastElement
	}

	/// Remove all elements.
	public mutating func removeAll(keepingCapacity keepCapacity: Bool) {
		self.array.removeAll(keepingCapacity: keepCapacity)
		self.set.removeAll(keepingCapacity: keepCapacity)
	}

	public mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
		try self.array.removeAll(where: shouldBeRemoved)
		self.set = Set(self.array)
	}

	@discardableResult
	public mutating func remove(_ member: Element) -> Element? {
		self.array.removeAll { $0 == member }
		return self.set.remove(member)
	}

	public static func == <T>(lhs: OrderedSet<T>, rhs: OrderedSet<T>) -> Bool {
		lhs.contents == rhs.contents
	}
}

extension OrderedSet: ExpressibleByArrayLiteral {
	/// Create an instance initialized with `elements`.
	///
	/// If an element occurs more than once in `element`, only the first one
	/// will be included.
	public init(arrayLiteral elements: Element...) {
		self.init(elements)
	}
}

extension OrderedSet: RandomAccessCollection {
	public var startIndex: Int {
		self.contents.startIndex
	}

	public var endIndex: Int {
		self.contents.endIndex
	}

	public subscript(index: Int) -> Element {
		self.contents[index]
	}
}

extension OrderedSet: Hashable where Element: Hashable {
}

extension OrderedSet: Codable where Element: Codable {
}
