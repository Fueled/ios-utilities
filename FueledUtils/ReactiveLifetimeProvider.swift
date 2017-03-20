import ReactiveSwift

public protocol ReactiveLifetimeProvider: ReactiveExtensionsProvider {
	var lifetimeToken: Lifetime.Token { get }
}

open class Lifetimed: ReactiveLifetimeProvider {
	public let lifetimeToken = Lifetime.Token()
	public init() {
	}
}

public extension Reactive where Base: ReactiveLifetimeProvider {
	public var lifetime: Lifetime {
		return Lifetime(self.base.lifetimeToken)
	}
	public func makeBindingTarget<U>(on scheduler: Scheduler = UIScheduler(), _ action: @escaping (Base, U) -> Void) -> BindingTarget<U> {
		return BindingTarget(on: scheduler, lifetime: lifetime) { [weak base = self.base] value in
			if let base = base {
				action(base, value)
			}
		}
	}
}
