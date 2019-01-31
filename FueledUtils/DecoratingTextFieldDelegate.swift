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

///
/// Adds formatting (decoration) characters to text field's content according to a variable pattern. Can be used for
/// payment card number formatting, phone number formatting, etc.
///
public final class DecoratingTextFieldDelegate: NSObject {
	///
	/// `DecoratingTextFieldDelegate` will call this function passing current data string as a
	/// parameter every time the data string changes, the returned pattern will subsequently be used to format the data
	/// string passed.
	///
	public let patternForDataString: (String) -> String
	///
	/// A character that is not a formatting character.
	///
	public let patternPlaceholderForDataCharacter: Character
	///
	/// A predicate to filter non-data characters from user's input. No matter what user tries to put
	/// into the textfield, only characters for which `isDataCharacter` returns `true` will appear in the text field.
	///
	public let isDataCharacter: (Character) -> Bool

	///
	/// Initializes a delegate with a fixed pattern
	/// - Parameters:
	///	  - pattern: A string containing data placeholder and formatting characters.
	///	  - patternPlaceholderForDataCharacter: A character that is not a formatting character.
	///	  - isDataCharacter: A predicate to filter non-data characters from user's input. No matter what user tries to put
	///	    into the textfield, only characters for which `isDataCharacter` returns `true` will appear in the text field.
	///
	/// ## Example:
	/// A 16-digit VISA payment card pattern might look like this `####-####-####-####` `'#'` is a
	/// `patternPlaceholderForDataCharacter` and '`-`' is a formatting (decorating) character.
	///
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

	///
	/// Intializes a delegate with a fixed pattern
	///
	/// - Parameters:
	///   - patternForDataString: `DecoratingTextFieldDelegate` will call this function passing current data string as a
	/// parameter every time the data string changes, the returned pattern will subsequently be used to format the data
	/// string passed.
	///   - patternPlaceholderForDataCharacter: A character that is not a formatting character.
	///   - isDataCharacter: A predicate to filter non-data characters from user's input. No matter what user tries to put
	/// into the textfield, only characters for which `isDataCharacter` returns `true` will appear in the text field.
	///
	/// ## Example:
	/// A 16-digit VISA payment card pattern might look like this `####-####-####-####` `'#'` is a
	/// `patternPlaceholderForDataCharacter` and '`-`' is a formatting (decorating) character. Furthermore, to support
	/// various kinds of payment cards a more complex behaviour may need to be implemented where the first 6 digits of a
	/// payment card number will define total length and formatting pattern for any valid card number starting with those 6
	/// digits. This behaviour can be implemented by using `patternForDataString`.
	///
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

	///
	/// Decorate a string consisting of data characters (see `isDataCharacter`) into a string converted using `patternForDataString`
	///
	/// - Parameters:
	///		- dataString: A string containing only data characters (see `isDataCharacter`).
	///
	/// - Returns: The converted string from the input.
	///
	public func decorateString(_ dataString: String) -> String {
		var result = ""
		var dataIndex = dataString.startIndex
		let pattern = self.patternForDataString(dataString)
		for patternChar in pattern {
			if patternChar == self.patternPlaceholderForDataCharacter {
				if dataIndex == dataString.endIndex {
					return result
				}
				result += String(dataString[dataIndex])
				dataIndex = dataString.index(after: dataIndex)
			} else {
				result += String(patternChar)
			}
		}
		return result
	}

	///
	/// Strips formatting (decoration) characters from the input string, checking each character using `isDataCharacter`
	/// and removing it from the input.
	///
	/// - Parameters:
	///		- dataString: A string contained any kind of characters
	///
	/// - Returns: The undecorated string from the input.
	///
	public func undecorateString(_ decoratedString: String) -> String {
		var result = ""
		for decoratedChar in decoratedString {
			if self.isDataCharacter(decoratedChar) {
				result += String(decoratedChar)
			}
		}
		return result
	}

	fileprivate func convertDecoratedRange(_ decoratedRange: NSRange, fromDecoratedString decoratedString: String) -> NSRange {
		let decoratedPrefix = (decoratedString as NSString).substring(to: decoratedRange.location)
		let decoratedSubstring = (decoratedString as NSString).substring(with: decoratedRange)
		let dataPrefix = self.undecorateString(decoratedPrefix)
		let dataSubstring = self.undecorateString(decoratedSubstring)
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
			if self.isDataCharacter(decoChar) {
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
		let decoratedString = textField.text ?? ""
		let decoratedReplacement = string
		let dataString = undecorateString(decoratedString)
		let dataReplacement = self.undecorateString(decoratedReplacement)
		var dataRange = self.convertDecoratedRange(range, fromDecoratedString: decoratedString)
		if range.length > 0 && decoratedReplacement.isEmpty && dataRange.length == 0 && dataRange.location > 0 {
			// probably backspace was hit with no data characters selected or prior to cursor
			// in this case we grow data range by one prior data character (if possible)
			// in order to erase that data character
			dataRange = (dataString as NSString).rangeOfComposedCharacterSequence(at: dataRange.location - 1)
		}

		let newDataString = (dataString as NSString).replacingCharacters(in: dataRange, with: dataReplacement)
		let newDecoratedString = decorateString(newDataString)
		textField.text = newDecoratedString
		textField.sendActions(for: .editingChanged)

		let newDataLocation = dataRange.location + dataReplacement.nsLength
		let newDecoratedLocation = convertDataLocation(newDataLocation, toDecoratedString: newDecoratedString)
		if let selectedPos = textField.position(from: textField.beginningOfDocument, offset: newDecoratedLocation) {
			textField.selectedTextRange = textField.textRange(from: selectedPos, to: selectedPos)
		}
		return false
	}
}
