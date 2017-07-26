//
//  ARDataSeries.swift
//  ARBarCharts
//
//  Created by Bobo on 7/16/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

/**
 * The `ARDataSeries` object is used as a convenience to easily create bar charts with `ARBarcharts`.
 * If more customization is desired, you should create your own object conforming to `ARBarChartDataSource` and `ARBarChartDelegate`.
 */
public class ARDataSeries: ARBarChartDataSource, ARBarChartDelegate {
    
    private let values: [[Double]]
    
    /// Labels to use for the series (Z-axis).
    public var seriesLabels: [String]? = nil
    
    /// Labels to use for the values at each index (X-axis).
    public var indexLabels: [String]? = nil
    
    /// Colors to use for the bars, cycled through based on bar position.
    public var barColors: [UIColor]? = nil
    
    /// Materials to use for the bars, cycled through based on bar position.
    /// If non-nil, `barMaterials` overrides `barColors` to style the bars.
    public var barMaterials: [SCNMaterial]? = nil
    
    /// Chamfer radius to use for the bars.
    public var chamferRadius: Float = 0.0
    
    /// Gap between series, expressed as a ratio of gap to bar width (Z-axis).
    public var seriesGap: Float = 0.5
    
    /// Gap between indices, expressed as a ratio of gap to bar length (X-axis).
    public var indexGap: Float = 0.5
    
    /// Space to allow for the series labels, expressed as a ratio of label space to graph width (Z-axis).
    public var spaceForSeriesLabels: Float = 0.2
    
    /// Space to allow for the index labels, expressed as a ratio of label space to graph length (X-axis).
    public var spaceForIndexLabels: Float = 0.2
    
    /// Opacity of each bar in the graph.
    public var barOpacity: Float = 1.0
    
    
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
    
    public func barChart(_ barChart: ARBarChart, labelForSeries series: Int) -> String? {
        let label = seriesLabels?[series]
        
        return label
    }
    
    public func barChart(_ barChart: ARBarChart, labelForValuesAtIndex index: Int) -> String? {
        return indexLabels?[index]
    }
    
    // MARK - ARBarChartDelegate
    
    public func barChart(_ barChart: ARBarChart, colorForBarAtIndex index: Int, forSeries series: Int) -> UIColor {
        if let barColors = barColors {
            return barColors[(series * values[series].count + index) % barColors.count]
        }
        
        return UIColor.white
    }
    
    public func barChart(_ barChart: ARBarChart, materialForBarAtIndex index: Int, forSeries series: Int) -> SCNMaterial {
        if let barMaterials = barMaterials {
            return barMaterials[(series * (values.first?.count ?? 0) + index) % barMaterials.count]
        }
        
        // If bar materials are not set, default to using colors
        let colorMaterial = SCNMaterial()
        colorMaterial.diffuse.contents = self.barChart(barChart, colorForBarAtIndex: index, forSeries: series)
        colorMaterial.specular.contents = UIColor.white
        return colorMaterial
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
    
    public func barChart(_ barChart: ARBarChart, chamferRadiusForBarAtIndex index: Int, forSeries series: Int) -> Float {
        return chamferRadius
    }
    
    public func spaceForSeriesLabels(in barChart: ARBarChart) -> Float {
        return spaceForSeriesLabels
    }
    
    public func spaceForIndexLabels(in barChart: ARBarChart) -> Float {
        return spaceForIndexLabels
    }
    
}
