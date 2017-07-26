//
//  ARChartHighlighter.swift
//  ARCharts
//
//  Created by Christopher Chute on 7/25/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import SceneKit
import Foundation

public class ARChartHighlighter {
    
    public enum AnimationStyle {
        case dropAway
        case fadeOut
    }
    
    public let animationStyle: AnimationStyle
    public let animationDuration: TimeInterval
    public var highlightedSeries: Int?
    public var highlightedIndex: Int?
    
    public init(animationStyle: AnimationStyle, animationDuration: TimeInterval) {
        self.animationStyle = animationStyle
        self.animationDuration = animationDuration
        self.highlightedIndex = nil
        self.highlightedSeries = nil
    }
    
    public func highlightBar(in barChart: ARBarChart, atIndex index: Int, forSeries series: Int) {
        if true {
            print("Highlight bar at index \(index) for series \(series)")
            return
        }
        var animations: [CABasicAnimation]
        var animatedAttributeKeys: [String]
        switch animationStyle {
        case .dropAway:
            animations = [
                CABasicAnimation.heightAnimation(withToValue: 0.0, duration: animationDuration, delay: nil),
                CABasicAnimation.yPositionAnimation(withToValue: 0.0, duration: animationDuration, delay: nil)
            ]
            animatedAttributeKeys = ["height", "position.y"]
        case .fadeOut:
            animations = [CABasicAnimation.opacityAnimation(withToValue: 0.0, duration: animationDuration, delay: nil)]
            animatedAttributeKeys = ["opacity"]
        }
        
        // Add animations to all bars except the one being highlighted
        for node in barChart.childNodes {
            if let barNode = node as? ARBar, let barBox = barNode.geometry as? SCNBox {
                if barNode.series != series || barNode.index != index {
                    for (animation, animatedAttributeKey) in zip(animations, animatedAttributeKeys) {
                        barBox.addAnimation(animation, forKey: animatedAttributeKey)
                    }
                }
            }
        }
        
        self.highlightedIndex = index
        self.highlightedSeries = series
    }
    
    public func unhighlightBar(in barChart: ARBarChart) {
        guard let index = self.highlightedIndex, let series = self.highlightedSeries else {
                return
        }
        
        print("Unhighlight bar at index \(index) for series \(series)")
        return
    }
    
}
