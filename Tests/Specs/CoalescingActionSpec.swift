//
//  CoalescingActionSpec.swift
//  FueledUtilsTests
//
//  Created by Stéphane Copin on 10/15/19.
//  Copyright © 2019 Fueled. All rights reserved.
//

import Quick
import Nimble
import FueledUtils
import ReactiveSwift
import XCTest

class CoalescingActionSpec: QuickSpec {
	override func spec() {
		describe("CoalescingAction") {
			describe("apply.dispose()") {
				it("should dispose of all created signal producers") {
					var startCounter = 0
					var disposeCounter = 0
					var interruptedCounter = 0
					let coalescingAction = CoalescingAction {
						SignalProducer(value: 2.0)
							.delay(1.0, on: QueueScheduler.main)
							.on(
								started: {
									startCounter += 1
								},
								interrupted: {
									interruptedCounter += 1
								},
								disposed: {
									disposeCounter += 1
								}
							)
					}

					expect(startCounter) == 0

					let producersCount = 5
					let disposables = (0..<producersCount).map { _ in coalescingAction.apply().start() }

					expect(startCounter) == 1

					disposables[0].dispose()

					expect(disposeCounter) == 0
					expect(interruptedCounter) == 0

					disposables[1..<producersCount].forEach { $0.dispose() }

					expect(disposeCounter).toEventually(equal(1))
					expect(interruptedCounter).toEventually(equal(1))
				}
			}
		}
	}
}
