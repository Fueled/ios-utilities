//
//  Publisher+IgnoreLoading.swift
//  RPMHelpers
//
//  Created by Stéphane Copin on 3/31/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

import Combine
import FueledUtils

public protocol TransferStateProtocol {
	associatedtype Progress
	associatedtype Value

	var progress: Progress? { get }
	var value: Value? { get }
}

extension TransferState: TransferStateProtocol {
	public var progress: Progress? {
		if case .loading(let progress) = self {
			return progress
		}
		return nil
	}

	public var value: Value? {
		if case .finished(let value) = self {
			return value
		}
		return nil
	}
}

extension Publisher where Output: TransferStateProtocol {
	public func ignoreLoading() -> AnyPublisher<Output.Value, Failure> {
		self.flatMap { transferState -> AnyPublisher<Output.Value, Failure> in
			guard let value = transferState.value else {
				return Empty(completeImmediately: true)
					.eraseToAnyPublisher()
			}
			return Just(value)
				.setFailureType(to: Failure.self)
				.eraseToAnyPublisher()
		}
			.eraseToAnyPublisher()
	}
}
