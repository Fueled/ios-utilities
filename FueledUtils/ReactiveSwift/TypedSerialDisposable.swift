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

import ReactiveSwift

///
/// A disposable that disposes of its wrapped disposable, and allows its
/// wrapped disposable to be replaced.
/// The `Inner` disposable type is fixed and cannot be changed.
///
/// - Note: This class is backed internally by a `SerialDisposable()`, so if the documentation
/// of this class differs in any way from `SerialDisposable`, please use its documentation
/// as the source of truth.
///
public final class TypedSerialDisposable<Inner: Disposable>: Disposable {
	private let internalDisposable = SerialDisposable()

	public var isDisposed: Bool {
		return self.internalDisposable.isDisposed
	}

	///
	/// The current inner disposable to dispose of.
	///
	/// Whenever this property is set (even to the same value!), the previous
	/// disposable is automatically disposed.
	///
	public var inner: Inner? {
		get {
			return self.internalDisposable.inner as? Inner
		}
		set {
			self.internalDisposable.inner = newValue
		}
	}

	///
	/// Initializes the receiver to dispose of the argument when the
	/// TypedSerialDisposable is disposed.
	///
	/// - Parameters:
	///   - disposable: Optional disposable.
	///
	public init(_ disposable: Inner? = nil) {
		self.inner = disposable
	}

	public func dispose() {
		self.internalDisposable.dispose()
	}
}

extension ScopedDisposable where Inner == TypedSerialDisposable<CompositeDisposable> {
	///
	/// Adds the right-hand-side disposable to the left-hand-side
	/// `CompositeDisposable`.
	///
	/// ````
	///  disposable += producer
	///      .filter { ... }
	///      .map    { ... }
	///      .start(observer)
	/// ````
	///
	/// - Parameters:
	///   - lhs: Disposable to add to.
	///   - rhs: Disposable to add.
	///
	/// - Returns: A `Disposable` that can be used to opaquely
	///            remove the disposable later (if desired).
	///
	@discardableResult
	public static func += (lhs: ScopedDisposable<TypedSerialDisposable<CompositeDisposable>>, rhs: Disposable?) -> Disposable? {
		return lhs.inner.inner?.add(rhs)
	}

	///
	/// Adds the right-hand-side disposable to the left-hand-side
	/// `CompositeDisposable`.
	///
	/// ````
	///  disposable += producer
	///      .filter { ... }
	///      .map    { ... }
	///      .start(observer)
	/// ````
	///
	/// - Parameters:
	///   - lhs: Disposable to add to.
	///   - rhs: Disposable to add.
	///
	/// - Returns: A `Disposable` that can be used to opaquely
	///            remove the disposable later (if desired).
	///
	@discardableResult
	public static func += (lhs: ScopedDisposable<TypedSerialDisposable<CompositeDisposable>>, rhs: @escaping () -> Void) -> Disposable? {
		return lhs.inner.inner?.add(rhs)
	}
}

extension TypedSerialDisposable where Inner == CompositeDisposable {
	///
	/// Adds the right-hand-side disposable to the left-hand-side
	/// `CompositeDisposable`.
	///
	/// ````
	///  disposable += producer
	///      .filter { ... }
	///      .map    { ... }
	///      .start(observer)
	/// ````
	///
	/// - Parameters:
	///   - lhs: Disposable to add to.
	///   - rhs: Disposable to add.
	///
	/// - Returns: A `Disposable` that can be used to opaquely
	///            remove the disposable later (if desired).
	///
	@discardableResult
	public static func += (lhs: TypedSerialDisposable<CompositeDisposable>, rhs: Disposable?) -> Disposable? {
		return lhs.inner?.add(rhs)
	}

	///
	/// Adds the right-hand-side disposable to the left-hand-side
	/// `CompositeDisposable`.
	///
	/// ````
	///  disposable += producer
	///      .filter { ... }
	///      .map    { ... }
	///      .start(observer)
	/// ````
	///
	/// - Parameters:
	///   - lhs: Disposable to add to.
	///   - rhs: Disposable to add.
	///
	/// - Returns: A `Disposable` that can be used to opaquely
	///            remove the disposable later (if desired).
	///
	@discardableResult
	public static func += (lhs: TypedSerialDisposable<CompositeDisposable>, rhs: @escaping () -> Void) -> Disposable? {
		return lhs.inner?.add(rhs)
	}
}
