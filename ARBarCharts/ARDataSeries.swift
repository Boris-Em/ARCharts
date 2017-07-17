//
//  ARDataSeries.swift
//  ARBarCharts
//
//  Created by Bobo on 7/16/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import Foundation

/**
 * The `ARDataSeries` object is used as a convenience to easily create bar charts with `ARBarcharts`.
 * If more customization is desired, you should create your own object conforming to `ARBarChartsDataSource` and `ARBarChartsDelegate`.
 */
public class ARDataSeries: ARBarChartsDataSource, ARBarChartsDelegate {
    
    private let values: [[Double]]
    
    public required init(withValues values: [[Double]], barChart: ARBarChartNode) {
        self.values = values
        barChart.dataSource = self
        barChart.delegate = self
    }
    
    public func numberOfSeries(in barChart: ARBarChartNode) -> Int {
        return values.count
    }
    
    public func barChart(_ barChart: ARBarChartNode, numberOfValuesInSeries series: Int) -> Int {
        return values[series].count
    }
    
    public func barChart(_ barChart: ARBarChartNode, valueAtIndex index: Int, forSeries series: Int) -> Double {
        return values[series][index]
    }
    
}
