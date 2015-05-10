//
//  Immutable.swift
//  Nuclear
//
//  Created by Josiah Gaskin on 5/4/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation

public class Immutable {
    // Each state is tagged with a unique ID (implemented as simple monotonically
    // increasing integer)
    class Tag {
        static var val : UInt = 0
        class func nextTag() -> UInt {
            if val == UInt.max {
                fatalError("RAN OUT OF IDS")
            }
            return ++val
        }
    }
    
    // A State in its simplest form is a recursively defined
    // map. It can contain primitive data, and arrays or maps
    // where the key is a numerical index or a string, and the value
    // is also of type State
    public enum State {
        case Array([State], UInt)
        case Map([String:State], UInt)
        case Value(AnyObject?, UInt)
        case None
        
        var hashValue : Int {
            switch self {
            case .Array(let _, let tag):
                return Int(tag)
            case .Map(let _, let tag):
                return Int(tag)
            case .Value(let _, let tag):
                return Int(tag)
            case .None:
                return 0
            }
        }
    }
    
    // Convert a native swift nested object to a nested immutable state
    public static func toState(x: AnyObject) -> State {
        switch x {
        case let alreadyState as State:
            return alreadyState
        case let someArray as [AnyObject]:
            return State.Array(convertArray(someArray), Tag.nextTag())
        case let someMap as [String:AnyObject]:
            return State.Map(convertMap(someMap), Tag.nextTag())
        default:
            return State.Value(x, Tag.nextTag())
        }
    }
    
    static func convertArray(array: [AnyObject]) -> [State] {
        return array.map({(x: AnyObject) -> State in
            return self.toState(x)
        })
    }
    
    static func convertMap(map: [String:AnyObject]) -> [String:State] {
        var asState : [String:State] = [:]
        for (key, val) in map {
            asState[key] = toState(val)
        }
        return asState
    }
    
    // Convert from an immutable state object to a vanilla swift object
    // fromState converts deeply
    public static func fromState(state: State?) -> Any? {
        switch state {
        case .Some(let someState):
            switch someState {
            case .Value(let v, let tag):
                return v
            case .Array(let array, let tag):
                return convertArrayBack(array)
            case .Map(let map, let tag):
                return convertMapBack(map)
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public static func convertArrayBack(array: [State]) -> [Any?] {
        return array.map({(state) in
            return self.fromState(state)
        })
    }
    
    public static func convertMapBack(map: [String:State]) -> [String:Any?] {
        var newMap : [String:Any?] = [:]
        for (key, state) in map {
            newMap[key] = fromState(state)
        }
        return newMap
    }
    
    // Get the value along the given keypath or return None if the value
    // does not exist
    public static func getIn(state: State, keyPath: [AnyObject]) -> State {
        if keyPath.count == 0 {
            return state
        }
        let key : AnyObject = keyPath[0]
        switch state {
        case let .Array(array, tag):
            if let index = key as? Int {
                if index < array.count {
                    return self.getIn(array[index], keyPath: Array(dropFirst(keyPath)))
                }
            }
            return .None
        case let .Map(map, tag):
            if let name = key as? String {
                if let val = map[name] {
                    return getIn(val, keyPath: Array(dropFirst(keyPath)))
                }
            }
            return .None
        default:
            return .None
        }
    }
    
    // Set or create the given value at the given keypath. Returns the modified state.
    public static func setIn(state: State, forKeyPath: [AnyObject], withValue: State?) -> State {
        return mutateIn(state, atKeyPath: forKeyPath, mutator: {(state) in
            return withValue ?? State.None
        })
    }
    
    
    // Recurse down to the key at the given path (creating the path if necessary), and
    // return the mutated state will all nodes along the given key path marked as having been
    // updated
    static func mutateIn(state: State?, atKeyPath: [AnyObject], mutator: (State?) -> State) -> State {
        if atKeyPath.count == 0 {
            // Apply the mutation, and mark the node as modified by updating the tag
            return markAsDirty(mutator(state))
        }

        let key : AnyObject = first(atKeyPath)!
        let rest = Array(dropFirst(atKeyPath))
        switch state {
        case .None: // Create the rest of the keypath
            return createIn(atKeyPath, generator: mutator)
        case .Some(let someState):
            switch someState {
            case var .Array(array, tag):
                if let index = key as? Int {
                    while array.count <= index {
                        array.append(State.None)
                    }
                    array[index] = mutateIn(array[index], atKeyPath: rest, mutator: mutator)
                    return State.Array(array, Tag.nextTag())
                } else {
                    fatalError("Tried to set a named key inside an array. Check your keypath")
                }
            case var .Map(map, tag):
                if let name = key as? String {
                    map[name] = mutateIn(map[name], atKeyPath: rest, mutator: mutator)
                    return State.Map(map, Tag.nextTag())
                } else {
                    fatalError("Tried to set an index key inside a map. Check your keypath")
                }
            case .None:
                // Replace this none with the tree created along the rest of the keypath
                return createIn(rest, generator: mutator)
            case .Value:
                fatalError("Tried to replace a single value with a deep state. Check your keypath")
            }

        }
    }
    
    // Create the state hierarchy that matches the keypath.
    static func createIn(keyPath: [AnyObject], generator: (State?) -> State) -> State {
        if keyPath.count == 0 {
            // Apply the mutation, and mark the node as modified by updating the tag
            return markAsDirty(generator(nil))
        }
        let key : AnyObject = first(keyPath)!
        let rest = Array(dropFirst(keyPath))
        if let index = key as? Int {
            var array : [State] = []
            for var i = 0; i < index; i++ {
                array.append(State.None)
            }
            array.append(createIn(rest, generator: generator))
            return State.Array(array, Tag.nextTag())
        } else if let name = key as? String {
            var map : [String:State] = [:]
            map[name] = createIn(rest, generator: generator)
            return State.Map(map, Tag.nextTag())
        }
        fatalError("Your keypath contains something other than strings and integer indices")
    }
    
    // Apply the given function to all
    static func mapOver(state: State, f: (Immutable.State, AnyObject) -> Immutable.State) -> State {
        switch state {
        case .None:
            return f(state, -1)
        case .Value:
            return markAsDirty(f(state, -1))
        case .Map(let m, let tag):
            var map : [String:State] = [:]
            for (key, val) in m {
                map[key] = markAsDirty(f(val, key))
            }
            return .Map(map, Tag.nextTag())
        case .Array(let a, let tag):
            var array : [State] = []
            for var i = 0; i < a.count; i++ {
                array.append(markAsDirty(f(a[i], i)))
            }
            return .Array(array, Tag.nextTag())
        }
    }
    
    // Filter by the given predicate
    static func filterOver(state: State, f: (Immutable.State) -> Bool) -> State {
        switch state {
        case .None:
            return .None
        case .Value:
            return f(state) ? state : .None
        case .Map(let m, let tag):
            var map : [String:State] = [:]
            for (key, val) in m {
                if (f(val)) {
                    map[key] = val
                }
            }
            return .Map(map, Tag.nextTag())
        case .Array(let a, let tag):
            let array = a.filter(f)
            return .Array(array, Tag.nextTag())
        }
    }
    
    // Reduce the given state
    static func reduceOver(state: State, f: (State, State) -> State, initial: State) -> State {
        switch state {
        case .None:
            return .None
        case .Value:
            return markAsDirty(f(initial, state))
        case .Map(let m, let tag):
            var current = initial
            for (key, val) in m {
                current = f(current, val)
            }
            return markAsDirty(current)
        case .Array(let a, let tag):
            var current = initial
            for var i = 0; i < a.count; i++ {
                current = f(current, a[i])
            }
            return markAsDirty(current)
        }
    }
    
    // Push the given item. Only valid for arrays
    static func push(state: State, newVal: State) -> State {
        switch state {
        case .None:
            return .None
        case .Value:
            return state
        case .Map:
            return state
        case .Array(var a, let tag):
            a.append(newVal)
            return .Array(a, Tag.nextTag())
        }
    }
    
    // Generate a new tag for the state to mark it as changed
    static func markAsDirty(state: State) -> State {
        switch state {
        case .Value(let a, _):
            return .Value(a, Tag.nextTag())
        case .Map(let a, _):
            return .Map(a, Tag.nextTag())
        case .Array(let a, _):
            return .Array(a, Tag.nextTag())
        case .None:
            return .None
        }
    }
    
    static func count(state: State) -> Int {
        switch state {
        case .Value:
            return 1
        case .Map(let m, _):
            return m.count
        case .Array(let a, _):
            return a.count
        case .None:
            return 0
        }
    }
}

extension Immutable.State {
    func toSwift() -> Any? {
        return Immutable.fromState(self)
    }
    
    func getIn(keyPath: [AnyObject]) -> Immutable.State {
        return Immutable.getIn(self, keyPath: keyPath)
    }
    
    func setIn(keyPath: [AnyObject], withValue: Immutable.State?) -> Immutable.State {
        return Immutable.setIn(self, forKeyPath: keyPath, withValue: withValue)
    }
    
    func mutateIn(keyPath: [AnyObject], withMutator: (Immutable.State?) -> Immutable.State) -> Immutable.State {
        return Immutable.mutateIn(self, atKeyPath: keyPath, mutator: withMutator)
    }
    
    func map(f: (Immutable.State, AnyObject) -> Immutable.State) -> Immutable.State {
        return Immutable.mapOver(self, f: f)
    }
    
    func filter(predicate: (Immutable.State) -> Bool) -> Immutable.State {
        return Immutable.filterOver(self, f: predicate)
    }
    
    func reduce(initial: Immutable.State, f: (initial: Immutable.State, next: Immutable.State) -> Immutable.State) -> Immutable.State {
        return Immutable.reduceOver(self, f: f, initial: initial)
    }
    
    func push(val: Immutable.State) -> Immutable.State {
        return Immutable.push(self, newVal: val)
    }
    
    var count : Int {
        return Immutable.count(self)
    }
    
    // Allow us to print the state for debugging
    func description() -> String {
        switch self {
        case .Value(let v, let tag):
            return "(Value)"
        case .None:
            return "(None)"
        case .Array(let array, _):
            let last = array.last!
            let recursive = array.reduce("", combine: { (sum, item) -> String in
                let maybeComma = (item === last) ? "" : ", "
                return "\(sum)\(item.description())\(maybeComma)"
            })
            return "(Array [\(recursive)])"
        case .Map(let map, let tag):
            var inner = "(Map {"
            let last = map.count
            var i = 0
            for (key,state) in map {
                let maybeComma = (++i == last) ? "" : ", "
                inner = "\(inner)\(key) : \(state.description())\(maybeComma)"
            }
            return "\(inner)})"
        }
    }
}

func ===(a: Immutable.State, b: Immutable.State) -> Bool {
    switch (a, b) {
    case (.Value(_, let aTag), .Value(_, let bTag)):
        return aTag == bTag
    case (.Map(_, let aTag), .Map(_, let bTag)):
        return aTag == bTag
    case (.Array(_, let aTag), .Array(_, let bTag)):
        return aTag == bTag
    case (.None, .None):
        return true
    default:
        return false
    }
}
