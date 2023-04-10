//
//  View+Shadow.swift
//  iOS_DEMO
//
//  Created by Abhishek Thapliyal on 07/04/23.
//

import SwiftUI

private struct ShadowModifier: ViewModifier {
	let shadowColor: Color
	let shadowX: CGFloat
	let shadowY: CGFloat
	let shadowRadius: CGFloat
	let backgroundColor: Color

	init(
		shadowColor: Color,
		shadowX: CGFloat,
		shadowY: CGFloat,
		shadowRadius: CGFloat,
		backgroundColor: Color = .white
	) {
		self.shadowColor = shadowColor
		self.shadowX = shadowX
		self.shadowY = shadowY
		self.shadowRadius = shadowRadius
		self.backgroundColor = backgroundColor
	}

	func body(content: Content) -> some View {
		content
			.background(
				backgroundColor
					.shadow(
						color: shadowColor,
						radius: shadowRadius,
						x: shadowX,
						y: shadowY
					)
			)
			.zIndex(1)
	}
}

@available(iOS 15.0, *)
extension View {
	func addShadow(shadow: NavigationBarShadow) -> some View {
		modifier(
			ShadowModifier(
				shadowColor: shadow.color,
				shadowX: shadow.x,
				shadowY: shadow.y,
				shadowRadius: shadow.radius,
				backgroundColor: shadow.backgroundColor
			)
		)
	}

	func bottomShadow() -> some View {
		modifier(
			ShadowModifier(
				shadowColor: Color.black.opacity(0.08),
				shadowX: 0,
				shadowY: 4,
				shadowRadius: 2
			)
		)
	}

	func topShadow() -> some View {
		modifier(
			ShadowModifier(
				shadowColor: Color.black.opacity(0.08),
				shadowX: 0,
				shadowY: -4,
				shadowRadius: 2
			)
		)
	}
}
