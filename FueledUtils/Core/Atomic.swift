//
//  Atomic.swift
//  RPMHelpers
//
//  Created by Stéphane Copin on 1/16/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

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
