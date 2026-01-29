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

extension Publishers {
	/// Combine many publishers into a single publisher
	static func CombineLatestMany<Output, Failure>(_ publishers: [AnyPublisher<Output, Failure>]) -> AnyPublisher<[Output], Failure> {
		guard !publishers.isEmpty else {
			return Just([])
				.setFailureType(to: Failure.self)
				.eraseToAnyPublisher()
		}

		let firstPublisherArray = publishers[0].map { [$0] }.eraseToAnyPublisher()
		return publishers
			.dropFirst()
			.reduce(firstPublisherArray) { combined, publisher in
				combined.combineLatest(publisher) { $0 + [$1] }.eraseToAnyPublisher()
			}
	}
}
