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

extension StringProtocol {
	public var nsLength: Int {
		return (String(self) as NSString).length
	}

	@available(*, deprecated, renamed: "nsRange")
	public var fullRange: NSRange {
		return NSRange(location: 0, length: nsLength)
	}

	public var nsRange: NSRange {
		return NSRange(location: 0, length: nsLength)
	}
}

extension StringProtocol where Self.Index == String.Index {
	///
	/// Returns a URL percent-encoded as per RFC 3986 section 2.3 Unreserved Characters (January 2005)
	///
	public func urlSafeString() -> String {
		let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~")
		return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!
	}
}

extension String {
	///
	/// Mutating version of `self.replacingOccurrences(of:, with:, options:, range:)`
	///
	public mutating func replaceOccurrences<Target: StringProtocol, Replacement: StringProtocol>(of target: Target, with replacement: Replacement, options: String.CompareOptions = [], locale: Locale? = nil) {
		var range: Range<Index>?
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

	public func stringIndex(_ index: Int) -> Index {
		return self.index(startIndex, offsetBy: index)
	}
}
