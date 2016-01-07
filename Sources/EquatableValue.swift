//
//  EquatableValue.swift
//  Sparse
//
//  Created by Jaden Geller on 1/6/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

public struct EquatableValue<Value> {
    public let value: Value
    public let isValue: Value -> Bool
    
    public init(_ value: Value, isValue: Value -> Bool) {
        self.value = value
        self.isValue = isValue
    }
    
    public init(neverEquatable value: Value) {
        self.value = value
        self.isValue = { _ in false }
    }
}

extension EquatableValue where Value: Equatable {
    public init(_ value: Value) {
        self.value = value
        self.isValue = { element in element == value }
    }
}

// MARK: Optional

public protocol OptionalType: NilLiteralConvertible {
    typealias Wrapped
    var optionalValue: Wrapped? { get }
}

extension Optional: OptionalType {
    public var optionalValue: Wrapped? {
        return self
    }
}

// TODO: Uncomment in Swift 3.0
extension EquatableValue /* : NilLiteralConvertible */ where Value: OptionalType {
    public init(nilLiteral: ()) {
        self.value = nil
        self.isValue = { element in
            switch element.optionalValue {
            case nil: return true
            default:  return false
            }
        }
    }
    
    public static var None: EquatableValue {
        return EquatableValue(nilLiteral: ())
    }
}

public typealias ArrayLiteralConvertibleCollectionType = protocol<ArrayLiteralConvertible, CollectionType>
extension EquatableValue where Value: ArrayLiteralConvertibleCollectionType {
    public static var None: EquatableValue {
        return EquatableValue([], isValue: { $0.isEmpty })
    }
}
