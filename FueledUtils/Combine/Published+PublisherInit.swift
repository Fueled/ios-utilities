//
//  Published+PublisherInit.swift
//  RPMHelpers
//
//  Created by Stéphane Copin on 1/23/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

import Combine

extension Published {
	/// This method exists as it's currently impossible to use the projectedValue of a `@Published` property without having initialize the whole object,
	/// which is obviously not ideal if the projectedValue is required to initialize the whole object (basically a chicken and egg problem)
	/// This resolves the issue by initializing the Published object separately from the object, and using the result
	/// Non-compiling Example:
	///
	/// final class TestPublished {
	///     @Published private var foo: Int = 0
	///     let fooChanges: AnyPublisher<Int, Never>
	///
	///     init() {
	///         self.fooChanges = AnyPublisher(self.$foo) // 'self' used in property access '$foo' before all stored properties are initialized
	///     }
	/// }
	///
	/// Compiling Example (using below)
	///    final class TestPublished {
	///    @Published private var foo: Int
	///    let fooChanges: AnyPublisher<Int, Never>
	///
	///    init() {
	///        self.fooChanges = AnyPublisher(Published.initWithPublisher(&self._foo, initialValue: 0)) // Compiles
	///    }
	/// }
	public static func initWithPublisher(_ property: inout Published<Value>, initialValue: Value) -> Published<Value>.Publisher {
		var published = Published(initialValue: initialValue)
		let publisher = published.projectedValue
		property = published
		return publisher
	}
}
