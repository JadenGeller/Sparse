//
//  Sparse.swift
//  Sparse
//
//  Created by Jaden Geller on 12/28/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

public struct Sparse<Key: Hashable, Value>: CollectionType {
    public typealias ValueChecker = Value -> Bool
    
    private let defaultValueForKey: Key -> Value
    private let isDefaultValueForKey: Key -> ValueChecker
    internal var backing: [Key : Value] = [:]
    
    public init(defaultValueForKey: Key -> Value, isDefaultValueForKey: Key -> ValueChecker) {
        self.defaultValueForKey = defaultValueForKey
        self.isDefaultValueForKey = isDefaultValueForKey
    }
    
    public init(defaultValue: Value, isDefaultValue: ValueChecker) {
        self.init(defaultValueForKey: { _ in defaultValue }, isDefaultValueForKey: { _ in isDefaultValue })
    }
}

// MARK: Equatable Initializers

extension Sparse where Value: Equatable {
    public init(defaultValueForKey: Key -> Value) {
        self.init(defaultValueForKey: defaultValueForKey, isDefaultValueForKey: { key in { value in defaultValueForKey(key) == value } })
    }
    
    public init(defaultValue: Value) {
        self.init(defaultValueForKey: { _ in defaultValue })
    }
}

// MARK: Memory-Inefficient Initializers 

extension Sparse {
    /// Since there's no way to check when a value has been set back to the default, default values will
    /// be stored in memory unless removed with `resetValueAtIndex`.
    public init(memoryInefficientDefultValueForKey defaultValueForKey: Key -> Value) {
        self.init(defaultValueForKey: defaultValueForKey, isDefaultValueForKey: { _ in { _ in false } })
    }
    
    /// Since there's no way to check when a value has been set back to the default, default values will
    /// be stored in memory unless removed with `resetValueAtIndex`.
    public init(memoryInefficientDefultValue defaultValue: Value) {
        self.init(memoryInefficientDefultValueForKey: { _ in defaultValue })
    }
}

// MARK: Sequence Initializers

extension Sparse {
    mutating private func _addElementsFromSequence<S: SequenceType where S.Generator.Element == (Key, Value)>(sequence: S) {
        sequence.forEach { (key, value) in self.backing[key] = value }
    }
    
    public init<S: SequenceType where S.Generator.Element == (Key, Value)>(_ sequence: S, defaultValueForKey: Key -> Value, isDefaultValueForKey: Key -> ValueChecker) {
        self.init(defaultValueForKey: defaultValueForKey, isDefaultValueForKey: isDefaultValueForKey)
        _addElementsFromSequence(sequence)
    }
    
    public init<S: SequenceType where S.Generator.Element == (Key, Value)>(_ sequence: S, defaultValue: Value, isDefaultValue: ValueChecker) {
        self.init(defaultValue: defaultValue, isDefaultValue: isDefaultValue)
        _addElementsFromSequence(sequence)
    }
}

// MARK: Equatable Sequence Initializers

extension Sparse where Value: Equatable {
    public init<S: SequenceType where S.Generator.Element == (Key, Value)>(_ sequence: S, defaultValueForKey: Key -> Value) {
        self.init(defaultValueForKey: defaultValueForKey)
        _addElementsFromSequence(sequence)
    }
    
    public init<S: SequenceType where S.Generator.Element == (Key, Value)>(_ sequence: S, defaultValue: Value) {
        self.init(defaultValue: defaultValue)
        _addElementsFromSequence(sequence)
    }
}

// MARK: Memory-Inefficient Sequence Initializers

extension Sparse {
    /// Since there's no way to check when a value has been set back to the default, default values will
    /// be stored in memory unless removed with `resetValueAtIndex`.
    public init<S: SequenceType where S.Generator.Element == (Key, Value)>(_ sequence: S, memoryInefficientDefultValueForKey defaultValueForKey: Key -> Value) {
        self.init(memoryInefficientDefultValueForKey: defaultValueForKey)
        _addElementsFromSequence(sequence)
    }
    
    /// Since there's no way to check when a value has been set back to the default, default values will
    /// be stored in memory unless removed with `resetValueAtIndex`.
    public init<S: SequenceType where S.Generator.Element == (Key, Value)>(_ sequence: S, memoryInefficientDefultValue defaultValue: Value) {
        self.init(memoryInefficientDefultValue: defaultValue)
        _addElementsFromSequence(sequence)
    }
}

// MARK: Implementation

extension Sparse {
    public subscript(key: Key) -> Value {
        get {
            return backing[key] ?? defaultValueForKey(key)
        }
        set {
            let isDefault = isDefaultValueForKey(key)(newValue)
            backing[key] = isDefault ? nil : newValue
        }
    }
    
    public mutating func resetValueForKey(key: Key) -> Value {
        let value = self[key]
        backing[key] = nil
        return value
    }
    
    public mutating func resetAll() {
        backing.removeAll()
    }
}

extension Sparse: SequenceType {
    /// Returns a generator over the non-default (key, value) pairs.
    public func generate() -> DictionaryGenerator<Key, Value> {
        return backing.generate()
    }
}

extension Sparse: Indexable {
    public var startIndex: DictionaryIndex<Key, Value> {
        return backing.startIndex
    }
    
    public var endIndex: DictionaryIndex<Key, Value> {
        return backing.endIndex
    }
    
    public subscript(position: DictionaryIndex<Key, Value>) -> (Key, Value) {
        return backing[position]
    }
    
    public func indexForKey(key: Key) -> DictionaryIndex<Key, Value>? {
        return backing.indexForKey(key)
    }
    
    public mutating func resetValueAtIndex(index: DictionaryIndex<Key, Value>) -> (Key, Value) {
        let (key, value) = self[index]
        resetValueForKey(key)
        return (key, value)
    }
}

extension Sparse: CustomStringConvertible {
    public var description: String {
        return backing.description
    }
}

extension Sparse {
    public var keys: LazyMapCollection<[Key : Value], Key> {
        return backing.keys
    }
    
    public var values: LazyMapCollection<[Key : Value], Value> {
        return backing.values
    }
    
    public mutating func updateValue(value: Value, forKey key: Key) -> Value {
        let oldValue = self[key]
        self[key] = value
        return oldValue
    }
}
