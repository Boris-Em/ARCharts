//
//  AnimationManager.swift
//  ARCharts
//
//  Created by Boris Emorine on 7/24/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import Foundation
import SceneKit

public enum ARBarChartAnimationType {
    case fadeIn
    case progressiveFadeIn
    case grow
    case progressiveGrow
}

struct AnimationManager {
    
    var animationType: ARBarChartAnimationType
    var animationDuration: Double
    
    var baseDelay: Double {
        get {
            return self.animationDuration / 10.0
        }
    }
    
    init(animationType: ARBarChartAnimationType, animationDuration: Double) {
        self.animationType = animationType
        self.animationDuration = animationDuration
    }
    
    func addAnimation(toBarNode barNode: SCNNode, atIndex index: Int, withBarHeight barHeight: Float, _ yPosition: Float, _ opacity: Float) {
        guard let barBox = barNode.geometry else  {
            return
        }
        
        let delay = animationType == .progressiveGrow || animationType == .progressiveFadeIn ? self.baseDelay * Double(index) : nil
        
        if animationType == .grow || animationType == .progressiveGrow {
            let heightAnim = heightAnimation(withToValue: barHeight, duration: animationDuration, delay: delay)
            let yPositionAnim = yPositionAnimation(withToValue: yPosition, duration: animationDuration, delay: delay)
            barBox.addAnimation(heightAnim, forKey: "height")
            barNode.addAnimation(yPositionAnim, forKey: "position.y")
        } else if animationType == .fadeIn || animationType == .progressiveFadeIn {
            let fadeInAnim = fadeInAnimation(withToValue: opacity, duration: animationDuration, delay: delay)
            barNode.addAnimation(fadeInAnim, forKey: "opacity")
        }
    }
}

func heightAnimation(withToValue toValue: Float, duration: Double, delay: Double?) -> CABasicAnimation {
    let heightAnimation = CABasicAnimation(keyPath: "height")
    heightAnimation.beginTime = delay != nil ? CACurrentMediaTime() + delay! : 0.0
    heightAnimation.duration = duration
    heightAnimation.fromValue = 0.0
    heightAnimation.toValue = toValue
    heightAnimation.isRemovedOnCompletion = false
    heightAnimation.fillMode = kCAFillModeForwards
    heightAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    
    return heightAnimation
}

func yPositionAnimation(withToValue toValue: Float, duration: Double, delay: Double?) -> CABasicAnimation {
    let yPositionAnimation = CABasicAnimation(keyPath: "position.y")
    yPositionAnimation.beginTime = delay != nil ? CACurrentMediaTime() + delay! : 0.0
    yPositionAnimation.duration = duration
    yPositionAnimation.fromValue = 0.0
    yPositionAnimation.toValue = toValue
    yPositionAnimation.isRemovedOnCompletion = false
    yPositionAnimation.fillMode = kCAFillModeForwards
    yPositionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    
    return yPositionAnimation
}

func fadeInAnimation(withToValue toValue: Float, duration: Double, delay: Double?) -> CABasicAnimation {
    let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
    fadeInAnimation.beginTime = delay != nil ? CACurrentMediaTime() + delay! : 0.0
    fadeInAnimation.duration = duration
    fadeInAnimation.fromValue = 0.0
    fadeInAnimation.toValue = toValue
    fadeInAnimation.isRemovedOnCompletion = false
    fadeInAnimation.fillMode = kCAFillModeForwards
    fadeInAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    
    return fadeInAnimation
}
