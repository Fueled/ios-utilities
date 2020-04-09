//
//  Subscriber+EraseToAnySubscriber.swift
//  RPMHelpers
//
//  Created by Stéphane Copin on 3/24/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

import Combine

extension Subscriber {
	public func eraseToAnySubscriber() -> AnySubscriber<Input, Failure> {
		AnySubscriber(self)
	}
}
