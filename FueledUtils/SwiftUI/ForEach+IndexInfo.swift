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

import SwiftUI

public struct IndexInfo<Index, ID: Hashable, Object>: Identifiable {
	public let index: Index
	public let id: ID
	public let object: Object

	init(index: Index, object: Object, id: KeyPath<Object, ID>) {
		self.index = index
		self.id = object[keyPath: id]
		self.object = object
	}
}

extension IndexInfo where Object: Identifiable, ID == Object.ID {
	public init(index: Index, object: Object) {
		self.init(
			index: index,
			object: object,
			id: \.self.id
		)
	}
}

extension IndexInfo where Object: Identifiable, ID == Object {
	public init(index: Index, object: Object) {
		self.init(
			index: index,
			object: object,
			id: \.self
		)
	}
}

extension IndexInfo where Object: Hashable, ID == Object {
	public init(index: Index, object: Object) {
		self.init(
			index: index,
			object: object,
			id: \.self
		)
	}
}

extension RandomAccessCollection {
	public func withIndices<ID: Identifiable>(id: KeyPath<Element, ID>) -> [IndexInfo<Index, ID, Element>] {
		zip(self.indices, self).map { IndexInfo(index: $0, object: $1, id: id) }
	}

	public func withIndices<ID: Hashable>(id: KeyPath<Element, ID>) -> [IndexInfo<Index, ID, Element>] {
		zip(self.indices, self).map { IndexInfo(index: $0, object: $1, id: id) }
	}
}
