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

import Quick
import Nimble
import FueledUtils
import XCTest

class OrderedSetSpec: QuickSpec {
	override func spec() {
		describe("OrderedSet") {
			describe("Initialization") {
				it("should initialize with no corruption") {
					expect(OrderedSet([1])) == [1]
				}
				it("should initialize with no corruption") {
					expect(OrderedSet([1, 1, 2, 2, 4, 3, 1, 2, 3])) == [1, 2, 4, 3]
				}
			}
			describe("Array operations") {
				it("should add properly") {
					var set = OrderedSet([1, 2, 3])
					set += [2, 2, 3, 3, 4, 4]
					expect(set) == [1, 2, 3, 4]
				}
				it("should remove properly") {
					var set = OrderedSet([1, 2, 3])
					set.remove(2)
					expect(set) == [1, 3]
				}
				it("should replace in a subrange properly") {
					var set = OrderedSet([1, 2, 3, 4, 5, 6, 7])
					set.replaceSubrange(1..<4, with: [3, 5, 9, 8, 1, 0])
					expect(set) == [1, 3, 9, 8, 1, 0, 5, 6, 7]
				}
			}
			describe("Set algebra") {
				it("should substract properly") {
					var set = OrderedSet([1, 2, 3])
					set.subtract([2, 3, 4])
					expect(set) == [1]
				}
				it("should form an union properly") {
					var set = OrderedSet([1, 2, 3])
					set.formUnion([3, 2, 4, 1])
					expect(set) == [1, 2, 3, 4]
				}
				it("should perform a symmetric difference properly") {
					var set: Set = [1, 2, 3, 4]
					set.formSymmetricDifference([3, 4, 5])
					expect(set) == [1, 2, 5]
				}
			}
		}
	}
}
