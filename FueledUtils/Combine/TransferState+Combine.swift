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

//@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
//extension TransferState {
//	public func mapPublisher<Mapped, Error: Swift.Error>(mapper: ) -> AnyPublisher<TransferState<Progress, Value>, Error> {
//		switch transferState {
//		case .loading:
//			return Just(transferState.interpolated(min: 0.0, max: 0.85).map { _ in })
//				.setFailureType(to: APIError.self)
//				.eraseToAnyPublisher()
//		case .finished(let archiveURL):
//			let destinationURL = APICharacter.localURL(coreDataCharacter)
//			return self.storeCharacterFromArchiveURL(
//				archiveURL,
//				destinationURL: destinationURL,
//				temporaryURL: temporaryURL
//			)
//			.map { $0.interpolated(min: 0.85, max: 1.0).map { _ in } }
//			.eraseToAnyPublisher()
//		}
//	}
//}

#endif
