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
     * - parameter barChart: The `ARBarChart` object requesting the number of series (Y axis).
     * - returns: The number of series (Y axis) in the bar chart.
     */
    func numberOfSeries(in barChart: ARBarChart) -> Int
    
    /**
     *  Asks the data source to return the number of values (indices on the X axis) for a specific series (rows on the Y axis) in the bar chart.
     * - parameter barChart: The `ARBarChart` object requesting the number of values.
     * - parameter series: The index number identifying a series in the bar chart (Y axis).
     * - returns: The number of values (X axis) for a specific series (Y axis) in the bar chart.
     */
    func barChart(_ barChart: ARBarChart,
                  numberOfValuesInSeries series: Int) -> Int
    
    /**
     *  Asks the data source to return the value (vertical position, Z axis) for a bar, at a given index (X axis) for a specific series (rows on the Y axis) in the bar chart.
     * - parameter barChart: The `ARBarChart` object requesting the value.
     * - parameter index: The index number identifying an index in the bar chart (X axis).
     * - parameter series: The index number identifying a series in the bar chart (Y axis).
     * - returns: The Z axis value for a given series (Y axis) at a particular index (X axis).
     */
    func barChart(_ barChart: ARBarChart,
                  valueAtIndex index: Int,
                  forSeries series: Int) -> Double
    
    /**
     *  Asks the data source to return the label for a specific series (Y axis).
     * - parameter barChart: The `ARBarChart` object requesting the number of values.
     * - parameter series: The index number identifying a series in the bar chart (Y axis).
     * - returns: The label for a given series (Y axis), or `nil` if the series has no label.
     */
    func barChart(_ barChart: ARBarChart,
                  labelForSeries series: Int) -> String?
    
    /**
     *  Asks the data source to return the label for values at a specific index (X axis) in all series.
     * - parameter barChart: The `ARBarChart` object requesting the number of values.
     * - parameter index: The index number identifying an index in the bar chart (X axis).
     * - returns: The label for a given index (X axis), or `nil` if the values at this index have no label.
     */
    func barChart(_ barChart: ARBarChart,
                  labelForValuesAtIndex index: Int) -> String?
        
}

// Make it optional for an `ARBarChartDataSource` to provide labels.
extension ARBarChartDataSource {
    
    public func barChart(_ barChart: ARBarChart, labelForSeries series: Int) -> String? {
        return nil
    }
    
    public func barChart(_ barChart: ARBarChart, labelForValuesAtIndex index: Int) -> String? {
        return nil
    }
    
}

public protocol ARBarChartDelegate: class {
    
    /**
     *  Asks the delegate to return the color for a bar at a given index (X axis) for a specific series (rows on the Y axis) in the bar chart.
     * - parameter barChart: The `ARBarChart` object requesting the number of values.
     * - parameter index: The index number identifying an index in the bar chart (X axis).
     * - parameter series: The index number identifying a series in the bar chart (Y axis).
     * - returns: The color to use for the bar corresponding to the given index and series.
     */
    func barChart(_ barChart: ARBarChart,
                  colorForBarAtIndex index: Int,
                  forSeries series: Int) -> UIColor
    
    /**
     * Asks the delegate to return the size of the gap to display after a specific series.
     * - parameter barChart: The `ARBarChart` object requesting the gap size.
     * - parameter series: The series that precedes the gap.
     * - returns: The size, as a percentage of bars' width, of the gap to display after a given series.
     * - discussion: The size returned is a percentage of the bars' width. For example, returning 0.5, means that the size of the gap will be 50% of the width of the bars.
     */
    func barChart(_ barChart: ARBarChart,
                         gapSizeAfterSeries series: Int) -> Float
    
    /**
     * Asks the delegate to return the size of the gap to display after a specific index.
     * - parameter barChart: The `ARBarChart` object requesting the gap size.
     * - parameter index: The index that precedes the gap.
     * - returns: The size, as a percentage of the bars' length, of the gap to display after a given index.
     * - discussion: The size returned is a percentage of the bars' length. For example, returning 0.5, means that the size of the gap will be 50% of the length of the bars.
     */
    func barChart(_ barChart: ARBarChart,
                  gapSizeAfterIndex index: Int) -> Float
    
    /**
     *  Asks the delegate to return the space available for index labels, as a ratio of the total available space for the Z axis (between 0 and 1).
     * - parameter barChart: The `ARBarChart` object requesting the spacing for index labels.
     * - returns: The ratio of Z-axis space to use for index labels, as a `Double` between 0 and 1.
     */
    func spaceForIndexLabels(in barChart: ARBarChart) -> Float
    
    /**
     *  Asks the delegate to return the space available for series labels, as a ratio of the total available space for the X axis (between 0 and 1).
     * - parameter barChart: The `ARBarChart` object requesting the spacing for series labels.
     * - returns: The ratio of X-axis space to use for series labels, as a `Double` between 0 and 1.
     */
    func spaceForSeriesLabels(in barChart: ARBarChart) -> Float
    
}

extension ARBarChartDelegate {
    
    public func barChart(_ barChart: ARBarChart,
                  gapSizeAfterSeries series: Int) -> Float {
        return 0.0
    }
        
    public func spaceForIndexLabels(in barChart: ARBarChart) -> Float {
        return 0.0
    }
    
    public func spaceForSeriesLabels(in barChart: ARBarChart) -> Float {
        return 0.0
    }
    
    
    func barChart(_ barChart: ARBarChart,
                  gapSizeAfterIndex index: Int) -> Float {
        return 0.0
    }
    
}
