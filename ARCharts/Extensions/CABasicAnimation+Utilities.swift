//
//  CABasicAnimation+Utilities.swift
//  ARCharts
//
//  Created by Christopher Chute on 7/25/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import Foundation


extension CABasicAnimation {
    static func heightAnimation(from fromValue: Float, to toValue: Float, duration: Double, delay: Double?) -> CABasicAnimation {
        let heightAnimation = CABasicAnimation(keyPath: "height")
        heightAnimation.beginTime = delay != nil ? CACurrentMediaTime() + delay! : 0.0
        heightAnimation.duration = duration
        heightAnimation.fromValue = fromValue
        heightAnimation.toValue = toValue
        heightAnimation.isRemovedOnCompletion = false
        heightAnimation.fillMode = kCAFillModeForwards
        heightAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        return heightAnimation
    }
    
    static func yPositionAnimation(from fromValue: Float, to toValue: Float, duration: Double, delay: Double?) -> CABasicAnimation {
        let yPositionAnimation = CABasicAnimation(keyPath: "position.y")
        yPositionAnimation.beginTime = delay != nil ? CACurrentMediaTime() + delay! : 0.0
        yPositionAnimation.duration = duration
        yPositionAnimation.fromValue = fromValue
        yPositionAnimation.toValue = toValue
        yPositionAnimation.isRemovedOnCompletion = false
        yPositionAnimation.fillMode = kCAFillModeForwards
        yPositionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        return yPositionAnimation
    }
    
    static func opacityAnimation(from fromValue: Float, to toValue: Float, duration: Double, delay: Double?) -> CABasicAnimation {
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.beginTime = delay != nil ? CACurrentMediaTime() + delay! : 0.0
        opacityAnimation.duration = duration
        opacityAnimation.fromValue = fromValue
        opacityAnimation.toValue = toValue
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.fillMode = kCAFillModeForwards
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        return opacityAnimation
    }
}
