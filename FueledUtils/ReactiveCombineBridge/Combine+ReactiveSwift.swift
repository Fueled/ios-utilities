//
//  Combine+ReactiveSwift.swift
//  FueledUtils-c6ea1015
//
//  Created by Stéphane Copin on 5/12/20.
//

import Combine
import ReactiveSwift

extension Publisher {
	public var producer: SignalProducer<Output, Failure> {
		SignalProducer { observer, lifetime in
			lifetime += self.sink(
				receiveCompletion: { completion in
					switch completion {
					case .finished:
						observer.sendCompleted()
					case .failure(let error):
						observer.send(error: error)
					}
				},
				receiveValue: { value in
					observer.send(value: value)
				}
			)
		}
	}
}

extension Lifetime {
	@discardableResult
	public static func += <Cancellable: Combine.Cancellable>(lhs: Lifetime, rhs: Cancellable?) -> Disposable? {
		rhs.flatMap { lhs.observeEnded($0.cancel) }
	}
}

extension Disposable {
	public var cancellable: some Cancellable {
		DisposableCancellable(self)
	}
}

private struct DisposableCancellable<Disposable: ReactiveSwift.Disposable>: Cancellable {
	private let disposable: Disposable

	init(_ disposable: Disposable) {
		self.disposable = disposable
	}

	func cancel() {
		self.disposable.dispose()
	}
}
