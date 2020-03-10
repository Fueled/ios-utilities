//
//  ForEach+IndexInfo.swift
//  RPMHelpers
//
//  Created by Stéphane Copin on 2/21/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

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
