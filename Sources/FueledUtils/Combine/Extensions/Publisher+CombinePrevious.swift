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


public extension Publisher {
	/// A tuple type that holds the previous and current output values of a publisher.
	typealias CombinePreviousOutput = (previous: Output, current: Output)

	///
	/// Combines the previous and current output values of the publisher, starting with a nil initial value.
	///
	/// This method emits a tuple containing the previous and current values
	/// whenever the publisher emits a new value. If no previous value exists,
	/// the publisher will complete without emitting any output.
	///
	/// - Returns: An `AnyPublisher<CombinePreviousOutput, Failure>` that emits
	///   tuples of previous and current output values.
	///
	func combinePrevious() -> AnyPublisher<CombinePreviousOutput, Failure> {
		combinePreviousImplementation(nil)
	}

	///
	/// Combines the previous and current output values of the publisher, starting with a specified initial value.
	///
	/// This method allows you to track values from the very beginning,
	/// emitting a tuple of previous and current values whenever the publisher emits a new value.
	///
	/// - Parameter initial: The initial value to use as the previous output
	///   for the first emission.
	/// - Returns: An `AnyPublisher<CombinePreviousOutput, Failure>` that emits
	///   tuples of previous and current output values.
	///
	func combinePrevious(_ initial: Output) -> AnyPublisher<CombinePreviousOutput, Failure> {
		combinePreviousImplementation(initial)
	}
}

private extension Publisher {
	///
	/// The implementation for combining previous and current output values.
	///
	/// This method uses the `scan` operator to keep track of the previous
	/// and current values, returning a publisher that emits a tuple of both
	/// values whenever a new value is emitted. If the initial value is nil
	/// and there is no previous value, the publisher completes without emitting.
	///
	/// - Parameter initial: The initial value to use as the previous output.
	/// - Returns: An `AnyPublisher<CombinePreviousOutput, Failure>` that emits
	///   tuples containing the previous and current output values or completes
	///   without emitting if there is no previous value available.
	///
	func combinePreviousImplementation(_ initial: Output?) -> AnyPublisher<CombinePreviousOutput, Failure> {
		scan((Output?.none, initial)) { current, newValue in
			(current.1, newValue)
		}
		.map { previous, current -> AnyPublisher<CombinePreviousOutput, Failure> in
			if let previous {
				let output = CombinePreviousOutput(previous, current!)
				return Just(output)
					.setFailureType(to: Failure.self)
					.eraseToAnyPublisher()
			} else {
				return Empty(completeImmediately: false)
					.eraseToAnyPublisher()
			}
		}
		.switchToLatest()
		.eraseToAnyPublisher()
	}
}
