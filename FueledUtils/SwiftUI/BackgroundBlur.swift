//
//  BackgroundBlur.swift
//  RPMHelpers
//
//  Created by Stéphane Copin on 4/10/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

import SwiftUI

public struct BlurView: UIViewRepresentable {
	public let style: UIBlurEffect.Style

	public func makeUIView(context: Context) -> UIVisualEffectView {
		UIVisualEffectView(effect: UIBlurEffect(style: self.style))
	}

	public func updateUIView(_ visualEffectView: UIVisualEffectView, context: Context) {
		visualEffectView.effect = UIBlurEffect(style: self.style)
	}
}

extension View {
	public func backgroundBlur(style: UIBlurEffect.Style, color: Color? = nil) -> some View {
		ZStack {
			color
			BlurView(style: style)
			self
		}
	}
}
