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

import Combine

extension Publisher {
	public func ignoreError() -> AnyPublisher<Output, Never> {
		self.catch { _ in Empty() }.eraseToAnyPublisher()
	}

	public func sink() -> AnyCancellable {
		self.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
	}
}

extension Publisher where Failure == Never {
	public func assign<Object: AnyObject>(to keyPath: ReferenceWritableKeyPath<Object, Output>, withoutRetaining object: Object) -> AnyCancellable {
		sink { [weak object] in
			object?[keyPath: keyPath] = $0
		}
	}
}

extension Publisher where Output: OptionalProtocol {
	public func ignoreNil() -> AnyPublisher<Output.Wrapped, Failure> {
		self.flatMap { ($0.wrapped.map { Just($0).eraseToAnyPublisher() } ?? Empty().eraseToAnyPublisher()).setFailureType(to: Failure.self) }.eraseToAnyPublisher()
	}
}
