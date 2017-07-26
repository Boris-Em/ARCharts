//
//  ARChartHighlighter.swift
//  ARCharts
//
//  Created by Christopher Chute on 7/25/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import SceneKit
import Foundation

public struct ARChartHighlighter {
    
    public enum AnimationStyle {
        case shrink
        case fade
    }
    
    public let animationStyle: AnimationStyle
    public let animationDuration: TimeInterval
    public var highlightedSeries: Int?
    public var highlightedIndex: Int?
    
    private let defaultFadedOpacity: Float = 0.15
    
    public init(animationStyle: AnimationStyle, animationDuration: TimeInterval) {
        self.animationStyle = animationStyle
        self.animationDuration = animationDuration
        self.highlightedIndex = nil
        self.highlightedSeries = nil
    }
    
    /**
     * Add highlighting animations on all bars except the one that is being highlighted.
     * - At least one of `index` or `series` must be non-nil.
     * - parameter barChart: The `ARBarChart` to which to add highlighting animations.
     * - parameter index: The index of the bar to highlight. If `nil`, highlight all indices.
     * - parameter series: The series of the bar to highlight. If `nil`, highlight all series.
     */
    public mutating func highlight(_ barChart: ARBarChart, atIndex index: Int?, forSeries series: Int?) {
        guard highlightedIndex == nil && highlightedSeries == nil else { return }
        
        addAnimations(to: barChart, highlightIndex: index, highlightSeries: series, isHighlighting: true)
        
        self.highlightedIndex = index
        self.highlightedSeries = series
    }
    
    /**
     * Reverse highlighting animations on all bars except the one that was highlighted.
     * - parameter barChart: The `ARBarChart` from which to remove highlighting.
     */
    public mutating func unhighlight(_ barChart: ARBarChart) {
        addAnimations(to: barChart, highlightIndex: highlightedIndex, highlightSeries: highlightedSeries, isHighlighting: false)
        
        self.highlightedIndex = nil
        self.highlightedSeries = nil
    }
    
    private func addAnimations(to barChart: ARBarChart,
                               highlightIndex index: Int?,
                               highlightSeries series: Int?,
                               isHighlighting: Bool) {
        guard series != nil || index != nil else {
            fatalError("ARChartHighlighter.highlight(_:index:series) requires at least one non-nil parameter.")
        }
        
        for node in barChart.childNodes {
            if let barNode = node as? ARBarChartBar, let barBox = barNode.geometry as? SCNBox {
                if (series != nil && barNode.series != series!)
                    || (index != nil && barNode.index != index!) {
                    let animationsAndAttributeKeys = getAnimations(for: barNode, isHighlighting: isHighlighting)
                    for (animation, animatedAttributeKey) in animationsAndAttributeKeys {
                        if animatedAttributeKey == "height" {
                            barBox.addAnimation(animation, forKey: animatedAttributeKey)
                        } else {
                            barNode.addAnimation(animation, forKey: animatedAttributeKey)
                        }
                    }
                }
            } else if let labelNode = node as? ARChartLabel {
                if (series != nil && labelNode.type == .series && labelNode.id != series!)
                    || (index != nil && labelNode.type == .index && labelNode.id != index!) {
                    let startingOpacity: Float = isHighlighting ? 1.0 : defaultFadedOpacity
                    let finalOpacity: Float = isHighlighting ? defaultFadedOpacity : 1.0
                    let opacityAnimation = CABasicAnimation.animation(forKey: "opacity", from: startingOpacity, to: finalOpacity, duration: animationDuration, delay: nil)
                    labelNode.addAnimation(opacityAnimation, forKey: "opacity")
                }
            }
        }
    }
    
    private func getAnimations(for barNode: ARBarChartBar,
                               isHighlighting: Bool) -> Zip2Sequence<[CABasicAnimation], [String]> {
        var animations: [CABasicAnimation]
        var animatedAttributeKeys: [String]
        
        switch animationStyle {
        case .shrink:
            let startingHeight = isHighlighting ? barNode.finalHeight : 0.0
            let finalHeight = isHighlighting ? 0.0 : barNode.finalHeight
            animations = [
                CABasicAnimation.animation(forKey: "height", from: startingHeight, to: finalHeight, duration: animationDuration, delay: nil),
                CABasicAnimation.animation(forKey: "position.y", from: 0.5 * startingHeight, to: 0.5 * finalHeight, duration: animationDuration, delay: nil)
            ]
            animatedAttributeKeys = ["height", "position.y"]
        case .fade:
            let fadedOpacity: Float = (barNode.finalOpacity <= 0.3) ? 0.0 : defaultFadedOpacity
            let startingOpacity: Float = isHighlighting ? barNode.finalOpacity : fadedOpacity
            let finalOpacity: Float = isHighlighting ? fadedOpacity : barNode.finalOpacity
            animations = [CABasicAnimation.animation(forKey: "opacity", from: startingOpacity, to: finalOpacity, duration: animationDuration, delay: nil)]
            animatedAttributeKeys = ["opacity"]
        }
        
        return zip(animations, animatedAttributeKeys)
    }
    
}
