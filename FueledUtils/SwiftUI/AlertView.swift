// Copyright © 2020, Fueled Digital Media, LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#if canImport(SwiftUI)
import SwiftUI

public typealias ActionHandler = () -> Void

@available(iOS 15.0, *)
public typealias AlertModel = AlertModifier.AlertModel

@available(iOS 15.0, *)
public typealias AlertButton = AlertModifier.AlertButton

@available(iOS 15.0, *)
public typealias AlertPresentationStyle = AlertModifier.PresentationStyle

@available(iOS 15.0, *)
extension View {
	public func showAlert(
		alertModel: AlertModel,
		presentationStyle: AlertPresentationStyle = .alert,
		isPresented: Binding<Bool>
	) -> some View {
		modifier(
			AlertModifier(
				alertModel: alertModel,
				presentationStyle: presentationStyle,
				isPresented: isPresented
			)
		)
	}
}

@available(iOS 15.0, *)
public struct AlertModifier: ViewModifier {
	public let alertModel: AlertModel
	public let presentationStyle: PresentationStyle

	@Binding public var isPresented: Bool

	public init(
		alertModel: AlertModel,
		presentationStyle: PresentationStyle,
		isPresented: Binding<Bool>
	) {
		self.alertModel = alertModel
		self.presentationStyle = presentationStyle
		self._isPresented = isPresented
	}

	public func body(content: Content) -> some View {
		switch presentationStyle {
		case .alert:
			showAlert(content: content)
		case .bottomSheet(let titleVisibility):
			bottomSheet(content: content, titleVisibility: titleVisibility)
		}
	}

	private func showAlert(content: Content) -> some View {
		content
			.alert(alertModel.title ?? "", isPresented: $isPresented) {
				ForEach(alertModel.buttons) { button in
					Button(button.title, action: button.action)
				}
			} message: {
				Text(alertModel.message ?? "")
			}
	}

	private func bottomSheet(content: Content, titleVisibility: Visibility = .hidden) -> some View {
		content
			.confirmationDialog(
				alertModel.title ?? "",
				isPresented: $isPresented,
				titleVisibility: titleVisibility,
				presenting: alertModel,
				actions: {
					ForEach($0.buttons) { button in
						Button(button.title, action: button.action)
					}
				},
				message: {
					if let message = $0.message {
						Text(message)
					}
				}
			)
	}
}

@available(iOS 15.0, *)
extension AlertModifier {
	public enum PresentationStyle {
		case alert
		case bottomSheet(titleVisibility: Visibility)
	}
}

@available(iOS 15.0, *)
extension AlertModifier {
	public struct AlertModel {
		public let title: String?
		public let message: String?
		public let buttons: [AlertButton]

		public init(title: String?, message: String?, buttons: [AlertButton]) {
			self.title = title
			self.message = message
			self.buttons = buttons
		}
	}

	public struct AlertButton {
		public let title: String
		public let action: ActionHandler

		public init(title: String, action: @escaping ActionHandler = {}) {
			self.title = title
			self.action = action
		}
	}
}

@available(iOS 15.0, *)
extension AlertButton: Identifiable {
	public var id: String {
		title
	}
}

#endif
