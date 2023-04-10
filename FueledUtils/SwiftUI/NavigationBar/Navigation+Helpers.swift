//
//  Navigation+Helpers.swift
//  iOS_DEMO
//
//  Created by Abhishek Thapliyal on 07/04/23.
//

import SwiftUI

public var appWindows: [UIWindow]? {
	// Get connected scenes
	UIApplication.shared.connectedScenes
	// Keep only active scenes, onscreen and visible to the user
		.filter { $0.activationState == .foregroundActive }
	// Keep only the first `UIWindowScene`
		.first(where: { $0 is UIWindowScene })
	// Get its associated windows
		.flatMap({ $0 as? UIWindowScene })?.windows
}

public var keyWindow: UIWindow? {
	appWindows?
		.first(where: \.isKeyWindow)
}

// MARK: - Safe Area Insets Injecting in Environment Variables
extension EnvironmentValues {
	public var safeAreaInsets: EdgeInsets {
		self[SafeAreaInsetsKey.self]
	}
}

public struct SafeAreaInsetsKey: EnvironmentKey {
	public static var defaultValue: EdgeInsets {
		let insets = keyWindow?.safeAreaInsets ?? .zero
		return EdgeInsets(top: insets.top, leading: insets.left, bottom: insets.bottom, trailing: insets.right)
	}
}
