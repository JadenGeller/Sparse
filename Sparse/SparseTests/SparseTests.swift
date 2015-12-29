//
//  SparseTests.swift
//  SparseTests
//
//  Created by Jaden Geller on 12/28/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import XCTest
@testable import Sparse

class SparseTests: XCTestCase {
    
    func testDefaultValue() {
        let sparse = Sparse([1 : 58, 2 : 63, 6 : 29], defaultValue: 0)
        for i in 0...10 {
            XCTAssertEqual({
                switch i {
                case 1: return 58
                case 2: return 63
                case 6: return 29
                default: return 0
                }
            }(), sparse[i])
        }
    }
    
    func testDefaultValueForKey() {
        let sparse = Sparse([1 : 58, 2 : 63, 6 : 29]) { key in key * key }
        for i in 0...10 {
            XCTAssertEqual({
                switch i {
                case 1: return 58
                case 2: return 63
                case 6: return 29
                default: return i * i
                }
                }(), sparse[i])
        }
    }
    
    func testReset() {
        var sparse = Sparse<Int, Int>(defaultValue: 0)
        sparse[10] = 5
        XCTAssertEqual(5, sparse[10])
        sparse.resetValueForKey(10)
        XCTAssertEqual(0, sparse[10])
    }
    
    func testSequence() {
        var found = Set<Int>()
        let sparse = Sparse([1 : 58, 2 : 63, 6 : 29], defaultValue: 0)
        for (k, _) in sparse {
            found.insert(k)
        }
        XCTAssertEqual(found, [1, 2, 6])
    }
    
    func testSlice() {
        var sparse = Sparse([1 : 58, 2 : 63, 6 : 29]) { key in key * key }
        XCTAssertEqual([0, 58, 63, 9], Array(sparse.get(0...3)))
        var slice = sparse.get(0...3)
        slice[0] = 5
        slice[1] = 6
        sparse.set(slice)
        XCTAssertEqual([5, 6, 63, 9], Array(sparse.get(0...3)))
    }
}
