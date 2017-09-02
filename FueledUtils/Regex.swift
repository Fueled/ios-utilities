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

/// `NSRegularExpression` convenience wrapper.
public struct Regex {
	fileprivate let impl: NSRegularExpression

	public init(_ pattern: String, options: NSRegularExpression.Options = []) {
		impl = try! NSRegularExpression(pattern: pattern, options: options)
	}

	public func match(_ string: String, options: NSRegularExpression.MatchingOptions = []) -> Bool {
		return impl.numberOfMatches(in: string, options: options, range: string.fullRange) != 0
	}
}

public func ~= (pattern: Regex, string: String) -> Bool {
	return pattern.match(string)
}
