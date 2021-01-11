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
	public func ignoreRepeats(isEqual: @escaping (Output, Output) -> Bool) -> AnyPublisher<Output, Failure> {
		self.map { Optional($0) }
			.combinePrevious(nil)
			.flatMap { previous, current -> AnyPublisher<Output, Failure> in
				let current = current!
				if previous.map({ isEqual($0, current) }) ?? false {
					return Empty(completeImmediately: false)
						.eraseToAnyPublisher()
				}
				return Just(current)
					.setFailureType(to: Failure.self)
					.eraseToAnyPublisher()
			}
			.eraseToAnyPublisher()
	}
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Output: Equatable {
	public func ignoreRepeats() -> AnyPublisher<Output, Failure> {
		self.ignoreRepeats(isEqual: ==)
	}
}

#endif
