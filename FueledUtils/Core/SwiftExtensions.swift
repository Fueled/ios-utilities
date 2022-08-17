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

extension FloatingPoint {
	func rounded(decimalPlaces: Int, rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self {
		var this = self
		this.round(decimalPlaces: decimalPlaces, rule: rule)
		return this
	}

	mutating func round(decimalPlaces: Int, rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) {
		var offset = Self(1)
		for _ in (0..<decimalPlaces) {
			offset *= Self(10)
		}
		self *= offset
		self.round(rule)
		self /= offset
	}
}
