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
                return state
            })
            self.on("removeExperiment", handler: {(state: State, payload: Any, action: String) -> State in
                return state
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
    
    
    func testHandlesAddExperiments() {
        let experiments = [exp1, exp2, exp3]
        let newState = store.handle(initial, action: "addExperiments", payload: experiments)
        let results = newState["experiments"] as! [Store.State]
        XCTAssertTrue(results[0] == experiments[0], "boo")
    }
}