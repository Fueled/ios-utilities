//
//  View+AnyView.swift
//  RPMHelpers
//
//  Created by Stéphane Copin on 1/27/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

import SwiftUI

extension View {
	public func eraseToAnyView() -> AnyView {
		AnyView(self)
	}
}
