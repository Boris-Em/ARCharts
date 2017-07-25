//
//  ARDataSeries.swift
//  ARBarCharts
//
//  Created by Bobo on 7/16/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import Foundation
import UIKit

/**
 * The `ARDataSeries` object is used as a convenience to easily create bar charts with `ARBarcharts`.
 * If more customization is desired, you should create your own object conforming to `ARBarChartDataSource` and `ARBarChartDelegate`.
 */
public class ARDataSeries: ARBarChartDataSource, ARBarChartDelegate {
    
    private let values: [[Double]]
    private let seriesLabels: [String]?
    private let indexLabels: [String]?
    public var barColor = UIColor.cyan
    public var seriesGap: Float = 0.5
    public var indexGap: Float = 0.5
    public var barOpacity: Float = 1.0
    
    // MARK - ARBarChartDataSource
    
    public required init(withValues values: [[Double]]) {
        self.values = values
        self.seriesLabels = nil
        self.indexLabels = nil
    }
    
    public init(withValues values: [[Double]], seriesLabels: [String], indexLabels: [String]) {
        self.values = values
        self.seriesLabels = seriesLabels
        self.indexLabels = indexLabels
    }
    
    public func numberOfSeries(in barChart: ARBarChart) -> Int {
        return values.count
    }
    
    public func barChart(_ barChart: ARBarChart, numberOfValuesInSeries series: Int) -> Int {
        return values[series].count
    }
    
    public func barChart(_ barChart: ARBarChart, valueAtIndex index: Int, forSeries series: Int) -> Double {
        return values[series][index]
    }
    
    public func barChart(_ barChart: ARBarChart, labelForSeries series: Int) -> String? {
        return seriesLabels?[series]
    }
    
    public func barChart(_ barChart: ARBarChart, labelForValuesAtIndex index: Int) -> String? {
        return indexLabels?[index]
    }
    
    // MARK - ARBarChartDelegate
    
    public func barChart(_ barChart: ARBarChart, colorForBarAtIndex index: Int, forSeries series: Int) -> UIColor {
        return barColor
    }
    
    public func barChart(_ barChart: ARBarChart, gapSizeAfterSeries series: Int) -> Float {
        return seriesGap
    }
    
    public func barChart(_ barChart: ARBarChart, gapSizeAfterIndex index: Int) -> Float {
        return indexGap
    }
    
    public func barChart(_ barChart: ARBarChart, opacityForBarAtIndex index: Int, forSeries series: Int) -> Float {
        return barOpacity
    }
}
