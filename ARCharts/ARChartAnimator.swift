//
//  ARChartAnimator.swift
//  ARCharts
//
//  Created by Boris Emorine on 7/24/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import Foundation
import SceneKit


public struct ARChartAnimator {
    
    public enum AnimationType {
        case fadeIn
        case progressiveFadeIn
        case grow
        case progressiveGrow
    }
    
    var animationType: AnimationType
    var animationDuration: Double
    
    init(animationType: AnimationType, animationDuration: Double) {
        self.animationType = animationType
        self.animationDuration = animationDuration
    }
    
    func addAnimation(toBarNode barNode: SCNNode, atIndex index: Int, withBarHeight barHeight: Float, _ yPosition: Float, _ opacity: Float) {
        guard let barBox = barNode.geometry else  {
            return
        }
        
        var delay: Double?
        if animationType == .progressiveGrow || animationType == .progressiveFadeIn {
            delay = 0.1 * Double(index) * animationDuration
        }
        
        if animationType == .grow || animationType == .progressiveGrow {
            let heightAnimation = CABasicAnimation.heightAnimation(withToValue: barHeight,
                                                                   duration: animationDuration,
                                                                   delay: delay)
            let yPositionAnimation = CABasicAnimation.yPositionAnimation(withToValue: yPosition,
                                                                         duration: animationDuration,
                                                                         delay: delay)
            barBox.addAnimation(heightAnimation, forKey: "height")
            barNode.addAnimation(yPositionAnimation, forKey: "position.y")
        } else if animationType == .fadeIn || animationType == .progressiveFadeIn {
            let fadeInAnim = CABasicAnimation.opacityAnimation(withToValue: opacity,
                                                               duration: animationDuration,
                                                               delay: delay)
            barNode.addAnimation(fadeInAnim, forKey: "opacity")
        }
    }
    
}
