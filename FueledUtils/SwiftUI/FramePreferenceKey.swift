//
//  FramePreferenceKey.swift
//  RPMPlatformSupport
//
//  Created by Stéphane Copin on 1/31/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

import SwiftUI

public struct FramePreferenceKey: PreferenceKey {
	public static var defaultValue: CGRect = .zero

	public static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
		value = nextValue()
	}
}
