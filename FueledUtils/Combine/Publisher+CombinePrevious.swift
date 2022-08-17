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
extension Publisher {
	public func combinePrevious() -> AnyPublisher<(previous: Output, current: Output), Failure> {
		self.combinePreviousImplementation(nil)
	}

	public func combinePrevious(_ initial: Output) -> AnyPublisher<(previous: Output, current: Output), Failure> {
		self.combinePreviousImplementation(initial)
	}

	private func combinePreviousImplementation(_ initial: Output?) -> AnyPublisher<(previous: Output, current: Output), Failure> {
		return self
			.scan((Output?.none, initial)) { current, newValue in
				(current.1, newValue)
			}
			.map { previous, current -> AnyPublisher<(previous: Output, current: Output), Failure> in
				if let previous = previous {
					return Just((previous, current!))
						.setFailureType(to: Failure.self)
						.eraseToAnyPublisher()
				} else {
					return Empty(completeImmediately: false).eraseToAnyPublisher()
				}
			}
			.switchToLatest()
			.eraseToAnyPublisher()
	}
}

#endif
