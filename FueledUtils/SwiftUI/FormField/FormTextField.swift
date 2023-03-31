//
//  FormTextField.swift
//  iOS_DEMO
//
//  Created by Abhishek Thapliyal on 27/03/23.
//

import SwiftUI

typealias ViewResultHandler = () -> any View

@available(iOS 15.0, *)
public struct FormTextField: View {
	@FocusState public var focusField: FormFocusField?
	@ObservedObject public var viewModel: FormFieldViewModel

	public init(focusField: FocusState<FormFocusField?>, viewModel: FormFieldViewModel) {
		self.viewModel = viewModel
		self._focusField = focusField
	}

	public var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			parentView
			errorView
		}
	}

	private var parentView: some View {
		ZStack(alignment: .leading) {
			placeHolderView
			textFieldView
		}
		.padding(.vertical, 15)
		.padding(.horizontal, 12)
		.overlay(overlayView)
		.onChange(of: focusField) { focusField in
			if focusField == viewModel.focusField {
				viewModel.fieldState = .active
			}
		}
	}

	@ViewBuilder private var placeHolderView: some View {
		if viewModel.inputText.isEmpty {
			Text(viewModel.placeHolder.title)
				.font(viewModel.placeHolder.font)
				.foregroundColor(viewModel.placeHolder.color)
		}
	}

	private var overlayView: some View {
		RoundedRectangle(cornerRadius: viewModel.boxDecoration.cornerRadius)
			.stroke(
				viewModel.borderColor,
				lineWidth: viewModel.borderWidth
			)
	}

	private var textFieldView: some View {
		TextField("", text: $viewModel.inputText)
			.font(viewModel.textDecoration.font)
			.foregroundColor(viewModel.textDecoration.color)
			.focused($focusField, equals: viewModel.focusField)
			.keyboardType(viewModel.inputFormat.keyboardType)
			.autocorrectionDisabled(!viewModel.inputFormat.enableAutocorrection)
			.textInputAutocapitalization(viewModel.inputFormat.autocapitalization)
			.onSubmit {
				viewModel.onSubmit.send()
			}
	}

	@ViewBuilder private var errorView: some View {
		if viewModel.fieldState == .error {
			HStack(spacing: 8) {
				Image(systemName: viewModel.errorDecoration.icon)
					.frame(width: 15, height: 15)
				Text(viewModel.errorDecoration.title)
					.font(viewModel.textDecoration.font)
			}
			.foregroundColor(viewModel.errorDecoration.color)
		}
	}
}

@available(iOS 15.0, *)
extension FormTextField {
	public enum VicinityViewType {
		case suffix
		case prefix
	}

	public struct VicinityView {
		public let view: any View
		public let position: VicinityViewType
	}
}

@available(iOS 15.0, *)
extension View {
	public func logger(_ items: Any..., separator: String = " ", terminator: String = "\n") -> some View {
		print(items, separator: separator, terminator: terminator)
		return self
	}
}
