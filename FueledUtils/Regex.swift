import Foundation

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
