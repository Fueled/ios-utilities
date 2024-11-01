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

import Foundation

extension NSDecimalNumber: @retroactive Comparable {
}

///
/// Compare 2 `NSDecimalNumber`s.
/// - Returns: `true` if the left side is lesser than the right side, `false` otherwise.
///
public func < (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
	return lhs.compare(rhs) == .orderedAscending
}

///
/// Compare 2 `NSDecimalNumber`s.
/// - Returns: `true` if the left side is lesser than or equal the right side, `false` otherwise.
///
public func <= (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
	return lhs.compare(rhs) != .orderedDescending
}

///
/// Compare 2 `NSDecimalNumber`s.
/// - Returns: `true` if the left side is greater than the right side, `false` otherwise.
///
public func > (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
	return lhs.compare(rhs) == .orderedDescending
}

///
/// Compare 2 `NSDecimalNumber`s.
/// - Returns: `true` if the left side is greater than or equal the right side, `false` otherwise.
///
public func >= (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
	return lhs.compare(rhs) != .orderedAscending
}

///
/// Multiply 2 `NSDecimalNumber`s together.
/// - Returns: The result of multiplying the left side with the right side.
///
public func * (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
	return lhs.multiplying(by: rhs)
}

///
/// Divide one `NSDecimalNumber` with another.
/// - Returns: The result of dividing the left side with the right side.
///
public func / (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
	return lhs.dividing(by: rhs)
}
