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
    
    public var seriesLabels: [String]? = nil
    public var indexLabels: [String]? = nil
    public var barColors: [UIColor]? = nil
    public var barMaterials: [SCNMaterial]? = nil
    public var seriesGap: Float = 0.5
    public var indexGap: Float = 0.5
    public var seriesLabelsGap: Float = 0.2
    public var indexLabelsGap: Float = 0.2
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
    
    public func spaceForSeriesLabels(in barChart: ARBarChart) -> Float {
        return seriesLabelsGap
    }
    public func spaceForIndexLabels(in barChart: ARBarChart) -> Float {
        return indexLabelsGap
    }
    
}
