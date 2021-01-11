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

import ReactiveSwift

extension SignalProtocol {
	///
	/// Converts a `Signal` that has a `TransferState` value into a `Signal` only returning a value when `finished()` is received.
	///
	public func ignoreLoading<Progress, Value>() -> Signal<Value, Error>
		where Self.Value == TransferState<Progress, Value>
	{
		return self.signal.compactMap { status in
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
