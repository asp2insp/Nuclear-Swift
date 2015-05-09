//
//  EvaluatorTests.swift
//  Nuclear
//
//  Created by Josiah Gaskin on 5/8/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//


import XCTest

class EvaluatorTests: XCTestCase {
    var state : Immutable.State = Immutable.State.None
    
    override func setUp() {
        self.state = Immutable.toState(["shopping_cart": ["items": ["eggs":1, "milk":2], "budget": 5]])
        super.setUp()
    }
    
    // Test simple keypath
    func testSimpleKeypath() {
        let simpleGetter = Getter(keyPath: ["shopping_cart", "budget"])
        let result = Evaluator.evaluate(self.state, withGetter: simpleGetter)
        XCTAssertEqual(5, result.toSwift() as! Int, "")
    }
    
    // Test keypath with compute
    func testKeyPathWithCompute() {
        let totalItems = Getter(keyPath: ["shopping_cart", "items"], withFunc: {(args) in
            return args[0].map({ (s, index) in
                return s
            }).reduce(Immutable.toState(0), f: {(sum, one)  in
                let a = sum.toSwift() as! Int
                let b = one.toSwift() as! Int
                return Immutable.toState(a + b)
            })
        })
        let result = Evaluator.evaluate(self.state, withGetter: totalItems)
        XCTAssertEqual(3, result.toSwift() as! Int, "")
    }
    
    // Test multiple getters
    func testMultiGetter() {
        let eggs = Getter(keyPath: ["shopping_cart", "items", "eggs"])
        let milk = Getter(keyPath: ["shopping_cart", "items", "milk"])
        let dairy = Getter(keyPath: [eggs, milk], withFunc: {(args) in
            let numEggs = args[0].toSwift() as! Int
            let numDairy = args[1].toSwift() as! Int
            return Immutable.toState(numEggs + numDairy)
        })
        let result = Evaluator.evaluate(self.state, withGetter: dairy)
        XCTAssertEqual(3, result.toSwift() as! Int, "")
    }
    
    func testMixedGetterAndKeyPath() {
        let eggs = Getter(keyPath: ["shopping_cart", "items", "eggs"])
        let milk = Getter(keyPath: ["shopping_cart", "items", "milk"])
        let isLessThanBudget = Getter(keyPath: [eggs, milk, "shopping_cart", "budget"], withFunc: {(args) in
            let numEggs = args[0].toSwift() as! Int
            let numDairy = args[1].toSwift() as! Int
            let budget = args[2].toSwift() as! Int
            return Immutable.toState(numEggs + numDairy < budget)
        })
        let result = Evaluator.evaluate(self.state, withGetter: isLessThanBudget)
        XCTAssertTrue(result.toSwift() as! Bool, "")
        
        self.state = state.setIn(["shopping_cart", "items", "eggs"], withValue: Immutable.toState(5))
        let result2 = Evaluator.evaluate(self.state, withGetter: isLessThanBudget)
        XCTAssertFalse(result2.toSwift() as! Bool, "")
    }
}