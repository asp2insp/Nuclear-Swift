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
    let exp1: Immutable.State = Immutable.toState(["id": 1, "proj_id": 10])
    let exp2: Immutable.State = Immutable.toState(["id": 2, "proj_id": 10])
    let exp3: Immutable.State = Immutable.toState(["id": 3, "proj_id": 11])
    
    class ExperimentStore : Store {
        override func getInitialState() -> Immutable.State {
            return Immutable.toState(["experiments": []])
        }
        
        override func initialize() {
            self.on("addExperiments", handler: {(state, payload, action) -> Immutable.State in
                let newExperiments = payload as! [Immutable.State]
                return state.mutateIn(["experiments"], withMutator: { (exps) in
                    var expsNew = exps ?? Immutable.toState([])
                    for newExp in newExperiments {
                        expsNew = expsNew.push(newExp)
                    }
                    return expsNew
                })
            })
            self.on("removeExperiment", handler: {(state, payload, action) in
                let targetId = payload as! Int
                return state.mutateIn(["experiments"], withMutator: {(maybeExps) in
                    let exps = maybeExps ?? Immutable.toState([])
                    return exps.filter({(e) in
                        return e.getIn(["id"]).toSwift() as! Int != targetId
                    })
                })
            })
        }
    }

    var store : Store = Store()
    var initial : Immutable.State = Immutable.State.None
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
        let results = newState.getIn(["experiments"])
        XCTAssertEqual(3, results.count, "We should have inserted 3 experiments")
        XCTAssertTrue(results.getIn([0]) === experiments[0], "")
        XCTAssertTrue(results.getIn([1]) === experiments[1], "")
        XCTAssertTrue(results.getIn([2]) === experiments[2], "")
    }

    // Should handle removing experiments
    func testHandlesRemoveExperiment() {
        let experiments = [exp1, exp2, exp3]
        let newState = store.handle(initial, action: "addExperiments", payload: experiments)
        let finalState = store.handle(newState, action: "removeExperiment", payload: 2)
        
        let results = finalState.getIn(["experiments"])
        XCTAssertEqual(2, results.count, "We should have inserted 3 experiments and removed 1")
        XCTAssertTrue(results.getIn([0]) === exp1, "We should not have removed the first one")
        XCTAssertTrue(results.getIn([1]) === exp3, "We should have removed the second one")
    }
}