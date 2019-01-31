/*
Copyright © 2019 Fueled Digital Media, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
import ReactiveSwift

/// The goal of this protocol is to add RAC-style `reactive` proxy to Swift objects.
@available(*, deprecated, renamed: "ReactiveExtensionsProvider")
public protocol ReactiveLifetimeProvider: ReactiveExtensionsProvider {
	var lifetimeToken: Lifetime.Token { get }
}

/// This base class adds RAC-style `reactive` proxy to Swift objects.

@available(*, deprecated, message: "Make your type a class that conforms to ReactiveLifetimeProvider instead")
open class Lifetimed: ReactiveLifetimeProvider {
	public let lifetimeToken = Lifetime.Token()
}

extension Reactive where Base: AnyObject {
	@available(*, deprecated, renamed: "Lifetime.of()")
	public var lifetime: Lifetime {
		return Lifetime.of(self.base)
	}
}
