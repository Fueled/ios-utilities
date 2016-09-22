import Foundation
import ReactiveSwift
import Result

public enum LoadingState<ErrorType: Error> {
	case `default`
	case Loading
	case failed(error: ErrorType)
	public var error: ErrorType? {
		if case .failed(let error) = self {
			return error
		} else {
			return nil
		}
	}
	public var loading: Bool {
		if case .Loading = self {
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
			.map { _ in LoadingState<Error>.Loading }
		let eventStates = self.events.map {
			(event: Event<Output, Error>) -> LoadingState<Error> in
			switch event {
			case .failed(let error):
				return LoadingState<Error>.failed(error: error)
			default:
				return LoadingState<Error>.default
			}
		}
		return loading.lift { $0.mergeWith(eventStates) }
	}
}
