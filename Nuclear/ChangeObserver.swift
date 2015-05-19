//
//  ChangeObserver.swift
//  Nuclear
//
//  Created by Josiah Gaskin on 5/14/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation

public class ChangeObserver {
    let tagger = Tag()
    var observers : [Getter:[UInt:((Immutable.State) -> ())]] = [:]
    
    // TODO: move this caching into Evaluator to match Nuclear-JS
    var lastKnownStates : [Int:[Int]] = [:]
    var reactor : Reactor!
    
    init(reactor: Reactor) {
        self.reactor = reactor
    }
    
    func notifyObservers(newState: Immutable.State) {
        for (getter, handlers) in observers {
            // We require that the getter compute function be pure, so if the inputs
            // haven't changed, we don't re-run the getter
            let newInputValueTags = currentTagsForGetter(getter)
            let currentValues = lastKnownStates[getter.hashValue] ?? []
            
            if tagsEqual(currentValues, other: newInputValueTags) {
                if reactor.debug { NSLog("No changes, skipping handlers") }
                continue // If the state hasn't changed, no need to update
            }
            lastKnownStates[getter.hashValue] = newInputValueTags
            for (id, handler) in handlers {
                handler(reactor.evaluate(getter))
            }
            postNotificationForGetter(getter)
        }
    }
    
    private func tagsEqual(one: [Int], other: [Int]) -> Bool {
        if one.count != other.count {
            return false
        }
        for var i = 0; i < other.count; i++ {
            if one[i] != other[i] {
                return false
            }
        }
        return true
    }
    
    private func currentTagsForGetter(getter: Getter) -> [Int] {
        var newInputValueTags : [Int] = getter.recursives.map({(g) -> Int in
            return self.reactor.evaluate(g).hashValue
        })
        newInputValueTags.append(reactor.evaluate(getter.keysOnly).hashValue)
        return newInputValueTags
    }
    
    private func postNotificationForGetter(getter: Getter) {
        let notification = NSNotification(name: getter.nameForNSNotification, object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    func onChange(getter: Getter, handler: ((Immutable.State) -> ())) -> UInt {
        if self.observers[getter] == nil {
            self.observers[getter] = [:]
        }
        let id = tagger.nextTag()
        self.observers[getter]![id] = handler
        self.lastKnownStates[getter.hashValue] = currentTagsForGetter(getter)
        return id
    }
    
    func removeHandler(id: UInt) {
        for (getter, var handlers) in self.observers {
            handlers.removeValueForKey(id)
            self.observers[getter] = handlers
        }
    }
    
    func handleReset() {
        lastKnownStates.removeAll(keepCapacity: true)
        observers.removeAll(keepCapacity: true)
    }
}