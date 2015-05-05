//
//  Getter.swift
//  Nuclear
//
//  Created by Josiah Gaskin on 5/4/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation

public typealias Compute = (Any...) -> Any

let IDENTITY = {(x: Any...) -> Any in
    return x
}

public enum SimpleDep {
    case Name(String)
    case Index(Int)
}

public enum Dep {
    case Simple(SimpleDep)
    case Recursive([Dep])
    case Func(Compute)
}

public typealias Getter = [Dep]

public func fromKeyPath(keyPath: Getter) -> Getter {
    var getter = keyPath
    getter.append(Dep.Func(IDENTITY))
    return getter
}

// A getter is either a full getter (with function)
// or a keypath (no function)
public func isGetter(toTest: Getter) -> Bool {
    switch toTest[-1] {
    case .Func:
        return true
    default:
        return false
    }
}

public func isKeyPath(toTest: Getter) -> Bool {
    return !isGetter(toTest)
}