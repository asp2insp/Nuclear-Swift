//
//  Immutable.swift
//  Nuclear
//
//  Created by Josiah Gaskin on 5/4/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation

public class Immutable {
    // A State in its simplest form is a recursively defined
    // map. It can contain primitive data, and arrays or maps
    // where the key is a numerical index or a string, and the value
    // is also of type State
    public enum State {
        case Array([State])
        case Map([String:State])
        case Value(Any?)
    }


    public static func toState(x: Any) -> State {
        switch x {
        case let someArray as [Any]:
            return State.Array(convertArray(someArray))
        case let someMap as [String:Any]:
            return State.Map(convertMap(someMap))
        default:
            return State.Value(x)
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

    public static func getIn(state: State, keyPath: [SimpleDep]) -> Any? {
        if keyPath.count == 0 {
            return state
        }
        let key = keyPath[0]
        switch state {
        case let .Array(array):
            switch key {
            case let SimpleDep.Index(index):
                return getIn(array[index], keyPath: Array(dropFirst(keyPath)))
            default:
                return nil
            }
        case let .Map(map):
            switch key {
            case let SimpleDep.Name(name):
                return getIn(map[name]!, keyPath: Array(dropFirst(keyPath))) ?? nil
            default:
                return nil
            }
        default:
            return nil
        }
    }
}