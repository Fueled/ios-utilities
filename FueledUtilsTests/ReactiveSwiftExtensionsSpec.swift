//
//  ReactiveSwiftExtensionsSpec.swift
//  FueledUtilsTests
//
//  Created by Stéphane Copin on 1/29/19.
//  Copyright © 2019 Fueled. All rights reserved.
//

import Quick
import Nimble
import FueledUtils
import ReactiveSwift
import Result
import XCTest

class ReactiveSwiftExtensionsSpec: QuickSpec {
	override func spec() {
		describe("Signal") {
			describe("minimum") {
				it("should send any values after the minimum time specified") {
					let (signal, observer) = Signal<Void, NoError>.pipe()
					let waitScheduler = QueueScheduler(qos: .utility, name: "Observe", targeting: nil)
					var valuesReceived = 0
					signal.minimum(interval: 0.1, on: waitScheduler).observeValues {
						valuesReceived += 1
					}

					observer.send(value: ())

					expect(valuesReceived) == 0

					expect(valuesReceived).toEventually(equal(1), timeout: 1.0)

					observer.send(value: ())

					expect(valuesReceived) == 2
				}
				it("should send any errors after the minimum time specified") {
					let (signal, observer) = Signal<Never, NSError>.pipe()
					let waitScheduler = QueueScheduler(qos: .utility, name: "Observe", targeting: nil)
					var errorsReceived = 0
					signal.minimum(interval: 0.1, on: waitScheduler).observeFailed { _ in
						errorsReceived += 1
					}

					observer.send(error: NSError(domain: "", code: 0, userInfo: nil))

					expect(errorsReceived) == 0

					expect(errorsReceived).toEventually(equal(1), timeout: 1.0)
				}
				it("should send any values instantly and receive an interrupted event if interrupted before the minimum interval is met") {
					let (signal, observer) = Signal<Void, NoError>.pipe()
					let waitScheduler = QueueScheduler(qos: .utility, name: "Observe", targeting: nil)
					var valuesReceived = 0
					var interruptedReceived = 0
					signal.minimum(interval: 0.1, on: waitScheduler).observe { event in
						switch event {
						case .value:
							valuesReceived += 1
						case .interrupted:
							interruptedReceived += 1
						default:
							break
						}
					}

					observer.send(value: ())
					observer.send(value: ())

					expect(valuesReceived) == 0
					expect(interruptedReceived) == 0

					observer.sendInterrupted()

					expect(valuesReceived) == 2
					expect(interruptedReceived) == 1
				}
			}
		}
	}
}
