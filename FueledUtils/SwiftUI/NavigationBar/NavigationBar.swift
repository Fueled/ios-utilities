//
//  NavigationBar.swift
//  NationsBenefits
//
//  Created by Abhishek Thapliyal on 07/04/23.
//  Copyright © 2022 Fueled. All rights reserved.
//

import SwiftUI

@available(iOS 15.0, *)
public struct NavigationBar: View {
	@ObservedObject var viewModel: NavigationBarViewModel
	@Environment(\.dismiss) private var dismissView

	public init(viewModel: NavigationBarViewModel) {
		self.viewModel = viewModel
	}

	public var body: some View {
		if let bottomShadow = viewModel.bottomShadow {
			parentView
				.addShadow(shadow: bottomShadow)
		} else {
			parentView
				.background(viewModel.backgroundColor)
		}
	}

	private var parentView: some View {
		VStack(spacing: .zero) {
			viewModel.statusBarBackgroundColor
				.frame(height: viewModel.safeAreaHeight)
			HStack(spacing: .zero) {
				HStack(spacing: .zero) {
					leftButtonView
					Spacer()
				}
				.frame(maxWidth: .infinity)
				HStack(spacing: .zero) {
					Spacer()
					titleView
					Spacer()
				}
				.frame(maxWidth: .infinity)
				HStack(spacing: .zero) {
					Spacer()
					rightButtonsView
				}
				.frame(maxWidth: .infinity)
			}
			.frame(height: 44)
		}
	}
}

@available(iOS 15.0, *)
extension NavigationBar {
	private var titleView: some View {
		Text(viewModel.title)
			.minimumScaleFactor(0.4)
			.font(viewModel.titleFont)
			.foregroundColor(viewModel.titleColor)
			.multilineTextAlignment(.center)
	}

	@ViewBuilder private var leftButtonView: some View {
		if let leftButton = viewModel.leftButton {
			buttonView(model: leftButton)
				.padding(leftButton.padding.edges, leftButton.padding.length)
		}
	}

	private var rightButtonsView: some View {
		ForEach(viewModel.rightButtons) {
			buttonView(model: $0)
				.padding($0.padding.edges, $0.padding.length)
		}
	}

	private func buttonView(model: NavigationBarButton) -> some View {
		HStack(spacing: .zero) {
			if let leftIcon = model.leftIcon {
				leftIcon.icon
					.renderingMode(.template)
					.foregroundColor(leftIcon.color)
			}
			if let title = model.title {
				Text(title)
					.font(model.font)
					.foregroundColor(model.foregroundColor)
			}
			if let rightIcon = model.rightIcon {
				rightIcon.icon
					.renderingMode(.template)
					.foregroundColor(rightIcon.color)
			}
		}
		.onTapGesture(perform: model.onTap)
	}
}
