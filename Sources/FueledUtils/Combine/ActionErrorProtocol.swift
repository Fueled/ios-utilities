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

///
/// A protocol for `ActionError` for use in type constraints
///
public protocol ActionErrorProtocol: Swift.Error {
	///
	/// Type of the error associated with the action error.
	///
	associatedtype InnerError: Swift.Error

	///
	/// Whether the receiver is currently in the disabled state or not.
	///
	var isDisabled: Bool { get }

	///
	/// The error the action protocol currently have. If `nil`, the action error is considered `disabled`.
	///
	var innerError: InnerError? { get }
}

extension ActionErrorProtocol {
	public var isDisabled: Bool {
		self.innerError == nil
	}
}
