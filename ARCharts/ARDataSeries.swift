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
    private let seriesLabels: [String]?
    private let indexLabels: [String]?
    public var barColor = UIColor.cyan
    public var seriesGap: Float = 0.5
    public var indexGap: Float = 0.5
    public var barOpacity: Float = 1.0
    
    private let arKitColors = [
        UIColor(colorLiteralRed: 238.0 / 255.0, green: 109.0 / 255.0, blue: 150.0 / 255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 70.0  / 255.0, green: 150.0 / 255.0, blue: 150.0 / 255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 134.0 / 255.0, green: 218.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 237.0 / 255.0, green: 231.0 / 255.0, blue: 254.0 / 255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 0.0   / 255.0, green: 110.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 193.0 / 255.0, green: 193.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0),
        UIColor(colorLiteralRed: 84.0  / 255.0, green: 204.0 / 255.0, blue: 254.0 / 255.0, alpha: 1.0)
    ]
    
    // MARK - ARBarChartDataSource
    
    public required init(withValues values: [[Double]]) {
        self.values = values
        self.seriesLabels = nil
        self.indexLabels = nil
    }
    
    public init(withValues values: [[Double]], seriesLabels: [String]?, indexLabels: [String]?) {
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
        let label = seriesLabels?[series]
        
        return label
    }
    
    public func barChart(_ barChart: ARBarChart, labelForValuesAtIndex index: Int) -> String? {
        return indexLabels?[index]
    }
    
    // MARK - ARBarChartDelegate
    
    public func barChart(_ barChart: ARBarChart, colorForBarAtIndex index: Int, forSeries series: Int) -> UIColor {
        return arKitColors[(series * values[series].count + index) % arKitColors.count]
    }
    
    public func barChart(_ barChart: ARBarChart, materialForBarAtIndex index: Int, forSeries series: Int) -> SCNMaterial {
        let colorIndex = (series * (values.first?.count ?? 0) + index) % arKitColors.count
        if colorIndex == 0 {
            let woodMaterial = SCNMaterial()
            woodMaterial.diffuse.contents = #imageLiteral(resourceName: "WoodGrain")
            woodMaterial.specular.contents = UIColor.white
            return woodMaterial
        } else {
            let colorMaterial = SCNMaterial()
            colorMaterial.diffuse.contents = arKitColors[colorIndex]
            colorMaterial.specular.contents = UIColor.white
            return colorMaterial
        }
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
        return 0.2
    }
    public func spaceForIndexLabels(in barChart: ARBarChart) -> Float {
        return 0.2
    }
    
}
