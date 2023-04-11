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
	public let safeAreaHeight: CGFloat
	public let backgroundColor: Color
	public let leftButton: NavigationBarButton?
	public let rightButtons: [NavigationBarButton]
	public let rightButtonsSpacing: CGFloat
	public let horizontalPadding: CGFloat
	public let bottomShadow: NavigationBarShadow?
	public let statusBarBackgroundColor: Color
	public let onTapTitle: NavigationActionHandler?

	@Published public var title: String
	@Published public var titleIcon: Image?

	public init(
		title: String = "",
		titleColor: Color = .black,
		safeAreaHeight: CGFloat = .zero,
		titleFont: Font = .system(size: 18, weight: .semibold),
		titleIcon: Image? = nil,
		backgroundColor: Color = .white,
		leftButton: NavigationBarButton? = nil,
		rightButtons: [NavigationBarButton] = [],
		rightButtonsSpacing: CGFloat = 5,
		horizontalPadding: CGFloat = 10,
		bottomShadow: NavigationBarShadow? = nil,
		statusBarBackgroundColor: Color = .clear,
		onTapTitle: NavigationActionHandler? = nil
	) {
		self.title = title
		self.titleColor = titleColor
		self.safeAreaHeight = safeAreaHeight
		self.titleFont = titleFont
		self.titleIcon = titleIcon
		self.backgroundColor = backgroundColor
		self.leftButton = leftButton
		self.rightButtons = rightButtons
		self.rightButtonsSpacing = rightButtonsSpacing
		self.horizontalPadding = horizontalPadding
		self.bottomShadow = bottomShadow
		self.statusBarBackgroundColor = statusBarBackgroundColor
		self.onTapTitle = onTapTitle
	}
}
