//
//  Sparse.swift
//  Sparse
//
//  Created by Jaden Geller on 12/28/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

public struct Sparse<Key: Hashable, Value: Equatable>: CollectionType {
    private let defaultValueForKey: Key -> Value
    private var backing: [Key : Value] = [:]
    
    public init<S: SequenceType where S.Generator.Element == (Key, Value)>(_ sequence: S, defaultValueForKey: Key -> Value) {
        self.init(defaultValueForKey: defaultValueForKey)
        sequence.forEach { (key, value) in self.backing[key] = value }
    }
    
    public init(defaultValueForKey: Key -> Value) {
        self.defaultValueForKey = defaultValueForKey
    }
    
    public init<S: SequenceType where S.Generator.Element == (Key, Value)>(_ sequence: S, defaultValue: Value) {
        self.init(sequence, defaultValueForKey: { _ in defaultValue })
    }
    
    public init(defaultValue: Value) {
        self.init(defaultValueForKey: { _ in defaultValue })
    }
    
    public subscript(key: Key) -> Value {
        get {
            return backing[key] ?? defaultValueForKey(key)
        }
        set {
            let isDefault = newValue == defaultValueForKey(key)
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
