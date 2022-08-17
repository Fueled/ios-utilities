// Copyright © 2020, Fueled Digital Media, LLC
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

#if canImport(Combine)
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ObservableObject where Self.ObjectWillChangePublisher == ObservableObjectPublisher {
	// Perform a one-way link, where the receiver will listen for changes on the object and automatically trigger its `objectWillChange` publisher
	public func link<Object: ObservableObject>(to object: Object) {
		object.objectWillChange.subscribe(
			AnySubscriber(
				receiveValue: { [weak self] _ in
					self?.objectWillChange.send()
					return .unlimited
				}
			)
		)
	}

	public func link<ObjectCollection: Collection>(to objects: ObjectCollection) where ObjectCollection.Element: ObservableObject {
		objects.forEach(self.link(to:))
	}

	public func link<Publisher: Combine.Publisher>(to publisher: Publisher) where Publisher.Output: ObservableObject {
		var cancellable: AnyCancellable?
		publisher.subscribe(
			AnySubscriber(
				receiveValue: { [weak self] object in
					_ = cancellable
					cancellable = object.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }
					return .unlimited
				}
			)
		)
	}

	public func link<Publisher: Combine.Publisher>(to publisher: Publisher) where Publisher.Output: OptionalProtocol, Publisher.Output.Wrapped: ObservableObject {
		var cancellable: AnyCancellable?
		publisher.subscribe(
			AnySubscriber(
				receiveValue: { [weak self] object in
					_ = cancellable
					cancellable = object.wrapped?.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }
					return .unlimited
				}
			)
		)
	}

	public func link<Publisher: Combine.Publisher, ObjectCollection: Collection>(to publisher: Publisher) where Publisher.Output == ObjectCollection, ObjectCollection.Element: ObservableObject {
		var cancellables = Set<AnyCancellable>()
		publisher.subscribe(
			AnySubscriber(
				receiveValue: { [weak self] objects in
					cancellables = Set()
					objects.forEach { object in
						object.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }
							.store(in: &cancellables)
					}
					return .unlimited
				}
			)
		)
	}
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ObservableObject {
	public var objectDidChange: AnyPublisher<Self.ObjectWillChangePublisher.Output, Never> {
		// The delay of 0.0 allows the will to transform into a Did, by waiting for exactly one run loop cycle
		self.objectWillChange.delay(for: 0.0, scheduler: RunLoop.current).eraseToAnyPublisher()
	}

	public var publisher: AnyPublisher<Self, Never> {
		self.objectDidChange.map { _ in self }.prepend(self).eraseToAnyPublisher()
	}
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Output: Collection, Failure == Never, Output.Element: ObservableObject {
	public func onAnyChanges() -> AnyPublisher<[Output.Element], Never> {
		self.flatMap { Publishers.CombineLatestMany($0.map { $0.publisher }) }.eraseToAnyPublisher()
	}
}

#endif
