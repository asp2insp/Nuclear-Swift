//
//  Store.swift
//  Nuclear
//
//  Created by Josiah Gaskin on 5/3/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation

// Stores define how a certain domain of the application should respond to actions
// taken on the whole system.  They manage their own section of the entire app state
// and have no knowledge about the other parts of the application state.
public class Store {
    // A store represents its state by one large, nested dictionary
    typealias State = [String : AnyObject]
    // A handler takes the current state, a payload, and an action and
    // returns a modified state.
    typealias Handler = (State, Any, String) -> State
    
    private var handlers : [String : Handler] = [:]
    
    init() {
        initialize()
    }
    
    // This method is overriden by extending classses to setup message handlers
    // via `this.on` and to set up the initial state
    func initialize() {
        // extending classes override to setup action handlers
    }
    
    // Overridable method to get the initial state for this type of store
    func getInitialState() -> State {
        return [:]
    }
    
    // Takes a current state, action type, and payload, does the reaction,
    // and returns the new state
    func handle(state : State, action: String, payload: Any) -> State {
        if let handler = handlers[action] {
            return handler(state, payload, action)
        }
        return state
    }
    
    // Pure function which takes the current state and returns a new state
    // after the reset. May be overriden
    func handleReset(state: State) -> State {
        return self.getInitialState()
    }
    
    // Register a handler for an action. May only be called
    // once per action
    func on(action: String, handler: Handler) {
        handlers[action] = handler
    }
}

// States are compared by reference since they are treated as immutable
func ==(lhs: Store.State, rhs: Store.State) -> Bool {
    return unsafeAddressOf(lhs).hashValue == unsafeAddressOf(rhs).hashValue
}
