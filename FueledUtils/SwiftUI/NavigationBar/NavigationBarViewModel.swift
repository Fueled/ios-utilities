//
//  NavigationBarViewModel.swift
//  NationsBenefits
//
//  Created by Abhishek Thapliyal on 05/09/22.
//  Copyright © 2022 Fueled. All rights reserved.
//

import Combine
import SwiftUI

@available(iOS 15.0, *)
public final class NavigationBarViewModel: ObservableObject {
	public let titleFont: Font
	public let titleColor: Color
	public let backgroundColor: Color
	public let leftButton: NavigationBarButton?
	public let rightButtons: [NavigationBarButton]
	public let bottomShadow: NavigationBarShadow?
	public let statusBarBackgroundColor: Color
	public let onTapTitle: NavigationActionHandler?

	@Published public var title: String
	@Published public var titleIcon: Image?

	public init(
		title: String = "",
		titleColor: Color = .black,
		titleFont: Font = .system(size: 18, weight: .semibold),
		titleIcon: Image? = nil,
		backgroundColor: Color = .white,
		leftButton: NavigationBarButton? = nil,
		rightButtons: [NavigationBarButton] = [],
		bottomShadow: NavigationBarShadow? = nil,
		statusBarBackgroundColor: Color,
		onTapTitle: NavigationActionHandler? = nil
	) {
		self.title = title
		self.titleColor = titleColor
		self.titleFont = titleFont
		self.titleIcon = titleIcon
		self.backgroundColor = backgroundColor
		self.leftButton = leftButton
		self.rightButtons = rightButtons
		self.bottomShadow = bottomShadow
		self.statusBarBackgroundColor = statusBarBackgroundColor
		self.onTapTitle = onTapTitle
	}
}
