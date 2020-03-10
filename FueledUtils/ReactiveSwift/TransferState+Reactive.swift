//
//  LoadingStatus.swift
//  AlterraCommon
//
//  Created by Stéphane Copin on 10/18/17.
//  Copyright © 2017 Fueled. All rights reserved.
//

import ReactiveSwift

extension SignalProtocol {
	///
	/// Converts a `Signal` that has a `TransferState` value into a `Signal` only returning a value when `finished()` is received.
	///
	public func ignoreLoading<Progress, Value>() -> Signal<Value, Error>
		where Self.Value == TransferState<Progress, Value>
	{
		return self.signal.filterMap { status in
			switch status {
			case .loading:
				return nil
			case .finished(let result):
				return result
			}
		}
	}

	///
	/// Maps a `Signal` for which each value is a `TransferState` into a `TransferState` returning the mapped value.
	///
	public func mapFinished<Progress, Value, Mapped>(_ mapper: @escaping (Value) -> Mapped) -> Signal<TransferState<Progress, Mapped>, Error>
		where Self.Value == TransferState<Progress, Value>
	{
		return self.signal.map { $0.map(mapper) }
	}

	///
	/// Maps a `Signal` for which each value is a `TransferState` into a `TransferState` returning a `SignalProducer` returning the mapped value.
	///
	public func flatMapFinished<Progress, Value, Mapped>(_ mapper: @escaping (Value) -> SignalProducer<Mapped, Error>) -> Signal<TransferState<Progress, Mapped>, Error>
		where Self.Value == TransferState<Progress, Value>
	{
		return self.signal.flatMap(.latest) { status -> Signal<TransferState<Progress, Mapped>, Error> in
			return Signal { observer, disposable in
				switch status {
				case .loading(let progress):
					observer.send(value: .loading(progress))
				case .finished(let result):
					disposable += mapper(result)
						.map { .finished($0) }
						.start(observer)
				}
			}
		}
	}
}

extension SignalProducerProtocol {
	///
	/// Converts a `SignalProducer` that has a `TransferState` value into a `SignalProducer` only returning a value when `finished()` is received.
	///
	public func ignoreLoading<Progress, Value>() -> SignalProducer<Value, Error>
		where Self.Value == TransferState<Progress, Value>
	{
		return self.producer.lift { $0.ignoreLoading() }
	}

	///
	/// Maps a `SignalProducer` for which each value is a `TransferState` into a `TransferState` returning the mapped value.
	///
	public func mapFinished<Progress, Value, Mapped>(_ mapper: @escaping (Value) -> Mapped) -> SignalProducer<TransferState<Progress, Mapped>, Error>
		where Self.Value == TransferState<Progress, Value>
	{
		return self.producer.lift { $0.mapFinished(mapper) }
	}

	///
	/// Maps a `SignalProducer` for which each value is a `TransferState` into a `TransferState` returning a `SignalProducer` returning the mapped value.
	///
	public func flatMapFinished<Progress, Value, Mapped>(_ mapper: @escaping (Value) -> SignalProducer<Mapped, Error>) -> SignalProducer<TransferState<Progress, Mapped>, Error>
		where Self.Value == TransferState<Progress, Value>
	{
		return self.producer.lift { $0.flatMapFinished(mapper) }
	}
}
