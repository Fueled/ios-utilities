//
//  NavigationBarShadow.swift
//  iOS_DEMO
//
//  Created by Abhishek Thapliyal on 07/04/23.
//

import SwiftUI

@available(iOS 15.0, *)
public struct NavigationBarShadow {
	public let color: Color
	public let x: CGFloat
	public let y: CGFloat
	public let radius: CGFloat
	public let backgroundColor: Color

	public init(
		color: Color = .black.opacity(0.08),
		x: CGFloat = .zero,
		y: CGFloat = 4,
		radius: CGFloat = 2,
		backgroundColor: Color = .blue
	) {
		self.color = color
		self.x = x
		self.y = y
		self.radius = radius
		self.backgroundColor = backgroundColor
	}
}
