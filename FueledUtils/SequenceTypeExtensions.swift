public extension SequenceType {
	public func collate<K: Hashable>(@noescape key: Generator.Element -> K?) -> [K: [Generator.Element]] {
		var res: [K: [Generator.Element]] = [:]
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

	public func splitBetween(@noescape areSeparated: (Generator.Element, Generator.Element) -> Bool) -> [[Generator.Element]] {
		var res: [[Generator.Element]] = []
		var chunk: [Generator.Element] = []
		var last: Generator.Element? = nil
		for s in self {
			if let last = last where areSeparated(last, s) {
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
}
