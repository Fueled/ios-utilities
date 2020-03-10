//
//  Lock.swift
//  RPMHelpers
//
//  Created by Stéphane Copin on 1/23/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

import Foundation

private protocol LockImplementation {
	mutating func lock()
	mutating func `try`() -> Bool
	mutating func unlock()
}

@available(iOS 10.0, *)
private struct UnfairLock: LockImplementation {
	private var unfairLock = os_unfair_lock_s()

	mutating func lock() {
		os_unfair_lock_lock(&self.unfairLock)
	}

	mutating func `try`() -> Bool {
		os_unfair_lock_trylock(&self.unfairLock)
	}

	mutating func unlock() {
		os_unfair_lock_unlock(&self.unfairLock)
	}
}

private struct PThreadMutexLock: LockImplementation {
	private var mutex = pthread_mutex_t()

	init?() {
		if pthread_mutex_init(&self.mutex, nil) != 0 {
			return nil
		}
	}

	mutating func lock() {
		pthread_mutex_lock(&self.mutex)
	}

	mutating func `try`() -> Bool {
		pthread_mutex_trylock(&self.mutex) == 0
	}

	mutating func unlock() {
		pthread_mutex_unlock(&self.mutex)
	}
}

private struct CocoaLock: LockImplementation {
	private let lockImplementation = NSLock()

	mutating func lock() {
		self.lockImplementation.lock()
	}

	mutating func `try`() -> Bool {
		self.lockImplementation.try()
	}

	mutating func unlock() {
		self.lockImplementation.unlock()
	}
}

public final class Lock {
	private var lockImplementation: LockImplementation

	public init() {
		if #available(iOS 10.0, *) {
			self.lockImplementation = UnfairLock()
		} else {
			self.lockImplementation = PThreadMutexLock() ?? CocoaLock()
		}
	}

	public func lock() {
		self.lockImplementation.lock()
	}

	public func `try`() -> Bool {
		self.lockImplementation.try()
	}

	public func unlock() {
		self.lockImplementation.unlock()
	}
}
