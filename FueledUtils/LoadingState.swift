import Foundation
import ReactiveCocoa
import Result

public enum LoadingState<Error: ErrorType> {
	case Default
	case Loading
	case Failed(error: Error)
	public var error: Error? {
		if case .Failed(let error) = self {
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
		let loading = self.executing.producer
			.filter { $0 }
			.map { _ in LoadingState<Error>.Loading }
		let eventStates = self.events.map {
			(event: Event<Output, Error>) -> LoadingState<Error> in
			switch event {
			case .Failed(let error):
				return LoadingState<Error>.Failed(error: error)
			default:
				return LoadingState<Error>.Default
			}
		}
		return loading.lift { $0.mergeWith(eventStates) }
	}
}
