public extension Sequence {
	public func collate<K: Hashable>(_ key: (Iterator.Element) -> K?) -> [K: [Iterator.Element]] {
		var res: [K: [Iterator.Element]] = [:]
		for s in self {
			if let k = key(s) {
				if let vs = res[k] {
					res[k] = vs + [s]
				} else {
					res[k] = [s]
				}
			}
		}
		return res
	}

	public func splitBetween(_ areSeparated: (Iterator.Element, Iterator.Element) -> Bool) -> [[Iterator.Element]] {
		var res: [[Iterator.Element]] = []
		var chunk: [Iterator.Element] = []
		var last: Iterator.Element? = nil
		for s in self {
			if let last = last , areSeparated(last, s) {
				res.append(chunk)
				chunk = []
			}
			chunk.append(s)
			last = s
		}
		if !chunk.isEmpty {
			res.append(chunk)
		}
		return res
	}

	@available(*, deprecated, renamed: "first(where:)")
	func findFirst(_ predicate: (Iterator.Element) -> Bool) -> Iterator.Element? {
		return self.first(where: predicate)
	}
}
