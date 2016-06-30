import UIKit
import Foundation

public final class DecoratingTextFieldDelegate: NSObject {
	public weak var textField: UITextField?
	public let pattern: String
	public let patternPlaceholderForDataCharacter: Character
	public let isDataCharacter: Character -> Bool

	public init(
		textField: UITextField,
		pattern: String,
		patternPlaceholderForDataCharacter: Character,
		isDataCharacter: Character -> Bool)
	{
		self.textField = textField
		self.pattern = pattern
		self.patternPlaceholderForDataCharacter = patternPlaceholderForDataCharacter
		self.isDataCharacter = isDataCharacter
		super.init()
		textField.delegate = self
	}

	public func decorateString(dataString: String) -> String {
		var res = ""
		let dataChars = dataString.characters
		var dataIndex = dataString.startIndex
		for patternChar in pattern.characters {
			if patternChar == patternPlaceholderForDataCharacter {
				if dataIndex == dataChars.endIndex {
					return res
				}
				res += String(dataChars[dataIndex])
				dataIndex = dataIndex.successor()
			} else {
				res += String(patternChar)
			}
		}
		return res
	}

	public func undecorateString(decoratedString: String) -> String {
		var res = ""
		for decoChar in decoratedString.characters {
			if isDataCharacter(decoChar) {
				res += String(decoChar)
			}
		}
		return res
	}

	private func convertDecoRange(decoRange: NSRange, fromDecoratedString decoratedString: String) -> NSRange {
		let decoPrefix = (decoratedString as NSString).substringToIndex(decoRange.location)
		let decoSubstring = (decoratedString as NSString).substringWithRange(decoRange)
		let dataPrefix = self.undecorateString(decoPrefix)
		let dataSubstring = self.undecorateString(decoSubstring)
		return NSRange(location: dataPrefix.nsLength, length: dataSubstring.nsLength)
	}

	private func convertDataLocation(dataLocation: Int, toDecoratedString decoratedString: String) -> Int {
		if dataLocation <= 0 {
			return dataLocation
		}
		var res = 0
		var prefixLength = dataLocation
		for decoChar in decoratedString.characters {
			let characterLength = String(decoChar).nsLength
			if isDataCharacter(decoChar) {
				if prefixLength <= 0 {
					return res
				}
				prefixLength -= characterLength
			}
			res += characterLength
		}
		return decoratedString.nsLength
	}
}

extension DecoratingTextFieldDelegate: UITextFieldDelegate {
	public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		let decoString = textField.text ?? ""
		let decoReplacement = string
		let dataString = undecorateString(decoString)
		let dataReplacement = undecorateString(decoReplacement)
		var dataRange = convertDecoRange(range, fromDecoratedString: decoString)
		if range.length > 0 && decoReplacement.isEmpty && dataRange.length == 0 && dataRange.location > 0 {
			// probably backspace was hit with no data characters selected or prior to cursor
			// in this case we grow data range by one prior data character (if possible)
			// in order to erase that data character
			dataRange = (dataString as NSString).rangeOfComposedCharacterSequenceAtIndex(dataRange.location - 1)
		}

		let newDataString = (dataString as NSString).stringByReplacingCharactersInRange(dataRange, withString: dataReplacement)
		let newDecoString = decorateString(newDataString)
		textField.text = newDecoString
		textField.sendActionsForControlEvents(.EditingChanged)

		let newDataLocation = dataRange.location + dataReplacement.nsLength
		let newDecoLocation = convertDataLocation(newDataLocation, toDecoratedString: newDecoString)
		if let selPos = textField.positionFromPosition(textField.beginningOfDocument, offset: newDecoLocation) {
			textField.selectedTextRange = textField.textRangeFromPosition(selPos, toPosition: selPos)
		}
		return false
	}
}
