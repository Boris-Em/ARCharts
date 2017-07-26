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
    
    func addAnimation(toBarNode barNode: SCNNode, atIndex index: Int, withBarHeight barHeight: Float, _ opacity: Float) {
        guard let barBox = barNode.geometry else  {
            return
        }
        
        var delay: Double?
        if animationType == .progressiveGrow || animationType == .progressiveFadeIn {
            delay = 0.1 * Double(index) * animationDuration
        }
        
        if animationType == .grow || animationType == .progressiveGrow {
            let heightAnimation = CABasicAnimation.heightAnimation(from: 0.0, to: barHeight, duration: animationDuration, delay: delay)
            let yPositionAnimation = CABasicAnimation.yPositionAnimation(from: 0.0, to: 0.5 * barHeight, duration: animationDuration, delay: delay)
            barBox.addAnimation(heightAnimation, forKey: "height")
            barNode.addAnimation(yPositionAnimation, forKey: "position.y")
        } else if animationType == .fadeIn || animationType == .progressiveFadeIn {
            let fadeInAnimation = CABasicAnimation.opacityAnimation(from: 0.0, to: opacity, duration: animationDuration, delay: delay)
            barNode.addAnimation(fadeInAnimation, forKey: "opacity")
        }
    }
    
}
