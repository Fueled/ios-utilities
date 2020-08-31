//
//  FoundationExtensions.swift
//  Pods
//
//  Created by Stéphane Copin on 8/31/20.
//

extension FloatingPoint {
	func rounded(decimalPlaces: Int, rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self {
		var this = self
		this.round(decimalPlaces: decimalPlaces, rule: rule)
		return this
	}

	mutating func round(decimalPlaces: Int, rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) {
		var offset = Self(1)
		for _ in (0..<decimalPlaces) {
			offset *= Self(10)
		}
		self *= offset
		self.round(rule)
		self /= offset
	}
}
