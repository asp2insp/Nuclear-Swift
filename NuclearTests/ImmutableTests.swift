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
    
    // Test dirty marks
    func testSetInMarksAsDirty() {
        var state = Immutable.toState([:])
        state = state.setIn(["a", 5], withValue: Immutable.toState(75))
        XCTAssertTrue(state.getIn(["a", 5]) === state.getIn(["a", 5]), "Identity failed on same value")
        XCTAssertTrue(state.getIn(["a", 2]) === state.getIn(["a", 2]), "Identity failed on None")
        
        // Test replace
        let oldValue = state.getIn(["a", 5])
        let oldRoot = state
        let oldArray = state.getIn(["a"])
        state = state.setIn(["a", 5], withValue: Immutable.toState(88))
        XCTAssertFalse(oldValue === state.getIn(["a", 5]), "Updated value should have different tag")
        XCTAssertFalse(oldArray === state.getIn(["a"]), "Array with updated child should have different tag")
        XCTAssertFalse(oldRoot === state, "Map with updated child should have different tag")
    }
    
    
    // Test mutators
    func testSetIn() {
        var state = Immutable.toState([:])
        state = state.setIn(["a", 0, "b"], withValue: Immutable.toState("Hello!"))
        XCTAssertEqual("(Map {a : (Array [(Map {b : (Value)})])})", state.description(), "")
        XCTAssertEqual("Hello!", Immutable.fromState(state.getIn(["a", 0, "b"])) as! String, "")
        
        // Test auto fill arrays increment
        state = state.setIn(["a", 5], withValue: Immutable.toState(75))
        XCTAssertEqual("(Map {a : (Array [(Map {b : (Value)}), (None), (None), (None), (None), (Value)])})", state.description(), "")
        XCTAssertEqual(75, Immutable.fromState(state.getIn(["a", 5])) as! Int, "")
        
        // Test replace
        state = state.setIn(["a", 5], withValue: Immutable.toState(88))
        XCTAssertEqual(88, Immutable.fromState(state.getIn(["a", 5])) as! Int, "")
    }
    
    // Test mapping transformation
    func testMap() {
        let state = Immutable.toState([0, 1, 2, 3, 4, 5])
        let plusThree = state.map({(int, index) in
            return Immutable.toState(int.toSwift() as! Int + 3)
        })
        let native = plusThree.toSwift() as! [Any?]
        for var i = 0; i < 5; i++ {
            XCTAssertEqual(i+3, native[i] as! Int, "")
        }
    }
    
    // Test reducing transformation
    func testReduce() {
        let state = Immutable.toState([0, 1, 2, 3, 4, 5])
        let summed = state.reduce(Immutable.toState(0), f: {(sum, one)  in
            let a = sum.toSwift() as! Int
            let b = one.toSwift() as! Int
            return Immutable.toState(a + b)
        })
        XCTAssertEqual(15, summed.toSwift() as! Int, "")
    }
    
    // Test helper functions that convert back from state
    func testFromStateNested() {
        let state = Immutable.toState(["shopping_cart": ["items": ["eggs", "milk"], "total": 5]])
        let native = Immutable.fromState(state) as! [String:Any?]
        let cart = native["shopping_cart"] as! [String:Any?]
        let items = cart["items"] as! [Any?]
        XCTAssertEqual(5, cart["total"] as! Int, "")
        XCTAssertEqual("eggs", items[0] as! String, "")
        XCTAssertEqual("milk", items[1] as! String, "")
    }
    
    func testConvertBackFromArray() {
        let state = Immutable.convertArray([0, 1, 2, 3])
        let native = Immutable.convertArrayBack(state)
        XCTAssertEqual(4, native.count, "There should be 4 items in the round-tripped array")
        for var i = 0; i < 3; i++ {
            XCTAssertEqual(i, native[i] as! Int, "")
        }
    }
    
    func testConvertBackFromMap() {
        let state = Immutable.convertMap(["hello":"world", "eggs":12])
        let native = Immutable.convertMapBack(state)
        XCTAssertEqual(2, native.count, "There should be 2 items in the round-tripped array")
        XCTAssertEqual("world", native["hello"] as! String, "")
        XCTAssertEqual(12, native["eggs"] as! Int, "")
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
        
        let b = [1, 2, 3]
        let stateRep2 = Immutable.toState(b)
        
        let expected2 = "(Array [(Value), (Value), (Value)])"
        
        XCTAssertEqual(expected2, stateRep2.description(), "")
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