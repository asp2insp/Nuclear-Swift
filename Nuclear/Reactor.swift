//
//  Reactor.swift
//  Nuclear
//
//  Created by Josiah Gaskin on 5/9/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation

public class Reactor {
    public static let instance = Reactor()
    
    var debug : Bool = false
    var stateMap = Immutable.toState([:])
    var stores : [String:Store] = [:]
    
    // Dispatch an action to the appropriate handlers
    func dispatch(action: String, payload: Any) {
        // Let each core handle the action
        for (id, store) in self.stores {
            let prevState = self.stateMap.getIn([id])
            let newState = store.handle(prevState, action: action, payload: payload)
            self.stateMap = self.stateMap.setIn([id], withValue: newState)
        }
        if self.debug {
            NSLog("Reacting to \(action)")
        }
        self.responder?.onUpdate()
    }
    
    // Add a new store to the reactor
    func registerStore(id: String, store: Store) {
        self.stores[id] = store
        self.stateMap = self.stateMap.setIn([id], withValue: store.getInitialState())
        self.responder?.onUpdate()
    }
    
    // Restore all registered stores to their initial state
    func reset() {
        for (id, store) in self.stores {
            let prevState = self.stateMap.getIn([id])
            let resetState = store.handleReset(prevState)
            self.stateMap = self.stateMap.setIn([id], withValue: resetState)
        }
        self.responder?.onUpdate()
    }
    
    // Evaluate the given getter and return the immutable state
    func evaluate(getter: Getter) -> Immutable.State {
        return Evaluator.evaluate(self.stateMap, withGetter: getter)
    }
    
    // Evaluate the given getter and return the swift native representation
    func evaluateToSwift(getter: Getter) -> Any? {
        return evaluate(getter).toSwift()
    }
    
    // TODO Add binding
    var responder : ReactorResponder?
    
    // TODO Add autobinding
    // TODO Add caching for autobinding
}

public protocol ReactorResponder {
    func onUpdate()
}