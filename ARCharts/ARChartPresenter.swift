//
//  ARChartPresenter.swift
//  ARCharts
//
//  Created by Boris Emorine on 7/24/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import Foundation
import SceneKit


public struct ARChartPresenter {
    
    public enum AnimationType {
        case fade
        case progressiveFade
        case grow
        case progressiveGrow
    }
    
    var animationType: AnimationType
    var animationDuration: Double
    
    init(animationType: AnimationType, animationDuration: Double) {
        self.animationType = animationType
        self.animationDuration = animationDuration
    }
    
    func addAnimation(to barNode: ARBarChartBar, in barChart: ARBarChart) {
        guard let barBox = barNode.geometry else  {
            return
        }
        
        var delay: Double?
        if animationType == .progressiveGrow || animationType == .progressiveFade {
            let numberOfIndices = barChart.dataSource!.barChart(barChart, numberOfValuesInSeries: barNode.series)
            delay = animationDuration * Double(barNode.index) / Double(numberOfIndices)
        }
        
        if animationType == .grow || animationType == .progressiveGrow {
            let heightAnimation = CABasicAnimation.animation(forKey: "height",
                                                             from: 0.0,
                                                             to: barNode.finalHeight,
                                                             duration: animationDuration,
                                                             delay: delay)
            let yPositionAnimation = CABasicAnimation.animation(forKey: "position.y",
                                                                from: 0.0,
                                                                to: 0.5 * barNode.finalHeight,
                                                                duration: animationDuration,
                                                                delay: delay)
            barBox.addAnimation(heightAnimation, forKey: "height")
            barNode.addAnimation(yPositionAnimation, forKey: "position.y")
        } else if animationType == .fade || animationType == .progressiveFade {
            let fadeInAnimation = CABasicAnimation.animation(forKey: "opacity",
                                                             from: 0.0,
                                                             to: barNode.finalOpacity,
                                                             duration: animationDuration,
                                                             delay: delay)
            barNode.addAnimation(fadeInAnimation, forKey: "opacity")
        }
    }
    
}
