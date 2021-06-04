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

import Foundation

public protocol TransferStateProtocol {
	associatedtype Progress
	associatedtype Value

	var progress: Progress? { get }
	var value: Value? { get }
}

///
/// Represents a transfer state, either loading or finished.
/// This is useful to represent a transfer state in percentage or bytes uploaded for example.
///
/// It is recommended to define a `typealias` corresponding to your use case that specify at least the `Progress` type, for example:
/// ```swift
/// typealias DownloadState<Value> = TransferState<Double, Value>
/// ```
/// or
/// ```swift
/// typealias DownloadState<Value> = TransferState<(uploadedBytes: UInt64, totalBytes: UInt64)?, Value>
/// ```
/// Nothing prevents you to also include the `Value` type in the `typealias`, if possible for your use case.
///
public enum TransferState<Progress, Value>: TransferStateProtocol {
	///
	/// Represents a `loading` state.
	///
	case loading(Progress)
	///
	/// Represents a `finished` state.
	///
	case finished(Value)

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

extension TransferStateProtocol {
	///
	/// Map a `TransferState` finishing with one `Value` into another, mapping it with the given closure.
	///
	/// - Parameters:
	///   - mapper: Mapper closure how to map the initial value to the mapped value.
	/// - Returns: A `TransferState` with the mapped value as mapped by the given closure.
	///
	public func map<Mapped>(_ mapper: (Value) throws -> Mapped) rethrows -> TransferState<Progress, Mapped> {
		if let progress = self.progress {
			return .loading(progress)
		}
		return .finished(try mapper(self.value!))
	}
}

extension TransferStateProtocol where Progress: Numeric {
	public func interpolated(min: Progress, max: Progress) -> TransferState<Progress, Value> {
		if let progress = self.progress {
			return .loading(progress * (max - min) + min)
		}
		return .finished(self.value!)
	}
}
