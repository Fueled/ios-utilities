import Foundation
import ReactiveSwift
import Result

public enum LoadingState<Error: Swift.Error> {
	case `default`
	case loading
	case failed(error: Error)
	public var error: Error? {
		if case .failed(let error) = self {
			return error
		} else {
			return nil
		}
	}
	public var loading: Bool {
		if case .loading = self {
			return true
		} else {
			return false
		}
	}
}

public extension Action {
	public func loadingState() -> SignalProducer<LoadingState<Error>, NoError> {
		let loading = self.isExecuting.producer
			.filter { $0 }
			.map { _ in LoadingState<Error>.loading }
		let eventStates = self.events.map {
			(event: Event<Output, Error>) -> LoadingState<Error> in
			switch event {
			case .failed(let error):
				return LoadingState<Error>.failed(error: error)
			default:
				return LoadingState<Error>.default
			}
		}
		return loading.lift { $0.merge(with: eventStates) }
	}
}
