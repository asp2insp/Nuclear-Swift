//
//  ImmutableTests.swift
//  Nuclear
//
//  Created by Josiah Gaskin on 5/5/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import UIKit
import XCTest

class ImmutableTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    // Test comparison by tag, and marking as dirty
    func testTaggingAndMarkAsDirty() {
        let a = Immutable.State.Value(5, 2)
        let b = Immutable.State.Value(5, 3)
        
        XCTAssertFalse(a === b, "States should be compared by tag not by value")
        XCTAssertTrue(a === a, "States should be self-identical")
        
        XCTAssertFalse(a === Immutable.markAsDirty(a), "Mark as dirty should update tag")
    }

    // Test deep conversion to state
    func testToState() {
        let a = ["shopping_cart": ["items": ["eggs", "milk"], "total": 5]]
        let stateRep = Immutable.toState(a)
        
        let expected = "(Map {shopping_cart : (Map {items : (Array [(Value : 1), (Value : 2)] : 3)} : 4)} : 5)"
        
        XCTAssertEqual(expected, stateRep.description(), "")
    }
    
    // Ensure that our to string works since we'll be basing everything else on it
    func testDescription() {
        XCTAssertEqual("(Value : 1)", Immutable.State.Value(3, 1).description(), "")
        XCTAssertEqual("(Array [(Value : 1)] : 2)", Immutable.State.Array([Immutable.State.Value(3, 1)], 2).description(), "")
        XCTAssertEqual("(Map {hello : (Value : 1)} : 2)", Immutable.State.Map(["hello":Immutable.State.Value(3, 1)], 2).description(), "")
    }
}