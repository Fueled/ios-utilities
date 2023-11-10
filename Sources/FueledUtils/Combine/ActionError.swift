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

#if canImport(FueledUtilsReactiveCommon)
import FueledUtilsReactiveCommon
#endif

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public enum ActionError<Error: Swift.Error>: Swift.Error {
	case disabled
	case failure(Error)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ActionError: ActionErrorProtocol {
	public var innerError: Error? {
		if case .failure(let error) = self {
			return error
		}
		return nil
	}
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ActionError {
	public func map<NewError: Swift.Error>(_ mapper: (InnerError) -> NewError) -> ActionError<NewError> {
		if let innerError = self.innerError {
			return .failure(mapper(innerError))
		}
		return .disabled
	}
}
