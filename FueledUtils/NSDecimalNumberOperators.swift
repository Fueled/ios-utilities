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
