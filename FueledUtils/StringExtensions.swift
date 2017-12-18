import Foundation

public extension String {
	//RFC 3986 section 2.3 Unreserved Characters (January 2005)
	public func urlSafeString() -> String {
		let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~")
		return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!
	}

	public var nsLength: Int {
		return (self as NSString).length
	}

	public var fullRange: NSRange {
		return NSRange(location: 0, length: nsLength)
	}

	public mutating func replaceOccurrences(of target: String, with replacement: String, options: String.CompareOptions = [], locale: Locale? = nil) {
		var range: Range<String.Index>?
		repeat {
			range = self.range(of: target, options: options, range: range.map { $0.lowerBound..<self.endIndex }, locale: locale)
			if let range = range {
				self.replaceSubrange(range, with: replacement)
			}
		} while range != nil
	}
	
	// 2...5
	public subscript(_ range: CountableClosedRange<Int>) -> String {
		get {
			let i = stringIndex(range.lowerBound)
			let j = stringIndex(range.upperBound)
			return String(self[i...j])
		}
	}
	
	// 2..<5
	public subscript(_ range: CountableRange<Int>) -> String {
		get {
			let i = stringIndex(range.lowerBound)
			let j = stringIndex(range.upperBound)
			return String(self[i..<j])
		}
	}
	
	// ...5
	public subscript(_ range: PartialRangeThrough<Int>) -> String {
		get {
			let j = stringIndex(range.upperBound)
			return String(prefix(through: j))
		}
	}
	
	// ..<5
	public subscript(_ range: PartialRangeUpTo<Int>) -> String {
		get {
			let j = stringIndex(range.upperBound)
			return String(prefix(upTo: j))
		}
	}
	
	// 5...
	public subscript(_ range: PartialRangeFrom<Int>) -> String {
		get {
			let i = stringIndex(range.lowerBound)
			return String(suffix(from: i))
		}
	}
	
	public func stringIndex(_ idx: Int) -> String.Index {
		return index(startIndex, offsetBy: idx)
	}
}

