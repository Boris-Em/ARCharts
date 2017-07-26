//
//  CABasicAnimation+Utilities.swift
//  ARCharts
//
//  Created by Christopher Chute on 7/25/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import Foundation


extension CABasicAnimation {
    
    static func animation(forKey keyPath: String,
                          from fromValue: Float,
                          to toValue: Float,
                          duration: Double,
                          delay: Double?) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.beginTime = delay != nil ? CACurrentMediaTime() + delay! : 0.0
        animation.duration = duration
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        return animation
    }
    
}
