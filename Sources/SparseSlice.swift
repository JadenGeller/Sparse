//
//  SparseSlice.swift
//  Sparse
//
//  Created by Jaden Geller on 12/29/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

public typealias HashableForwardIndexType = protocol<Hashable, ForwardIndexType>

/// A view of a limited range of a Sparse providing Array-like collection semantics
public struct SparseSlice<Key: HashableForwardIndexType, Value: Equatable> {
    private var backing: Sparse<Key, Value>
    private let range: Range<Key>

    private init(backing: Sparse<Key, Value>, range: Range<Key>) {
        self.backing = backing
        self.range = range
    }
}

extension SparseSlice: CollectionType {
    public var startIndex: Key {
        return range.startIndex
    }
    
    public var endIndex: Key {
        return range.endIndex
    }
    
    public subscript(index: Key) -> Value {
        get {
            return backing[index]
        }
        set {
            backing[index] = newValue
        }
    }
}

extension Sparse where Key: HashableForwardIndexType {
    func get(range: Range<Key>) -> SparseSlice<Key, Value> {
        return SparseSlice(backing: self, range: range)
    }
    
    mutating func set(slice: SparseSlice<Key, Value>) {
        slice.indices.forEach { key in self[key] = slice[key] }
    }

// WHY DOESN'T THIS FAIL TO COMPILE?!?!?! *CRASH*
//    public subscript(range: Range<Key>) -> SparseSlice<Key, Value> {
//        get {
//            return SparseSlice(backing: self, range: range)
//        }
//    }
}
