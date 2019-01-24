//
//  CoalescingAction.swift
//  FueledUtils
//
//  Created by Stéphane Copin on 4/22/16.
//  Copyright © 2016 Fueled. All rights reserved.
//

import ReactiveSwift
import Result

///
/// Similar to `Action`, except if the action is already executing, subsequent `apply()` call will not fail,
/// and will be completed with the same output when the initial executing action completes.
/// Disposing any of the `SignalProducer` returned by 'apply()` will cancel the action.
///
public class CoalescingAction<Input, Output, Error: Swift.Error>: ActionProtocol {
	public typealias OutputType = Output
	public typealias InputType = Input
	public typealias ErrorType = Error
	public typealias ApplyErrorType = Error

	private let action: Action<Input, Output, Error>
	private var observer: Signal<Output, Error>.Observer?

	private class DisposableContainer {
		private let disposable: Disposable
		private var count = Atomic(0) {
			willSet {
				if self.count.value == 0 {
					self.disposable.dispose()
				}
			}
		}

		init(_ disposable: Disposable) {
			self.disposable = disposable
		}

		func add(_ lifetime: Lifetime) {
			lifetime.observeEnded {
				self.count.value -= 1
			}
		}
	}
	private var disposableContainer: DisposableContainer?

	public var isExecuting: Property<Bool> {
		return self.action.isExecuting
	}

	public let isEnabled = Property<Bool>(value: true)

	public var events: Signal<Signal<Output, Error>.Event, NoError> {
		return self.action.events
	}

	public var values: Signal<Output, NoError> {
		return self.action.values
	}

	public var errors: Signal<Error, NoError> {
		return self.action.errors
	}

	public var lifetime: Lifetime {
		return self.action.lifetime
	}

	public init(execute: @escaping (Input) -> SignalProducer<Output, Error>) {
		self.action = Action(execute: execute)
	}

	public func apply(_ input: Input) -> SignalProducer<Output, Error> {
		if self.isExecuting.value {
			return SignalProducer { [disposableContainer, weak self] observer, lifetime in
				disposableContainer?.add(lifetime)
				lifetime += self?.action.events.observeValues { event in
					observer.send(event)
				}
			}
		}

		return SignalProducer<Output, Error> { observer, lifetime in
			self.observer = observer
			let disposable = self.action.apply(input).flatMapError { error in
				guard case .producerFailed(let innerError) = error else {
					return SignalProducer.empty
				}

				return SignalProducer(error: innerError)
			}.start(observer)
			let disposableContainer = DisposableContainer(disposable)
			disposableContainer.add(lifetime)
			self.disposableContainer = disposableContainer
		}
	}
}

extension CoalescingAction where Input == Void {
	public func apply() -> SignalProducer<Output, Error> {
		return self.apply(())
	}
}
