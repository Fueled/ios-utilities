// Copyright © 2024 Fueled Digital Media, LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Combine

///
/// A type-erasing current value publisher.
///
/// Use an `AnyCurrentValuePublisher` to wrap an existing current value publisher whose details you don’t want to expose.
/// For example, this is useful if you want to use a `CurrentValueSubject` internally, but don't want to expose the setter/its send() method
///
public struct AnyCurrentValuePublisher<Output, Failure: Swift.Error>: CurrentValuePublisher {
	private let valueGetter: () -> Output
	private let receiveSubscriberClosure: (AnySubscriber<Output, Failure>) -> Void

	public var value: Output {
		self.valueGetter()
	}

	public init(_ value: Output) {
		self.valueGetter = { value }
		self.receiveSubscriberClosure = { _ = $0.receive(value) }
	}

	public init<Publisher: CurrentValuePublisher>(_ publisher: Publisher) where Publisher.Output == Output, Publisher.Failure == Failure {
		self.valueGetter = { publisher.value }
		self.receiveSubscriberClosure = { publisher.receive(subscriber: $0) }
	}

	public func receive<Subscriber: Combine.Subscriber>(subscriber: Subscriber) where Subscriber.Input == Output, Subscriber.Failure == Failure {
		self.receiveSubscriberClosure(subscriber.eraseToAnySubscriber())
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
