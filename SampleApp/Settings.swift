//
//  Settings.swift
//  ARChartsSampleApp
//
//  Created by Boris Emorine on 7/26/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import Foundation
import  ARCharts

struct Settings {
    
    var animationType: ARChartAnimator.AnimationType = .fadeIn
    var longPressAnimationType : ARChartHighlighter.AnimationStyle = .shrink
    var barOpacity: Float = 1.0
    
    public func index(forEntranceAnimationType animationType: ARChartAnimator.AnimationType?) -> Int {
        guard let animationType = animationType else {
            return 0
        }
        
        switch animationType {
        case .fadeIn:
            return 0
        case .progressiveFadeIn:
            return 1
        case .grow:
            return 2
        case .progressiveGrow:
            return 3
        }
    }
    
    public func entranceAnimationType(forIndex index: Int) -> ARChartAnimator.AnimationType? {
        switch index {
        case 0:
            return .fadeIn
        case 1:
            return .progressiveFadeIn
        case 2:
            return .grow
        case 3:
            return .progressiveGrow
        default:
            return .fadeIn
        }
    }
    
    public func index(forLongPressAnimationType animationType: ARChartHighlighter.AnimationStyle?) -> Int {
        guard let animationType = animationType else {
            return 0
        }
        switch animationType {
        case .shrink:
            return 0
        case .fade:
            return 1
        }
    }
    
    public func longPressAnimationType(forIndex index: Int) -> ARChartHighlighter.AnimationStyle? {
        switch index {
        case 0:
            return .shrink
        case 1:
            return .fade
        default:
            return .shrink
        }
    }
}
