// Copyright © 2020, Fueled Digital Media, LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ForEachWithIndex<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
	public var data: Data
	public var content: (_ index: Data.Index, _ element: Data.Element) -> Content
	var id: KeyPath<Data.Element, ID>

	public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (_ index: Data.Index, _ element: Data.Element) -> Content) {
		self.data = data
		self.id = id
		self.content = content
	}

	public var body: some View {
		ForEach(
			zip(self.data.indices, self.data).map { index, element in
				IndexInfo(
					index: index,
					id: self.id,
					element: element
				)
			},
			id: \.elementID
		) { indexInfo in
			self.content(indexInfo.index, indexInfo.element)
		}
	}
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ForEachWithIndex where ID == Data.Element.ID, Content: View, Data.Element: Identifiable {
	public init(_ data: Data, @ViewBuilder content: @escaping (_ index: Data.Index, _ element: Data.Element) -> Content) {
		self.init(data, id: \.id, content: content)
	}
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ForEachWithIndex: DynamicViewContent where Content: View {
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct IndexInfo<Index, Element, ID: Hashable>: Hashable {
	let index: Index
	let id: KeyPath<Element, ID>
	let element: Element

	var elementID: ID {
		self.element[keyPath: self.id]
	}

	static func == (_ lhs: IndexInfo, _ rhs: IndexInfo) -> Bool {
		lhs.elementID == rhs.elementID
	}

	func hash(into hasher: inout Hasher) {
		self.elementID.hash(into: &hasher)
	}
}

#endif
