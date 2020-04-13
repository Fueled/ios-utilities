//
//  EdgeInsets+Zero.swift
//  RPMHelpers
//
//  Created by Stéphane Copin on 4/10/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

import SwiftUI

extension EdgeInsets {
	public static var zero: EdgeInsets {
		EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0)
	}

	public init(_ length: CGFloat) {
		self.init(top: length, leading: length, bottom: length, trailing: length)
	}

	public init(_ edges: Edge.Set, _ length: CGFloat) {
		self.init(
			top: edges.contains(.top) ? length : 0.0,
			leading: edges.contains(.leading) ? length : 0.0,
			bottom: edges.contains(.bottom) ? length : 0.0,
			trailing: edges.contains(.trailing) ? length : 0.0
		)
	}
}
