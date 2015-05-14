//
//  Tag.swift
//  Nuclear
//
//  Created by Josiah Gaskin on 5/14/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation

// Each state is tagged with a unique ID (implemented as simple monotonically
// increasing integer)
class Tag {
    private var val : UInt = 0
    func nextTag() -> UInt {
        if val == UInt.max {
            fatalError("RAN OUT OF IDS")
            // TODO: Add GC/Compaction of tags
        }
        return ++val
    }
}