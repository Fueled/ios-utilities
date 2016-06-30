import Foundation

extension NSDecimalNumber: Comparable {
}

public func < (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
	return lhs.compare(rhs) == .OrderedAscending
}

public func <= (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
	let result = lhs.compare(rhs)
	return result == .OrderedAscending || result == .OrderedSame
}

public func > (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
	return lhs.compare(rhs) == .OrderedDescending
}

public func >= (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
	let result = lhs.compare(rhs)
	return result == .OrderedDescending || result == .OrderedSame
}

public func * (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
	return lhs.decimalNumberByMultiplyingBy(rhs)
}

public func / (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
	return lhs.decimalNumberByDividingBy(rhs)
}
