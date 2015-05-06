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
    
    // Should convert primitives to state
    func testToStateOnPrimitives() {
        XCTAssertTrue(Immutable.State.Value(5, 1) === Immutable.toState(5), "Couldn't convert an int to state")
        XCTAssertTrue(Immutable.State.Value("hello", 2) === Immutable.toState("hello"), "Couldn't convert a string to state")
        XCTAssertTrue(Immutable.State.Value(5.3, 3) === Immutable.toState(5.3), "Couldn't convert a double to state")
    }

}