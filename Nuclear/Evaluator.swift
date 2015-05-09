//
//  Evaluator.swift
//  Nuclear
//
//  Created by Josiah Gaskin on 5/4/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation

public class Evaluator {
    
    class func evaluate(state: Immutable.State, withGetter: Getter) -> Immutable.State {
        var args = recursiveParts(withGetter).map({(getter) in
            return self.evaluate(state, withGetter: getter)
        })
        args.append(state.getIn(self.keyPathParts(withGetter)))
        return withGetter.compute(args)
    }
    
    class func recursiveParts(getter: Getter) -> [Getter] {
        return getter.keyPath.filter({(maybeGetter) in
            return maybeGetter is Getter
        }) as! [Getter]
    }
    
    class func keyPathParts(getter: Getter) -> [AnyObject] {
        return getter.keyPath.filter({(maybeGetter) in
            return !(maybeGetter is Getter)
        })
    }
    
    
    // TODO: Add caching
}