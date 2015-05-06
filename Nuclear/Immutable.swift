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
            return val++
        }
    }
    
    // A State in its simplest form is a recursively defined
    // map. It can contain primitive data, and arrays or maps
    // where the key is a numerical index or a string, and the value
    // is also of type State
    public enum State {
        case Array([State], UInt)
        case Map([String:State], UInt)
        case Value(Any?, UInt)
        case None
    }
    
    
    public static func toState(x: Any) -> State {
        switch x {
        case let someArray as [Any]:
            return State.Array(convertArray(someArray), Tag.nextTag())
        case let someMap as [String:Any]:
            return State.Map(convertMap(someMap), Tag.nextTag())
        default:
            return State.Value(x, Tag.nextTag())
        }
    }
    
    static func convertArray(array: [Any]) -> [State] {
        return array.map({(x: Any) -> State in
            return self.toState(x)
        })
    }
    
    static func convertMap(map: [String:Any]) -> [String:State] {
        var asState : [String:State] = [:]
        for (key, val) in map {
            asState[key] = toState(val)
        }
        return asState
    }
    
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
    
    public static func convertArrayBack(array: [State]) -> [Any] {
        return []
    }
    
    public static func convertMapBack(map: [String:State]) -> [String:Any] {
        return [:]
    }
    
    // Get the value along the given keypath or return None if the value
    // does not exist
    public static func getIn(state: State, keyPath: [Any]) -> State {
        if keyPath.count == 0 {
            return state
        }
        let key = keyPath[0]
        switch state {
        case let .Array(array, tag):
            if let index = key as? Int {
                return getIn(array[index], keyPath: Array(dropFirst(keyPath)))
            } else {
                return .None
            }
        case let .Map(map, tag):
            if let name = key as? String {
                return getIn(map[name]!, keyPath: Array(dropFirst(keyPath))) ?? .None
            } else {
                return .None
            }
        default:
            return .None
        }
    }
    
    // Set or create the given value at the given keypath. Returns the modified state.
    public static func setIn(state: State, forKeyPath: [Any], withValue: State?) -> State {
        return mutateIn(state, atKeyPath: forKeyPath, mutator: {(state) in
            return withValue ?? State.None
        })
    }
    
    
    // Recurse down to the key at the given path (creating the path if necessary), and
    // return the mutated state will all nodes along the given key path marked as having been
    // updated
    static func mutateIn(state: State?, atKeyPath: [Any], mutator: (State?) -> State) -> State {
        if atKeyPath.count == 0 {
            // Apply the mutation, and mark the node as modified by updating the tag
            return markAsDirty(mutator(state))
        }

        let key = first(atKeyPath)
        let rest = Array(dropFirst(atKeyPath))
        switch state {
        case .None: // Create the rest of the keypath
            return createIn(rest, generator: mutator)
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
    static func createIn(keyPath: [Any], generator: (State?) -> State) -> State {
        if keyPath.count == 0 {
            // Apply the mutation, and mark the node as modified by updating the tag
            return markAsDirty(generator(nil))
        }
        let key = first(keyPath)
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
    
    static func markAsDirty(state: State) -> State {
        switch state {
        case .Value(let a, let tag):
            return .Value(a, Tag.nextTag())
        case .Map(let a, let tag):
            return .Map(a, Tag.nextTag())
        case .Array(let a, let tag):
            return .Array(a, Tag.nextTag())
        case .None:
            return .None
        }
    }
}

extension Immutable.State {
    func toSwift() -> Any {
        return Immutable.fromState(self)
    }
    
    func getIn(keyPath: [Any]) -> Immutable.State? {
        return Immutable.getIn(self, keyPath: keyPath)
    }
    
    func setIn(keyPath: [Any], withValue: Immutable.State?) -> Immutable.State {
        return Immutable.setIn(self, forKeyPath: keyPath, withValue: withValue)
    }
}

func ===(a: Immutable.State, b: Immutable.State) -> Bool {
    switch (a, b) {
    case (.Value(let a, let aTag), .Value(let b, let bTag)) where aTag == bTag: return true
    case (.Map(  let a, let aTag), .Map(  let b, let bTag)) where aTag == bTag: return true
    case (.Array(let a, let aTag), .Array(let b, let bTag)) where aTag == bTag: return true
    default: return false
    }
}
