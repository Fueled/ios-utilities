//
//  CurrentValuePublisher.swift
//  RPMHelpers
//
//  Created by Stéphane Copin on 3/24/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

import Combine

///
/// A type-erasing current value publisher.
///
/// Use an `AnyCurrentValuePublisher` to wrap an existing current value publisher whose details you don’t want to expose.
/// For example, this is useful if you want to use a `CurrentValueSubject` internally, but don't want to expose the setter/its send() method
///
public struct AnyCurrentValuePublisher<Output, Failure: Swift.Error>: CurrentValuePublisher {
	private let valueGetter: () -> Output
	private let receiveSubcriberClosure: (AnySubscriber<Output, Failure>) -> Void

	public var value: Output {
		self.valueGetter()
	}

	public init(_ value: Output) {
		self.valueGetter = { value }
		self.receiveSubcriberClosure = { _ = $0.receive(value) }
	}

	public init<CurrentValuePublisher: FueledUtils.CurrentValuePublisher>(_ publisher: CurrentValuePublisher) where CurrentValuePublisher.Output == Output, CurrentValuePublisher.Failure == Failure {
		self.valueGetter = { publisher.value }
		self.receiveSubcriberClosure = { publisher.receive(subscriber: $0) }
	}

	public func receive<Subscriber: Combine.Subscriber>(subscriber: Subscriber) where Subscriber.Input == Output, Subscriber.Failure == Failure {
		self.receiveSubcriberClosure(subscriber.eraseToAnySubscriber())
	}
}

extension CurrentValuePublisher {
	public func eraseToAnyCurrentValuePublisher() -> AnyCurrentValuePublisher<Output, Failure> {
		AnyCurrentValuePublisher(self)
	}
}

///
/// A publisher that also stores the last value it sent
///
public protocol CurrentValuePublisher: Publisher {
	var value: Output { get }
}

extension CurrentValueSubject: CurrentValuePublisher {
}
