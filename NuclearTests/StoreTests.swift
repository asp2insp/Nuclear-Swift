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
    let exp1: Store.State = ["id": 1, "proj_id": 10]
    let exp2: Store.State = ["id": 2, "proj_id": 10]
    let exp3: Store.State = ["id": 3, "proj_id": 11]
    
    class ExperimentStore : Store {
        override func getInitialState() -> State {
            return ["experiments": []]
        }
        
        override func initialize() {
            self.on("addExperiments", handler: {(state: State, payload: Any, action: String) -> State in
                var newState = state
                if let experiments = payload as? [State] {
                    var targetExperiments = newState["experiments"] as! [State]
                    for exp in experiments {
                        targetExperiments.append(exp)
                    }
                    newState.updateValue(targetExperiments, forKey: "experiments")
                }
                return newState
            })
            self.on("removeExperiment", handler: {(state: State, payload: Any, action: String) -> State in
                var newState = state
                var experiments = newState["experiments"] as! [State]
                if let id = payload as? Int {
                    for var i = 0; i < experiments.count; i++ {
                        if experiments[i]["id"] as! Int == id {
                            experiments.removeAtIndex(i)
                            break
                        }
                    }
                    newState.updateValue(experiments, forKey: "experiments")
                }
                return newState
            })
        }
    }

    var store : Store = Store()
    var initial : Store.State = Store.State()
    override func setUp() {
        super.setUp()
        store = ExperimentStore()
        initial = store.getInitialState()
        store.handleReset(initial)
    }
    
    // Should handle adding experiments
    func testHandlesAddExperiments() {
        let experiments = [exp1, exp2, exp3]
        let newState = store.handle(initial, action: "addExperiments", payload: experiments)
        let results = newState["experiments"] as! [Store.State]
        XCTAssertEqual(3, results.count, "We should have inserted 3 experiments")
        XCTAssertTrue(results[0] == experiments[0], "Contents in state should reflect input")
        XCTAssertTrue(results[1] == experiments[1], "Contents in state should reflect input")
        XCTAssertTrue(results[2] == experiments[2], "Contents in state should reflect input")
    }
    
    // Should handle removing experiments
    func testHandlesRemoveExperiment() {
        let experiments = [exp1, exp2, exp3]
        let newState = store.handle(initial, action: "addExperiments", payload: experiments)
        let finalState = store.handle(newState, action: "removeExperiment", payload: 2)
        
        let results = finalState["experiments"] as! [Store.State]
        XCTAssertEqual(2, results.count, "We should have inserted 3 experiments and removed 1")
        XCTAssertTrue(results[0] == exp1, "We should not have removed the first one")
        XCTAssertTrue(results[1] == exp3, "We should have removed the second one")
    }
}