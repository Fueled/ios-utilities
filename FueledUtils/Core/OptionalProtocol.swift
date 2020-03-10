//
//  OptionalProtocol.swift
//  RPMHelpers
//
//  Created by Stéphane Copin on 3/9/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

public protocol OptionalProtocol {
	associatedtype Wrapped

	var wrapped: Wrapped? { get }
}

extension Optional: OptionalProtocol {
	public var wrapped: Wrapped? {
		self
	}
}
