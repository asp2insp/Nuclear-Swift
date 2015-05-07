//
//  StoreTests.swift
//  Nuclear
//
//  Created by Josiah Gaskin on 5/3/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import UIKit
import XCTest

class StoreTests: XCTestCase {
//    let exp1: Immutable.State = Immutable.toState(["id": 1, "proj_id": 10])
//    let exp2: Immutable.State = Immutable.toState(["id": 2, "proj_id": 10])
//    let exp3: Immutable.State = Immutable.toState(["id": 3, "proj_id": 11])
//    
//    class ExperimentStore : Store {
//        override func getInitialState() -> Immutable.State {
//            return Immutable.toState(["experiments": []])
//        }
//        
//        override func initialize() {
//            self.on("addExperiments", handler: {(state, payload, action) in
//                var newState = state
//                if let experiments = payload as? [Immutable.State] {
//                    var targetExperiments = Immutable.getIn(newState, keyPath: ["experiments"]) as! [Immutable.State]
//                    for exp in experiments {
//                        targetExperiments.append(exp)
//                    }
//                    newState = Immutable.setIn(newState, forKeyPath: ["experiments"], withValue: Immutable.toState(targetExperiments))
//                }
//                return newState
//            })
//            self.on("removeExperiment", handler: {(state, payload, action) in
//                var newState = state
//                let experimentsState = Immutable.getIn(newState, keyPath: ["experiments"])
//
//                if let id = payload as? Int {
//                    for var i = 0; i < experiments.count; i++ {
//                        if experiments[i]["id"] as! Int == id {
//                            experiments.removeAtIndex(i)
//                            break
//                        }
//                    }
//                    newState.updateValue(experiments, forKey: "experiments")
//                }
//                return newState
//            })
//        }
//    }
//
//    var store : Store = Store()
//    var initial : Immutable.State?
//    override func setUp() {
//        super.setUp()
//        store = ExperimentStore()
//        initial = store.getInitialState()
//        store.handleReset(initial!)
//    }
//    
//    // Should handle adding experiments
//    func testHandlesAddExperiments() {
//        let experiments = [exp1, exp2, exp3]
//        let newState = store.handle(initial!, action: "addExperiments", payload: experiments)
//        let results = Immutable.getIn(newState, keyPath: ["experiments"])
//        XCTAssertEqual(3, results.count, "We should have inserted 3 experiments")
//        XCTAssertTrue(results[0] == experiments[0], "Contents in state should reflect input")
//        XCTAssertTrue(results[1] == experiments[1], "Contents in state should reflect input")
//        XCTAssertTrue(results[2] == experiments[2], "Contents in state should reflect input")
//    }
//    
//    // Should handle removing experiments
//    func testHandlesRemoveExperiment() {
//        let experiments = [exp1, exp2, exp3]
//        let newState = store.handle(initial!, action: "addExperiments", payload: experiments)
//        let finalState = store.handle(newState, action: "removeExperiment", payload: 2)
//        
//        let results = Immutable.getIn(finalState, ["experiments"] as [SimpleDep]) as! [Immutable.State]
//        XCTAssertEqual(2, results.count, "We should have inserted 3 experiments and removed 1")
//        XCTAssertTrue(results[0] == exp1, "We should not have removed the first one")
//        XCTAssertTrue(results[1] == exp3, "We should have removed the second one")
//    }
}