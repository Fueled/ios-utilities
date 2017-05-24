import UIKit
import Foundation

public final class DecoratingTextFieldDelegate: NSObject {
	public let pattern: String
	public let patternPlaceholderForDataCharacter: Character
	public let isDataCharacter: (Character) -> Bool

	public init(
		pattern: String,
		patternPlaceholderForDataCharacter: Character,
		isDataCharacter: @escaping (Character) -> Bool)
	{
		self.pattern = pattern
		self.patternPlaceholderForDataCharacter = patternPlaceholderForDataCharacter
		self.isDataCharacter = isDataCharacter
		super.init()
	}

	public func decorateString(_ dataString: String) -> String {
		var res = ""
		let dataChars = dataString.characters
		var dataIndex = dataChars.startIndex
		for patternChar in pattern.characters {
			if patternChar == patternPlaceholderForDataCharacter {
				if dataIndex == dataChars.endIndex {
					return res
				}
				res += String(dataChars[dataIndex])
				dataIndex = dataChars.index(after: dataIndex)
			} else {
				res += String(patternChar)
			}
		}
		return res
	}

	public func undecorateString(_ decoratedString: String) -> String {
		var res = ""
		for decoChar in decoratedString.characters {
			if isDataCharacter(decoChar) {
				res += String(decoChar)
			}
		}
		return res
	}

	fileprivate func convertDecoRange(_ decoRange: NSRange, fromDecoratedString decoratedString: String) -> NSRange {
		let decoPrefix = (decoratedString as NSString).substring(to: decoRange.location)
		let decoSubstring = (decoratedString as NSString).substring(with: decoRange)
		let dataPrefix = self.undecorateString(decoPrefix)
		let dataSubstring = self.undecorateString(decoSubstring)
		return NSRange(location: dataPrefix.nsLength, length: dataSubstring.nsLength)
	}

	fileprivate func convertDataLocation(_ dataLocation: Int, toDecoratedString decoratedString: String) -> Int {
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
	public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let decoString = textField.text ?? ""
		let decoReplacement = string
		let dataString = undecorateString(decoString)
		let dataReplacement = undecorateString(decoReplacement)
		var dataRange = convertDecoRange(range, fromDecoratedString: decoString)
		if range.length > 0 && decoReplacement.isEmpty && dataRange.length == 0 && dataRange.location > 0 {
			// probably backspace was hit with no data characters selected or prior to cursor
			// in this case we grow data range by one prior data character (if possible)
			// in order to erase that data character
			dataRange = (dataString as NSString).rangeOfComposedCharacterSequence(at: dataRange.location - 1)
		}

		let newDataString = (dataString as NSString).replacingCharacters(in: dataRange, with: dataReplacement)
		let newDecoString = decorateString(newDataString)
		textField.text = newDecoString
		textField.sendActions(for: .editingChanged)

		let newDataLocation = dataRange.location + dataReplacement.nsLength
		let newDecoLocation = convertDataLocation(newDataLocation, toDecoratedString: newDecoString)
		if let selPos = textField.position(from: textField.beginningOfDocument, offset: newDecoLocation) {
			textField.selectedTextRange = textField.textRange(from: selPos, to: selPos)
		}
		return false
	}
}
