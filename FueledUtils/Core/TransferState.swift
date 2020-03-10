//
//  LoadingStatus.swift
//  AlterraCommon
//
//  Created by Stéphane Copin on 10/18/17.
//  Copyright © 2017 Fueled. All rights reserved.
//

import Foundation

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
public enum TransferState<Progress, Value> {
	///
	/// Represents a `loading` state.
	///
	case loading(Progress)
	///
	/// Represents a `finished` state.
	///
	case finished(Value)

	///
	/// Map a `TransferState` finishing with one `Value` into another, mapping it with the given closure.
	///
	/// - Parameters:
	///   - mapper: Mapper closure how to map the initial value to the mapped value.
	/// - Returns: A `TransferState` with the mapped value as mapped by the given closure.
	///
	public func map<Mapped>(_ mapper: (Value) -> Mapped) -> TransferState<Progress, Mapped> {
		switch self {
		case .loading(let progress):
			return .loading(progress)
		case .finished(let result):
			return .finished(mapper(result))
		}
	}
}
