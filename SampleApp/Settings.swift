//
//  Settings.swift
//  ARChartsSampleApp
//
//  Created by Boris Emorine on 7/26/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import Foundation
import ARCharts

struct Settings {
    
    var animationType: ARChartPresenter.AnimationType = .fade
    var longPressAnimationType : ARChartHighlighter.AnimationStyle = .shrink
    var barOpacity: Float = 1.0
    var labels = true
    var numberOfSeries = 10
    var numberOfIndices = 10
    var graphWidth: Float = 0.3
    var graphHeight: Float = 0.3
    var graphLength: Float = 0.3
    var dataSet: Int = 0
    
    public func index(forEntranceAnimationType animationType: ARChartPresenter.AnimationType?) -> Int {
        guard let animationType = animationType else {
            return 0
        }
        
        switch animationType {
        case .fade:
            return 0
        case .progressiveFade:
            return 1
        case .grow:
            return 2
        case .progressiveGrow:
            return 3
        }
    }
    
    public func entranceAnimationType(forIndex index: Int) -> ARChartPresenter.AnimationType? {
        switch index {
        case 0:
            return .fade
        case 1:
            return .progressiveFade
        case 2:
            return .grow
        case 3:
            return .progressiveGrow
        default:
            return .fade
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
