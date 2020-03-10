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
	///
	/// Returns the equivalent length of the string (as given by `NSString.length`) if the receiver's content was in a `NSString`.
	///
	/// Equivalent to using `(String(self) as NSString).length` or `self.utf16.count`
	///
	public var nsLength: Int {
		return (String(self) as NSString).length
	}

	///
	/// Returns `NSRange(location: 0, length: nsLength)` for usage with Objective-C APIs.
	///
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
	///
	/// Returns true if the receiver is empty or if it only contains whitespaces or newlines
	///
	public var isBlank: Bool {
		return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}
	///
	/// Returns the receiver if `isEmpty` is `false`, and `nil` if it is `true`
	///
	public var nonEmptyValue: Self? {
		return self.isEmpty ? nil : self
	}
	///
	/// Returns the receiver if `isBlank` is `false`, and `nil` if it is `true`
	///
	public var nonBlankValue: Self? {
		return self.isBlank ? nil : self
	}
}

extension String {
	///
	/// Mutating version of `self.replacingOccurrences(of:, with:, options:, range:)`
	///
	public mutating func replaceOccurrences<Target: StringProtocol, Replacement: StringProtocol>(of target: Target, with replacement: Replacement, options: String.CompareOptions = [], locale: Locale? = nil) {
		var range: Range<Index>?
		repeat {
			range = self.range(of: target, options: options, range: range.map { self.index($0.lowerBound, offsetBy: replacement.count)..<self.endIndex }, locale: locale)
			if let range = range {
				self.replaceSubrange(range, with: replacement)
			}
		} while range != nil
	}

	///
	/// Allows to get a substring from a string using an integer range.
	///
	public func substring(_ range: CountableClosedRange<Int>) -> String {
		let i = stringIndex(range.lowerBound)
		let j = stringIndex(range.upperBound)
		return String(self[i...j])
	}

	///
	/// Allows to get a substring from a string using an integer range.
	///
	public func substring(_ range: CountableRange<Int>) -> String {
		let i = stringIndex(range.lowerBound)
		let j = stringIndex(range.upperBound)
		return String(self[i..<j])
	}

	///
	/// Allows to get a substring from a string using an integer range.
	///
	public func substring(_ range: PartialRangeThrough<Int>) -> String {
		let j = stringIndex(range.upperBound)
		return String(self[...j])
	}

	///
	/// Allows to get a substring from a string using an integer range.
	///
	public func substring(_ range: PartialRangeUpTo<Int>) -> String {
		let j = stringIndex(range.upperBound)
		return String(self[..<j])
	}

	///
	/// Allows to get a substring from a string using an integer range.
	///
	public func substring(_ range: PartialRangeFrom<Int>) -> String {
		let i = stringIndex(range.lowerBound)
		return String(suffix(from: i))
	}

	///
	/// Helper function to convert an integer index (0-based) into a string index.
	///
	public func stringIndex(_ index: Int) -> Index {
		return self.index(startIndex, offsetBy: index)
	}
}

extension Optional where Wrapped: StringProtocol {
	///
	/// If the receiver is non-`nil`, returns the result of `StringProtocol.nonBlankValue.isBlank`, otherwise returns `false.
	///
	public var isBlank: Bool {
		return self.map { $0.isBlank } ?? true
	}
	///
	/// If the receiver is non-`nil`, returns the result of `StringProtocol.nonEmptyValue`, otherwise returns `false.
	///
	public var nonEmptyValue: Wrapped? {
		return self.flatMap { $0.nonEmptyValue }
	}
	///
	/// If the receiver is non-`nil`, returns the result of `StringProtocol.nonBlankValue`, otherwise returns `false.
	///
	public var nonBlankValue: Wrapped? {
		return self.flatMap { $0.nonBlankValue }
	}
}
