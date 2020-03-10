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

infix operator .=: AssignmentPrecedence

public final class AtomicValue<Value> {
	private(set) var value: Value
	private let lock = Lock()

	public init(_ value: Value) {
		self.value = value
	}

	public static func .= (atomicValue: AtomicValue, value: Value) {
		atomicValue.modify { $0 = value }
	}

	public func modify(_ modify: (inout Value) -> Void) {
		self.lock.lock()
		defer {
			self.lock.unlock()
		}
		modify(&self.value)
	}

	public func withValue(_ getter: (Value) -> Void) {
		self.lock.lock()
		defer {
			self.lock.unlock()
		}
		getter(self.value)
	}
}

@propertyWrapper
public struct Atomic<Value> {
	private let atomicValue: AtomicValue<Value>

	public init(_ value: Value) {
		self.atomicValue = AtomicValue(value)
	}

	public init(wrappedValue value: Value) {
		self.init(value)
	}

	public var wrappedValue: Value {
		self.atomicValue.value
	}

	public mutating func modify(_ modify: (inout Value) -> Void) {
		self.atomicValue.modify(modify)
	}

	public mutating func withValue(_ getter: (Value) -> Void) {
		self.atomicValue.withValue(getter)
	}

	public static func .= (atomicValue: inout Atomic, value: Value) {
		atomicValue.atomicValue .= value
	}
}
