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
    public var barColor = UIColor.cyan
    
    // MARK - ARBarChartDataSource
    
    public required init(withValues values: [[Double]]) {
        self.values = values
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
    
    // MARK - ARBarChartDelegate
    
    public func barChart(_ barChart: ARBarChart, colorForBarAtIndex index: Int, forSeries series: Int) -> UIColor {
        return barColor
    }
    
}
