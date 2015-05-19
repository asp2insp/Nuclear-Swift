//
//  Reactor.swift
//  Nuclear
//
//  Created by Josiah Gaskin on 5/9/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation

public class Reactor {
    public var debug : Bool = false
    private var stateMap = Immutable.toState([:])
    private var stores : [String:Store] = [:]
    private var changeObserver : ChangeObserver!
    
    init() {
        changeObserver = ChangeObserver(reactor: self)
    }
    
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
        self.changeObserver.notifyObservers(self.stateMap)
    }
    
    // Add a new store to the reactor
    func registerStore(id: String, store: Store) {
        self.stores[id] = store
        self.stateMap = self.stateMap.setIn([id], withValue: store.getInitialState())
        self.changeObserver.notifyObservers(self.stateMap)
    }
    
    // Observe the given getter. The result of the getter will be passed
    // to the handler, which will be invoked every time there's a new value.
    func observe(getter: Getter, handler: ((Immutable.State) -> ())) -> UInt {
        return self.changeObserver.onChange(getter, handler: handler)
    }
    
    // Unobserve the handlers bound to the given IDs.
    func unobserve(ids : UInt...) {
        for id in ids {
            self.changeObserver.removeHandler(id)
        }
    }
    
    // Restore all registered stores to their initial state
    func reset() {
        for (id, store) in self.stores {
            let prevState = self.stateMap.getIn([id])
            let resetState = store.handleReset(prevState)
            self.stateMap = self.stateMap.setIn([id], withValue: resetState)
        }
        changeObserver.handleReset()
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
    // TODO Add autobinding
    // TODO Add caching for autobinding
}
