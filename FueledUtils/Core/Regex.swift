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

///
/// `NSRegularExpression` convenience wrapper.
///
public struct Regex {
	private let implementation: NSRegularExpression

	///
	/// The pattern the regex was initialized with
	///
	var pattern: String {
		return implementation.pattern
	}
	///
	/// The options used to create the regex initially
	///
	var options: NSRegularExpression.Options {
		return implementation.options
	}

	///
	/// Create a new `Regex` with the given `pattern` and `options`.
	///
	/// - Parameters:
	///   - pattern: The pattern to create the regex with.
	///   - options: The options to use when creating the regular expression.
	///
	/// - Note: The initializer is an implicitely unwrapped optional for backward-compatibility reason, and will be made optional in a future release.
	///
	public init!(_ pattern: String, options: NSRegularExpression.Options = []) {
		guard let implementation = try? NSRegularExpression(pattern: pattern, options: options) else {
			return nil
		}
		self.implementation = implementation
	}

	///
	/// Match the regex
	///
	/// - Parameters:
	///   - pattern: The string to match the regex against.
	///   - options: The options to use when matching the regular expressiona against the given string.
	///
	public func match(_ string: String, options: NSRegularExpression.MatchingOptions = []) -> Bool {
		return implementation.numberOfMatches(in: string, options: options, range: string.nsRange) != 0
	}
}

///
/// Match a regex with a string.
///
/// - Parameters:
///   - pattern: The Regex to match the string against.
///   - string: The string to try to match against the Regex.
/// - Returns: `true` if `pattern` matches `string`, `false` otherwise.
///
public func ~= (pattern: Regex, string: String) -> Bool {
	return pattern.match(string)
}
