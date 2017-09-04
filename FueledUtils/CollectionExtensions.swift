public extension Collection {
	public func getSafely(_ index: Self.Index) -> Self.Iterator.Element? {
		if index < self.startIndex || index > self.endIndex {
			return nil
		}
		return self[index]
	}
}

