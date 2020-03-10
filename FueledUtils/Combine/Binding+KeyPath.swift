//
//  Binding+KeyPath.swift
//  RPMHelpers
//
//  Created by Stéphane Copin on 1/23/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

import SwiftUI

extension Binding {
	public init<Type>(_ object: Type, to keyPath: ReferenceWritableKeyPath<Type, Value>) {
		self.init(
			get: {
				object[keyPath: keyPath]
			},
			set: {
				object[keyPath: keyPath] = $0
			}
		)
	}
}
