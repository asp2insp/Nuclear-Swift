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
    func testDeepNestedToState() {
        let a = ["shopping_cart": ["items": ["eggs", "milk"], "total": 5]]
        let stateRep = Immutable.toState(a)
        
        let expected = "(Map {shopping_cart : (Map {items : (Array [(Value), (Value)]), total : (Value)})})"
        
        XCTAssertEqual(expected, stateRep.description(), "")
    }
    
    // Test simple conversion to state
    func testValueToState() {
        let a = 5
        let stateRep = Immutable.toState(a)
        
        XCTAssertEqual( "(Value)", stateRep.description(), "")
        let b = "hello"
        let stateRep2 = Immutable.toState(b)
        
        XCTAssertEqual("(Value)", stateRep2.description(), "")
    }
    
    // Test deep conversion to state
    func testMapToState() {
        let a = ["total": 5]
        let stateRep = Immutable.toState(a)
        
        let expected = "(Map {total : (Value)})"
        
        XCTAssertEqual(expected, stateRep.description(), "")
    }
    
    // Test deep conversion to state
    func testArrayToState() {
        let a = ["eggs", "milk"]
        let stateRep = Immutable.toState(a)
        
        let expected = "(Array [(Value), (Value)])"
        
        XCTAssertEqual(expected, stateRep.description(), "")
    }
    
    // Test helper functions that convert to state
    func testConvertArray() {
        let a = ["eggs", "milk", 45]
        let stateRep = Immutable.State.Array(Immutable.convertArray(a), 4)
        
        let expected = "(Array [(Value), (Value), (Value)])"
        
        XCTAssertEqual(expected, stateRep.description(), "")
    }
    
    // Test helper functions that convert to state
    func testConvertMap() {
        let a = ["eggs":10, "milk":"one"]
        let stateRep = Immutable.State.Map(Immutable.convertMap(a), 3)
        
        let expected = "(Map {eggs : (Value), milk : (Value)})"
        
        XCTAssertEqual(expected, stateRep.description(), "")
    }
    
    // Ensure that our to string works since we'll be basing everything else on it
    func testDescription() {
        XCTAssertEqual("(Value)", Immutable.State.Value(3, 1).description(), "")
        XCTAssertEqual("(Array [(Value)])", Immutable.State.Array([Immutable.State.Value(3, 1)], 2).description(), "")
        XCTAssertEqual("(Map {hello : (Value)})", Immutable.State.Map(["hello":Immutable.State.Value(3, 1)], 2).description(), "")
    }
}