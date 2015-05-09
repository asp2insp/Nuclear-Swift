//
//  ReactorTests.swift
//  Nuclear
//
//  Created by Josiah Gaskin on 5/9/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.

import XCTest

class ReactorTests: XCTestCase {
    
    class itemStore : Store {
        override func getInitialState() -> Immutable.State {
            return Immutable.toState(["all":[]])
        }
        
        override func initialize() {
            self.on("addItem", handler: {(state, payload, action) -> Immutable.State in
                let item = payload as! [String:NSObject]
                let name : AnyObject = item["name"] ?? "unknown"
                let price : AnyObject = item["price"] ?? -1
                return state.mutateIn(["all"], withMutator: { (items) in
                    return items!.push(Immutable.toState(["name": name, "price": price]))
                })
            })
        }
    }
    
    class taxPercentStore : Store {
        override func getInitialState() -> Immutable.State {
            return Immutable.toState(0)
        }
        
        override func initialize() {
            self.on("setTax", handler: {(state, payload, action) -> Immutable.State in
                let tax = payload as! Int
                return Immutable.toState(tax)
            })
        }
    }
    var reactor : Reactor = Reactor()
    var subtotalGetter : Getter = Getter(keyPath: [])
    var taxGetter : Getter = Getter(keyPath: [])
    var totalGetter : Getter = Getter(keyPath: [])
    override func setUp() {
        super.setUp()
        
        
        reactor = Reactor()
        subtotalGetter = Getter(keyPath: ["items", "all"], withFunc: {(items) in
            return items[0].reduce(Immutable.toState(0), f: {(sum, one)  in
                let current = sum.toSwift() as! Int
                let nextPrice = one.getIn(["price"]).toSwift() as! Int
                return Immutable.toState(current + nextPrice)
            })
        })
        
        taxGetter = Getter(keyPath: [subtotalGetter, "taxPercent"], withFunc: {(args) in
            let subtotal = args[0].toSwift() as! Double
            let tax = args[1].toSwift() as! Double
            let total = subtotal * (tax * 0.01)
            return Immutable.toState(total)
        })
        
        totalGetter = Getter(keyPath: [subtotalGetter, taxGetter], withFunc: {(args) in
            let subtotal = args[0].toSwift() as! Double
            let tax = args[1].toSwift() as! Double
            let totalCents = (subtotal + tax) * 100
            return Immutable.toState(round(totalCents) / 100)
        })

        reactor.registerStore("items", store: itemStore())
        reactor.registerStore("taxPercent", store: taxPercentStore())
    }
    
    // Test initialization
    func testInit() {
        let initialTax = reactor.evaluateToSwift(Getter(keyPath: ["taxPercent"])) as! Int
        XCTAssertEqual(0, initialTax, "")
        let emptyCart = reactor.evaluateToSwift(Getter(keyPath: ["items", "all"])) as! [Any?]
        XCTAssertEqual(0, emptyCart.count, "")
    }
    
    // Test whole retrieval
    func testFullRetrieval() {
        let wholeState = reactor.evaluate(Getter(keyPath: []))
        XCTAssertEqual(0, wholeState.getIn(["taxPercent"]).toSwift() as! Int, "")
    }
    
    // Test whole evaluation
    func testWholeEval() {
        let wholeMap : [String:Any?] = reactor.evaluateToSwift(Getter(keyPath: [])) as! [String:Any?]
        let taxPercent = wholeMap["taxPercent"] as! Int
        XCTAssertEqual(0, taxPercent, "")
    }
    
    // Test dispatch actions
    func testActions() {
        reactor.dispatch("addItem", payload: ["name": "item 1", "price": 10])
        XCTAssertEqual(0.0, reactor.evaluateToSwift(taxGetter) as! Double, "")
        XCTAssertEqual(10.0, reactor.evaluateToSwift(totalGetter) as! Double, "")
        
        reactor.dispatch("setTax", payload: 5)
        XCTAssertEqual(0.5, reactor.evaluateToSwift(taxGetter) as! Double, "")
        XCTAssertEqual(10.5, reactor.evaluateToSwift(totalGetter) as! Double, "")
    }
    
    func testReset() {
        reactor.dispatch("addItem", payload: ["name": "item 1", "price": 10])
        reactor.dispatch("setTax", payload: 5)
        
        let newTax = reactor.evaluateToSwift(Getter(keyPath: ["taxPercent"])) as! Int
        XCTAssertEqual(5, newTax, "")
        let cart = reactor.evaluateToSwift(Getter(keyPath: ["items", "all"])) as! [Any?]
        XCTAssertEqual(1, cart.count, "")
        
        reactor.reset()
        let initialTax = reactor.evaluateToSwift(Getter(keyPath: ["taxPercent"])) as! Int
        XCTAssertEqual(0, initialTax, "")
        let emptyCart = reactor.evaluateToSwift(Getter(keyPath: ["items", "all"])) as! [Any?]
        XCTAssertEqual(0, emptyCart.count, "")
    }
}