//
//  ChangeObserverTests.swift
//  Nuclear
//
//  Created by Josiah Gaskin on 5/14/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation
import XCTest

class ChangeObserverTests: XCTestCase {
    
    class TestStore : Store {
        override func getInitialState() -> Immutable.State {
            return Immutable.toState([
                "a": ["b": 2, "c": 0],
            ])
        }
        
        override func initialize() {
            self.on("setB", handler: {(state, payload, action) -> Immutable.State in
                return state.setIn(["a", "b"], withValue: Immutable.toState(payload as! AnyObject))
            })
        }
    }
    let reactor = Reactor()
    let getter = Getter(keyPath: ["store", "a", "b"])
    let parentGetter = Getter(keyPath: ["store", "a"])
    let siblingGetter = Getter(keyPath: ["store", "a", "c"])
    
    var handleCount = 0

    override func setUp() {
        super.setUp()
        reactor.registerStore("store", store: TestStore())
        reactor.reset()
        handleCount = 0
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testChangeObserverFiresOnObjectChange() {
        let handler = {(state: Immutable.State) -> () in
            handleCount++
        }
        let regId = reactor.observe(getter, handler: handler)
        
        reactor.dispatch("setB", payload: "Hi")
        XCTAssertEqual(1, handleCount, "")
        
        // Should not be called again after being unregistered
        reactor.unobserve(regId)
        reactor.dispatch("setB", payload: "world")
        XCTAssertEqual(1, handleCount, "")
    }
    
    func testSiblingAndParent() {
        let handler = {(state: Immutable.State) -> () in
            handleCount++
        }
        reactor.observe(getter, handler: handler)
        reactor.observe(siblingGetter, handler: handler)
        reactor.observe(parentGetter, handler: handler)
        
        reactor.dispatch("setB", payload: "Hi")
        XCTAssertEqual(2, handleCount, "Parent + Getter, but not sibling")
    }
    
    func testUnregisterMultiple() {
        let handler = {(state: Immutable.State) -> () in
            handleCount++
        }
        let a = reactor.observe(getter, handler: handler)
        let b = reactor.observe(parentGetter, handler: handler)
        
        reactor.dispatch("setB", payload: "Hi")
        
        XCTAssertEqual(2, handleCount, "Both")
        
        reactor.unobserve(a, b)
    
        reactor.dispatch("setB", payload: "Hi")
        XCTAssertEqual(2, handleCount, "Neither")
    }
}
