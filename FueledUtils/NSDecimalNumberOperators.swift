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
import Foundation

extension NSDecimalNumber: Comparable {
}

public func < (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
	return lhs.compare(rhs) == .orderedAscending
}

public func <= (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
	let result = lhs.compare(rhs)
	return result == .orderedAscending || result == .orderedSame
}

public func > (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
	return lhs.compare(rhs) == .orderedDescending
}

public func >= (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
	let result = lhs.compare(rhs)
	return result == .orderedDescending || result == .orderedSame
}

public func * (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
	return lhs.multiplying(by: rhs)
}

public func / (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
	return lhs.dividing(by: rhs)
}
