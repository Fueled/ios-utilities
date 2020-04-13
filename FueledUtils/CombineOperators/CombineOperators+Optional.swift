//
//  CombineOperators+Optional.swift
//  RPMHelpers
//
//  Created by Stéphane Copin on 3/26/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

import Combine
import FueledUtils

public func >>> <CancellableCollection: RangeReplaceableCollection>(lhs: AnyCancellable?, rhs: inout CancellableCollection) where CancellableCollection.Element == AnyCancellable {
	lhs?.store(in: &rhs)
}

public func >>> (lhs: AnyCancellable?, rhs: inout Set<AnyCancellable>) {
	lhs?.store(in: &rhs)
}

public func >>> <CancellableCollection: RangeReplaceableCollection>(lhs: AnyCancellable, rhs: inout CancellableCollection?) where CancellableCollection.Element == AnyCancellable {
	rhs?.append(lhs)
}

public func >>> (lhs: AnyCancellable, rhs: inout Set<AnyCancellable>?) {
	rhs?.insert(lhs)
}

public func >>> <CancellableCollection: RangeReplaceableCollection>(lhs: AnyCancellable?, rhs: inout CancellableCollection?) where CancellableCollection.Element == AnyCancellable {
	guard let lhs = lhs else {
		return
	}
	lhs >>> rhs
}

public func >>> (lhs: AnyCancellable?, rhs: inout Set<AnyCancellable>?) {
	guard let lhs = lhs else {
		return
	}
	lhs >>> rhs
}
