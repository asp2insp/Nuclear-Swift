//
//  Getter.swift
//  Nuclear
//
//  Created by Josiah Gaskin on 5/4/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation

let IDENTITY = {(args: [Immutable.State]) -> Immutable.State in
    return args[0]
}

class Getter {
    let keyPath : [AnyObject]
    let compute : ([Immutable.State]) -> Immutable.State
    
    init (keyPath: [AnyObject]) {
        self.keyPath = keyPath
        self.compute = IDENTITY
    }
    
    init (keyPath: [AnyObject], withFunc: ([Immutable.State]) -> Immutable.State) {
        self.keyPath = keyPath
        self.compute = withFunc
    }
}
