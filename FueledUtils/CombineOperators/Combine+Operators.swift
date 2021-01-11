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

#if canImport(Combine)
import Combine

// swiftlint:disable generic_type_name

#if !canImport(ReactiveSwift)
precedencegroup BindingPrecedence {
	associativity: right

	higherThan: AssignmentPrecedence
}

infix operator <~: BindingPrecedence
#else
import ReactiveSwift
#endif

precedencegroup AccessPrecedence {
	associativity: right

	higherThan: BindingPrecedence
}

infix operator ~: AccessPrecedence

precedencegroup InsertCancellablePrecedence {
	associativity: left

	lowerThan: AssignmentPrecedence
}

infix operator >>>: InsertCancellablePrecedence

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ObjectKeyPathReference<Root, Value> {
	public let object: Root
	public let keyPath: ReferenceWritableKeyPath<Root, Value>
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func ~ <Object, Value>(lhs: Object, rhs: ReferenceWritableKeyPath<Object, Value>) -> ObjectKeyPathReference<Object, Value> {
	ObjectKeyPathReference(object: lhs, keyPath: rhs)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func <~ <Object: AnyObject, Value, Publisher: Combine.Publisher>(
	lhs: ObjectKeyPathReference<Object, Value>,
	rhs: Publisher
) -> AnyCancellable where Publisher.Output == Value, Publisher.Failure == Never {
	rhs.assign(to: lhs.keyPath, withoutRetaining: lhs.object)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func <~ <ObservingObject: ObservableObject, ObservedObject: ObservableObject>(
	lhs: ObservingObject,
	rhs: ObservedObject
) where ObservingObject.ObjectWillChangePublisher == ObservableObjectPublisher {
	lhs.link(to: rhs)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func <~ <ObservingObject: ObservableObject, ObservedObjectCollection: Collection>(
	lhs: ObservingObject,
	rhs: ObservedObjectCollection
) where ObservingObject.ObjectWillChangePublisher == ObservableObjectPublisher, ObservedObjectCollection.Element: ObservableObject {
	lhs.link(to: rhs)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func <~ <ObservingObject: ObservableObject, Publisher: Combine.Publisher>(
	lhs: ObservingObject,
	rhs: Publisher
) where ObservingObject.ObjectWillChangePublisher == ObservableObjectPublisher, Publisher.Output: ObservableObject {
	lhs.link(to: rhs)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func <~ <ObservingObject: ObservableObject, Publisher: Combine.Publisher>(
	lhs: ObservingObject,
	rhs: Publisher
) where ObservingObject.ObjectWillChangePublisher == ObservableObjectPublisher, Publisher.Output: OptionalProtocol, Publisher.Output.Wrapped: ObservableObject {
	lhs.link(to: rhs)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func <~ <ObservingObject: ObservableObject, Publisher: Combine.Publisher>(
	lhs: ObservingObject,
	rhs: Publisher
) where ObservingObject.ObjectWillChangePublisher == ObservableObjectPublisher, Publisher.Output: Collection, Publisher.Output.Element: ObservableObject {
	lhs.link(to: rhs)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func <~ <ObservingObject: ObservableObject, ObservedObject: ObservableObject>(
	lhs: ObservingObject,
	rhs: ReferenceWritableKeyPath<ObservingObject, ObservedObject>
) where ObservingObject.ObjectWillChangePublisher == ObservableObjectPublisher {
	lhs.link(to: lhs[keyPath: rhs])
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func <~ <ObservingObject: ObservableObject, ObservedObjectCollection: Collection>(
	lhs: ObservingObject,
	rhs: ReferenceWritableKeyPath<ObservingObject, ObservedObjectCollection>
) where ObservingObject.ObjectWillChangePublisher == ObservableObjectPublisher, ObservedObjectCollection.Element: ObservableObject {
	lhs.link(to: lhs[keyPath: rhs])
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func >>> <CancellableCollection: RangeReplaceableCollection>(lhs: AnyCancellable, rhs: inout CancellableCollection) where CancellableCollection.Element == AnyCancellable {
	lhs.store(in: &rhs)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func >>> (lhs: AnyCancellable, rhs: inout Set<AnyCancellable>) {
	lhs.store(in: &rhs)
}

#endif
