//
//  Publisher+IgnoreRepeats.swift
//  RPMHelpers
//
//  Created by Stéphane Copin on 3/26/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

import Combine
import FueledUtils

extension Publisher {
	public func ignoreRepeats(isEqual: @escaping (Output, Output) -> Bool) -> AnyPublisher<Output, Failure> {
		self.map { Optional($0) }
			.combinePrevious(nil)
			.flatMap { previous, current -> AnyPublisher<Output, Failure> in
				let current = current!
				if previous.map({ isEqual($0, current) }) ?? false {
					return Empty(completeImmediately: false)
						.eraseToAnyPublisher()
				}
				return Just(current)
					.setFailureType(to: Failure.self)
					.eraseToAnyPublisher()
			}
			.eraseToAnyPublisher()
	}
}

extension Publisher where Output: Equatable {
	public func ignoreRepeats() -> AnyPublisher<Output, Failure> {
		self.ignoreRepeats(isEqual: ==)
	}
}
