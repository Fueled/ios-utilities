//
//  ObservableObject+Link.swift
//  RPMHelpers
//
//  Created by Stéphane Copin on 2/11/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

import Combine

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
							>>> cancellables
					}
					return .unlimited
				}
			)
		)
	}
}

extension ObservableObject {
	public var objectDidChange: AnyPublisher<Self.ObjectWillChangePublisher.Output, Never> {
		// The delay of 0.0 allows the will to transform into a Did, by waiting for exactly one run loop cycle
		self.objectWillChange.delay(for: 0.0, scheduler: RunLoop.current).eraseToAnyPublisher()
	}

	public var publisher: AnyPublisher<Self, Never> {
		self.objectDidChange.map { _ in self }.prepend(self).eraseToAnyPublisher()
	}
}

extension Publisher where Output: Collection, Failure == Never, Output.Element: ObservableObject {
	public func onAnyChanges() -> AnyPublisher<[Output.Element], Never> {
		self.flatMap { Publishers.CombineLatestMany($0.map { $0.publisher }) }.eraseToAnyPublisher()
	}
}
