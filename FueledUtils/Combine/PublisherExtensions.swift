//
//  Publisher+sink.swift
//  RPMHelpers
//
//  Created by Stéphane Copin on 1/23/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

import Combine

extension Publisher {
	public func ignoreError() -> AnyPublisher<Output, Never> {
		self.catch { _ in Empty() }.eraseToAnyPublisher()
	}

	public func sink() -> AnyCancellable {
		self.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
	}
}

extension Publisher where Failure == Never {
	public func assign<Object: AnyObject>(to keyPath: ReferenceWritableKeyPath<Object, Output>, withoutRetaining object: Object) -> AnyCancellable {
		sink { [weak object] in
			object?[keyPath: keyPath] = $0
		}
	}
}

extension Publisher where Output: OptionalProtocol {
	public func ignoreNil() -> AnyPublisher<Output.Wrapped, Failure> {
		self.flatMap { ($0.wrapped.map { Just($0).eraseToAnyPublisher() } ?? Empty().eraseToAnyPublisher()).setFailureType(to: Failure.self) }.eraseToAnyPublisher()
	}
}
