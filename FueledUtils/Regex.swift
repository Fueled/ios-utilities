import Foundation

public struct Regex {
	private let impl: NSRegularExpression

	init(_ pattern: String, options: NSRegularExpressionOptions = []) {
		impl = try! NSRegularExpression(pattern: pattern, options: options)
	}

	func match(string: String, options: NSMatchingOptions = []) -> Bool {
		return impl.numberOfMatchesInString(string, options: options, range: string.fullRange) != 0
	}
}

public func ~= (pattern: Regex, string: String) -> Bool {
	return pattern.match(string)
}
