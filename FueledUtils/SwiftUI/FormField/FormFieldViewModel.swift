//
//  FormFieldViewModel.swift
//  iOS_DEMO
//
//  Created by Abhishek Thapliyal on 27/03/23.
//

import Combine
import SwiftUI

@available(iOS 15.0, *)
public typealias BoxDecoration = FormFieldViewModel.BoxDecoration

@available(iOS 15.0, *)

@available(iOS 15.0, *)
public typealias FieldValidation = FormFieldViewModel.FieldValidation

@available(iOS 15.0, *)
public typealias PlaceHolder = FormFieldViewModel.PlaceHolder

@available(iOS 15.0, *)
public typealias InputFormat = FormFieldViewModel.InputFormat

@available(iOS 15.0, *)
public typealias TextDecoration = FormFieldViewModel.TextDecoration

@available(iOS 15.0, *)
public typealias FieldState = FormFieldViewModel.FieldState

@available(iOS 15.0, *)
public typealias ErrorDecoration = FormFieldViewModel.ErrorDecoration

@available(iOS 15.0, *)
public final class FormFieldViewModel: ObservableObject {
	public let placeHolder: PlaceHolder
	public let textDecoration: TextDecoration
	public let inputFormat: InputFormat
	public let boxDecoration: BoxDecoration
	public let fieldValidation: FieldValidation
	public let errorDecoration: ErrorDecoration
	public let focusField: FormFocusField
	public let onSubmit = PassthroughSubject<Void, Never>()

	@Published public var inputText: String = ""
	@Published public var fieldState: FieldState = .inactive

	public init(
		boxDecoration: BoxDecoration,
		fieldValidation: FieldValidation,
		placeHolder: PlaceHolder,
		inputFormat: InputFormat,
		textDecoration: TextDecoration,
		errorDecoration: ErrorDecoration,
		focusField: FormFocusField
	) {
		self.boxDecoration = boxDecoration
		self.fieldValidation = fieldValidation
		self.placeHolder = placeHolder
		self.inputFormat = inputFormat
		self.textDecoration = textDecoration
		self.errorDecoration = errorDecoration
		self.focusField = focusField
	}
}

@available(iOS 15.0, *)
extension FormFieldViewModel {
	public enum FieldState {
		case active
		case inactive
		case error
	}

	public struct InputFormat {
		public let keyboardType: UIKeyboardType
		public let fieldType: UITextContentType
		public let enableAutocorrection: Bool
		public let autocapitalization: TextInputAutocapitalization

		public init(keyboardType: UIKeyboardType, fieldType: UITextContentType, enableAutocorrection: Bool, autocapitalization: TextInputAutocapitalization) {
			self.keyboardType = keyboardType
			self.fieldType = fieldType
			self.enableAutocorrection = enableAutocorrection
			self.autocapitalization = autocapitalization
		}
	}

	public struct BoxDecoration {
		public let activeBorderColor: Color
		public let inactiveBorderColor: Color
		public let activeBorderWidth: CGFloat
		public let inactiveBorderWidth: CGFloat
		public let cornerRadius: CGFloat

		public init(activeBorderColor: Color, inactiveBorderColor: Color, activeBorderWidth: CGFloat, inactiveBorderWidth: CGFloat, cornerRadius: CGFloat) {
			self.activeBorderColor = activeBorderColor
			self.inactiveBorderColor = inactiveBorderColor
			self.activeBorderWidth = activeBorderWidth
			self.inactiveBorderWidth = inactiveBorderWidth
			self.cornerRadius = cornerRadius
		}
	}

	public struct FieldValidation {
		public let isOptional: Bool
		public let regexPattern: String
		public let isErrorViewEnabled: Bool

		public init(
			isOptional: Bool = true,
			regexPattern: String = "",
			isErrorViewEnabled: Bool = false
		) {
			self.isOptional = isOptional
			self.regexPattern = regexPattern
			self.isErrorViewEnabled = isErrorViewEnabled
		}
	}

	public struct PlaceHolder {
		public let title: String
		public let color: Color
		public let font: Font

		public init(title: String, color: Color, font: Font) {
			self.title = title
			self.color = color
			self.font = font
		}
	}

	public struct TextDecoration {
		public let font: Font
		public let color: Color

		public init(font: Font, color: Color) {
			self.font = font
			self.color = color
		}
	}

	public struct ErrorDecoration {
		public let icon: String
		public let title: String
		public let font: Font
		public let color: Color
		public let borderWidth: CGFloat

		public init(icon: String, title: String, font: Font, color: Color, borderWidth: CGFloat) {
			self.icon = icon
			self.title = title
			self.font = font
			self.color = color
			self.borderWidth = borderWidth
		}
	}
}

@available(iOS 15.0, *)
extension FormFieldViewModel {
	public var borderColor: Color {
		switch fieldState {
		case .active:
			return boxDecoration.activeBorderColor
		case .inactive:
			return boxDecoration.inactiveBorderColor
		case .error:
			return errorDecoration.color
		}
	}

	public var borderWidth: CGFloat {
		switch fieldState {
		case .active:
			return boxDecoration.activeBorderWidth
		case .inactive:
			return boxDecoration.inactiveBorderWidth
		case .error:
			return errorDecoration.borderWidth
		}
	}
}

@available(iOS 15.0, *)
extension FormFieldViewModel {
	public var isFieldValid: Bool {
		guard !fieldValidation.isOptional else {
			return true
		}
		let range = NSRange(location: 0, length: inputText.utf16.count)
		let regex = try! NSRegularExpression(pattern: fieldValidation.regexPattern)
		let isValid = regex.firstMatch(in: inputText, range: range) != nil
		return isValid
	}

	@discardableResult
	public func handleValidation() -> Bool {
		withAnimation {
			fieldState = isFieldValid ? .inactive : .error
		}
		return isFieldValid
	}
}
