import Foundation

public extension String {
	//RFC 3986 section 2.3 Unreserved Characters (January 2005)
	public func urlSafeString() -> String {
		let allowedCharacters = NSCharacterSet(charactersInString: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~")
		return self.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)!
	}

	public var fullRange: NSRange {
		return NSRange(location: 0, length: (self as NSString).length)
	}
}
