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
	private var valueStorage: Value

	/// If modifying the `value`, consider that the operation might not be atomic. Consider the following examples:
	/// ```
	/// let atomicValue = AtomicValue(0)
	/// atomicValue.value = 1
	/// ```
	/// This is an atomic operation as the original value is overriden.
	/// ```
	/// let atomicValue = AtomicValue(0)
	/// atomicValue.value += 1
	/// ```
	/// This is _not_ an atomic operation, as this will be translated as:
	/// atomicValue.value = atomicValue.value + 1
	/// Resulting in the internal lock being acquired twice, resulting in potential undesired behavior.
	/// If modifying the value, `modify()` is recommended to avoid such behavior.
	public var value: Value {
		get {
			self.lock.lock()
			defer {
				self.lock.unlock()
			}
			return self.valueStorage
		}
		set {
			self.lock.lock()
			defer {
				self.lock.unlock()
			}
			self.valueStorage = newValue
		}
	}
	private let lock = Lock()

	public init(_ value: Value) {
		self.valueStorage = value
	}

	public static func .= (atomicValue: AtomicValue, value: Value) {
		atomicValue.modify { $0 = value }
	}

	public func modify<Return>(_ modify: (inout Value) -> Return) -> Return {
		self.lock.lock()
		defer {
			self.lock.unlock()
		}
		return modify(&self.valueStorage)
	}

	public func withValue<Return>(_ getter: (Value) -> Return) -> Return {
		self.lock.lock()
		defer {
			self.lock.unlock()
		}
		return getter(self.valueStorage)
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
		get {
			self.atomicValue.value
		}
		set {
			self.atomicValue.value = newValue
		}
	}

	public var projectedValue: Atomic {
		get {
			self
		}
		set {
			self = newValue
		}
	}

	public mutating func modify<Return>(_ modify: (inout Value) -> Return) -> Return {
		self.atomicValue.modify(modify)
	}

	public mutating func withValue<Return>(_ getter: (Value) -> Return) -> Return {
		self.atomicValue.withValue(getter)
	}

	public static func .= (atomicValue: inout Atomic, value: Value) {
		atomicValue.atomicValue .= value
	}
}
