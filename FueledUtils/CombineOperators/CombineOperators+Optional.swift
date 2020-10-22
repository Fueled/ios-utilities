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

import Combine
import FueledUtils

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func >>> <CancellableCollection: RangeReplaceableCollection>(lhs: AnyCancellable?, rhs: inout CancellableCollection) where CancellableCollection.Element == AnyCancellable {
	lhs?.store(in: &rhs)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func >>> (lhs: AnyCancellable?, rhs: inout Set<AnyCancellable>) {
	lhs?.store(in: &rhs)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func >>> <CancellableCollection: RangeReplaceableCollection>(lhs: AnyCancellable, rhs: inout CancellableCollection?) where CancellableCollection.Element == AnyCancellable {
	rhs?.append(lhs)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func >>> (lhs: AnyCancellable, rhs: inout Set<AnyCancellable>?) {
	rhs?.insert(lhs)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func >>> <CancellableCollection: RangeReplaceableCollection>(lhs: AnyCancellable?, rhs: inout CancellableCollection?) where CancellableCollection.Element == AnyCancellable {
	guard let lhs = lhs else {
		return
	}
	lhs >>> rhs
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func >>> (lhs: AnyCancellable?, rhs: inout Set<AnyCancellable>?) {
	guard let lhs = lhs else {
		return
	}
	lhs >>> rhs
}
