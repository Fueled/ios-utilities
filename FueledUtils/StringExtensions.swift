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
}
