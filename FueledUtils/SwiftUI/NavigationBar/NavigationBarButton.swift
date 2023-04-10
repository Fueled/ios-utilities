//
//  NavigationBarViewModel.swift
//  NationsBenefits
//
//  Created by Abhishek Thapliyal on 05/09/22.
//  Copyright © 2022 Fueled. All rights reserved.
//

import SwiftUI

@available(iOS 15.0, *)
public typealias NavigationActionHandler = () -> Void

@available(iOS 15.0, *)
public struct NavigationBarButton {
	public let id = UUID()
	public let title: String?
	public let font: Font
	public let foregroundColor: Color
	public let leftIcon: NavigationButtonIcon?
	public let rightIcon: NavigationButtonIcon?
	public let isDismissButton: Bool
	public let padding: (edges: Edge.Set, length: CGFloat)
	public let onTap: NavigationActionHandler

	public init(
		title: String? = nil,
		font: Font = .system(size: 16, weight: .medium),
		foregroundColor: Color = .blue,
		leftIcon: NavigationButtonIcon? = nil,
		rightIcon: NavigationButtonIcon? = nil,
		isDismissButton: Bool = false,
		padding: (edges: Edge.Set, length: CGFloat),
		onTap: @escaping NavigationActionHandler = {}
	) {
		self.title = title
		self.font = font
		self.leftIcon = leftIcon
		self.rightIcon = rightIcon
		self.foregroundColor = foregroundColor
		self.isDismissButton = isDismissButton
		self.padding = padding
		self.onTap = onTap
	}
}

@available(iOS 15.0, *)
extension NavigationBarButton {
	public struct NavigationButtonIcon {
		public let icon: Image
		public let color: Color

		public  init(icon: Image, color: Color) {
			self.icon = icon
			self.color = color
		}
	}
}

@available(iOS 15.0, *)
extension NavigationBarButton: Identifiable {
}
