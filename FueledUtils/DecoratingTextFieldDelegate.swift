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
import UIKit
import Foundation

/// Adds formatting (decoration) characters to text field's content according to a variable pattern. Can be used for
/// payment card number formatting, phone number formatting, etc.
public final class DecoratingTextFieldDelegate: NSObject {
	public let patternForDataString: (String) -> String
	public let patternPlaceholderForDataCharacter: Character
	public let isDataCharacter: (Character) -> Bool

	/**
	Intializes a delegate with a fixed pattern
	- parameters:
		- pattern: a string containing data placeholder and formatting characters.
		- patternPlaceholderForDataCharacter: a character that is not a formatting character.
		- isDataCharacter: a predicate to filter non-data characters from user's input. No matter what user tries to put \
		  into the textfield, only characters for which `isDataCharacter` returns `true` will appear in the text field.
	## Example:
	A 16-digit VISA payment card pattern might look like this `####-####-####-####` `'#'` is a
	`patternPlaceholderForDataCharacter` and '`-`' is a formatting (decorating) character.
	*/
	public convenience init(
		pattern: String,
		patternPlaceholderForDataCharacter: Character,
		isDataCharacter: @escaping (Character) -> Bool)
	{
		self.init(
			patternForDataString: { _ in pattern },
			patternPlaceholderForDataCharacter: patternPlaceholderForDataCharacter,
			isDataCharacter: isDataCharacter
		)
	}

	/**
	Intializes a delegate with a fixed pattern
	- parameters:
	- patternForDataString: `DecoratingTextFieldDelegate` will call this function passing current data string as a \
	parameter every time the data string changes, the returned pattern will subsequently be used to format the data \
	string passed.
	- patternPlaceholderForDataCharacter: a character that is not a formatting character.
	- isDataCharacter: a predicate to filter non-data characters from user's input. No matter what user tries to put \
	into the textfield, only characters for which `isDataCharacter` returns `true` will appear in the text field.
	## Example:
	A 16-digit VISA payment card pattern might look like this `####-####-####-####` `'#'` is a
	`patternPlaceholderForDataCharacter` and '`-`' is a formatting (decorating) character. Furthermore, to support \
	various kinds of payment cards a more complex behaviour may need to be implemented where the first 6 digits of a \
	payment card number will define total length and formatting pattern for any valid card number starting with those 6 \
	digits. This behaviour can be implemented by using `patternForDataString`.
	*/
	public init(
		patternForDataString: @escaping (String) -> String,
		patternPlaceholderForDataCharacter: Character,
		isDataCharacter: @escaping (Character) -> Bool)
	{
		self.patternForDataString = patternForDataString
		self.patternPlaceholderForDataCharacter = patternPlaceholderForDataCharacter
		self.isDataCharacter = isDataCharacter
		super.init()
	}

	/// - Parameters:
	///		- dataString: a string conaining only data characters (see `isDataCharacter`).
	/// - Returns: a representation of `dataString` formatted using a corresponding pattern obtained using \
	/// `patternForDataString`.
	public func decorateString(_ dataString: String) -> String {
		var res = ""
		var dataIndex = dataString.startIndex
		let pattern = self.patternForDataString(dataString)
		for patternChar in pattern {
			if patternChar == patternPlaceholderForDataCharacter {
				if dataIndex == dataString.endIndex {
					return res
				}
				res += String(dataString[dataIndex])
				dataIndex = dataString.index(after: dataIndex)
			} else {
				res += String(patternChar)
			}
		}
		return res
	}

	/// Strips formatting (decoration) characters from the input string.
	public func undecorateString(_ decoratedString: String) -> String {
		var res = ""
		for decoChar in decoratedString {
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
		for decoChar in decoratedString {
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
