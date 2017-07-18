//
//  Int+random.swift
//  ARBarCharts
//
//  Created by Christopher Chute on 7/17/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import Foundation

extension Int {
    
    /// Get a random integer between `lowerBound` and `upperBound - 1`.
    public static func random(_ lowerBound: Int, _ upperBound: Int) -> Int {
        return Int(arc4random_uniform(UInt32(upperBound))) + lowerBound
    }
    
}

