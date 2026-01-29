//
//  Publisher+AdditionalHandleEvents.swift
//  FueledUtils
//
//  Created by Stéphane Copin on 10/14/20.
//

import Combine

public extension Publisher {
	/// - Parameters:
	///   - receiveTermination: Sent when the publisher either a completion event or is cancelled.
	///   - receiveResult: Sent when the publisher send values, or an error.
	/// - Please refer to the documentation for
	/// `Publisher.self.handleEvents(receiveSubscription:receiveOutput:receiveCompletion:receiveCancel:receiveRequest:)`
	/// for more information about the other parameters.
	func handleEvents(
		receiveSubscription: ((Subscription) -> Void)? = nil,
		receiveOutput: ((Output) -> Void)? = nil,
		receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil,
		receiveCancel: (() -> Void)? = nil,
		receiveTermination: @escaping () -> Void,
		receiveResult: ((Result<Output, Failure>) -> Void)? = nil,
		receiveRequest: ((Subscribers.Demand) -> Void)? = nil
	) -> Publishers.HandleEvents<Self> {
		extendedHandleEvents(
			receiveSubscription: receiveSubscription,
			receiveOutput: receiveOutput,
			receiveCompletion: receiveCompletion,
			receiveCancel: receiveCancel,
			receiveTermination: receiveTermination,
			receiveResult: receiveResult,
			receiveRequest: receiveRequest
		)
	}

	/// - Parameters:
	///   - receiveTermination: Sent when the publisher either a completion event or is cancelled.
	///   - receiveResult: Sent when the publisher send values, or an error.
	/// - Please refer to the documentation for
	/// `Publisher.self.handleEvents(receiveSubscription:receiveOutput:receiveCompletion:receiveCancel:receiveRequest:)`
	/// for more information about the other parameters.
	func handleEvents(
		receiveSubscription: ((Subscription) -> Void)? = nil,
		receiveOutput: ((Output) -> Void)? = nil,
		receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil,
		receiveCancel: (() -> Void)? = nil,
		receiveTermination: (() -> Void)? = nil,
		receiveResult: @escaping (Result<Output, Failure>) -> Void,
		receiveRequest: ((Subscribers.Demand) -> Void)? = nil
	) -> Publishers.HandleEvents<Self> {
		self.extendedHandleEvents(
			receiveSubscription: receiveSubscription,
			receiveOutput: receiveOutput,
			receiveCompletion: receiveCompletion,
			receiveCancel: receiveCancel,
			receiveTermination: receiveTermination,
			receiveResult: receiveResult,
			receiveRequest: receiveRequest
		)
	}
}

private extension Publisher {
	func extendedHandleEvents(
		receiveSubscription: ((Subscription) -> Void)? = nil,
		receiveOutput: ((Output) -> Void)? = nil,
		receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil,
		receiveCancel: (() -> Void)? = nil,
		receiveTermination: (() -> Void)? = nil,
		receiveResult: ((Result<Output, Failure>) -> Void)?,
		receiveRequest: ((Subscribers.Demand) -> Void)? = nil
	) -> Publishers.HandleEvents<Self> {
		var hasTerminated = false
		let receiveTermination = receiveTermination.map { receiveTermination in
			{
				if hasTerminated {
					return
				}
				hasTerminated = true
				receiveTermination()
			}
		}
		return handleEvents(
			receiveSubscription: receiveSubscription,
			receiveOutput: {
				receiveOutput?($0)
				receiveResult?(.success($0))
			},
			receiveCompletion: {
				receiveCompletion?($0)
				if case .failure(let error) = $0 {
					receiveResult?(.failure(error))
				}
				receiveTermination?()
			},
			receiveCancel: {
				receiveCancel?()
				receiveTermination?()
			},
			receiveRequest: receiveRequest
		)
	}
}
