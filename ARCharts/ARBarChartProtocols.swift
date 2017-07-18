//
//  ARBarChartsProtocols.swift
//  ARBarCharts
//
//  Created by Bobo on 7/15/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import UIKit

/**
 * The `ARBarChartDataSource` protocol is adopted by an object that mediates the application's data model for an `ARBarChart` object.
 * The data source proves the bar chart object with the information it needs to construct and modify a bar chart.
 */
public protocol ARBarChartDataSource: class {
    
    /**
     *  Asks the data source to return the number of series (rows on the Y axis) in the bar chart.
     * - parameter barChart: The `ARBarCharNode` object requesting the number of series (Y axis).
     * - returns: The number of series (Y axis) in the bar chart.
     */
    func numberOfSeries(in barChart: ARBarChart) -> Int
    
    /**
     *  Asks the data source to return the number of values (indeces on the X axis) for a specific series (rows on the Y axis) in the bar chart.
     * - parameter barChart: The `ARBarCharNode` object requesting the number of values.
     * - parameter series: The index number identifying a series in the bar chart (Y axis).
     * - returns: The number of values (X axis) for a specific series (Y axis) in the bar chart.
     */
    func barChart(_ barChart: ARBarChart,
                  numberOfValuesInSeries series: Int) -> Int
    
    /**
     *  Asks the data source to return the value (vertical position, Z axis) for a bar, at a given index (X axis) for a specific series (rows on the Y axis) in the bar chart.
     * - parameter barChart: The `ARBarCharNode` object requesting the number of values.
     * - parameter index: The index number identifying an index in the bar chart (X axis).
     * - parameter series: The index number identifying a series in the bar chart (Y axis).
     * - returns: The Z axis value for a given series (Y axis) at a particular index (X axis).
     */
    func barChart(_ barChart: ARBarChart,
                  valueAtIndex index: Int,
                  forSeries series: Int) -> Double
    
    /**
     *  Asks the data source to return the color for a bar at a given index (X axis) for a specific series (rows on the Y axis) in the bar chart.
     * - parameter barChart: The `ARBarCharNode` object requesting the number of values.
     * - parameter index: The index number identifying an index in the bar chart (X axis).
     * - parameter series: The index number identifying a series in the bar chart (Y axis).
     * - returns: The color to use for the bar corresponding to the given index and series.
     */
    func barChart(_ barChart: ARBarChart,
                  colorForValueAtIndex index: Int,
                  forSeries series: Int) -> UIColor
    
}

public protocol ARBarChartDelegate: class {
    
}
