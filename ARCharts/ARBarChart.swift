//
//  ARBarChart.swift
//  ARBarCharts
//
//  Created by Bobo on 7/15/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit


public class ARBarChart: SCNNode {
    
    public var dataSource: ARBarChartDataSource?
    public var delegate: ARBarChartDelegate?
    public var animationType: ARBarChartAnimationType?
    public var animationDuration = 1.0
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(geometry: SCNGeometry) {
        super.init()
        self.geometry = geometry
    }
    
    private var size: SCNVector3?
    
    /** Initialize an `ARBarChart` with a dataSource and bounding dimensions.
     * Dimensions should be read as if you were looking down on the graph from above.
     * Width and height determine the square in the XY-plane on which the graph lies.
     * Depth is the distance from the planar surface to the top of the bar in the graph.
     *
     *  - parameter dataSource: Provides data to the chart.
     *  - parameter size: The size of the graph.
     */
    public init(dataSource: ARBarChartDataSource, delegate: ARBarChartDelegate, size: SCNVector3) {
        super.init()
        
        self.dataSource = dataSource
        self.delegate = delegate
        self.size = size
    }
    
    public func reloadGraph() {
        // TODO: Implement
    }
    
    // TODO: Cache (with lazy?)
    private var numberOfSeries: Int? {
        get {
            return self.dataSource?.numberOfSeries(in: self)
        }
    }
    
    // TODO: Cache (with lazy?)
    private var maxNumberOfIndices: Int? {
        get {
            guard let numberOfSeries = self.numberOfSeries, let dataSource = self.dataSource else {
                return nil
            }
            
            return Array(0 ..< numberOfSeries).map({ dataSource.barChart(self, numberOfValuesInSeries: $0) }).max()
        }
    }
    
    // TODO: Cache (lazy?)
    private var minAndMaxChartValues: (minValue: Double, maxValue: Double)? {
        get {
            guard let dataSource = self.dataSource else {
                return nil
            }
            
            var minValue = Double.greatestFiniteMagnitude
            var maxValue = Double.leastNormalMagnitude
            var didProcessValue = false
            
            for series in 0 ..< dataSource.numberOfSeries(in: self) {
                for index in 0 ..< dataSource.barChart(self, numberOfValuesInSeries: series) {
                    let value = dataSource.barChart(self, valueAtIndex: index, forSeries: series)
                    minValue = min(minValue, value)
                    maxValue = max(maxValue, value)
                    didProcessValue = true
                }
            }
            
            guard didProcessValue == true else {
                return nil
            }
            
            return (minValue, maxValue)
        }
    }
    public var minValue: Double?
    public var maxValue: Double?
    
    public func drawGraph() {
        guard let dataSource = dataSource,
            let delegate = delegate,
            let numberOfSeries = self.numberOfSeries,
            let maxNumberOfIndices = self.maxNumberOfIndices,
            let size = self.size else {
                // TODO: Print or assert
                return
        }
        
        guard let minValue = self.minValue ?? self.minAndMaxChartValues?.minValue,
            let maxValue = self.maxValue ?? self.minAndMaxChartValues?.maxValue,
            minValue < maxValue else {
                // TODO: Print or assert
                return
        }
        
        let biggestValueRange = maxValue - minValue
        let seriesSize = self.seriesSize(withNumberOfSeries: numberOfSeries, zSizeAvailableForBars: size.z)
        let barsLength = self.indexSize(withNumberOfIndices: maxNumberOfIndices, xSizeAvailableForBars: size.x)
        let maxBarHeight = size.y / Float(biggestValueRange)
        
        var previousZPosition: Float = 0.0
        
        for series in 0 ..< numberOfSeries {
            let zPosition = self.zPosition(forSeries: series, previousZPosition, seriesSize)
            var previousXPosition: Float = 0.0
            
            for index in 0 ..< dataSource.barChart(self, numberOfValuesInSeries: series) {
                let value = dataSource.barChart(self, valueAtIndex: index, forSeries: series)
                
                let barHeight = Float(value) * maxBarHeight
                let startingBarHeight = animationType == .grow || animationType == .progressiveGrow ? 0.0 : barHeight
                let barBox = SCNBox(width: CGFloat(barsLength),
                                    height: CGFloat(startingBarHeight),
                                    length: CGFloat(seriesSize),
                                    chamferRadius: 0)
                let barNode = SCNNode(geometry: barBox)
                barNode.opacity = animationType == .fadeIn || animationType == .progressiveFadeIn ? 0.0 : 1.0
                
                let yPosition = Float(value) * Float(maxBarHeight) / 2
                let startingYPosition = animationType == .grow || animationType == .progressiveGrow ? 0.0 : yPosition
                let xPosition = self.xPosition(forIndex: index, previousXPosition, barsLength)
                barNode.position = SCNVector3(x: xPosition, y: startingYPosition, z: zPosition)
                
                let barColor = delegate.barChart(self, colorForBarAtIndex: index, forSeries: series)
                barNode.geometry?.firstMaterial?.diffuse.contents = barColor
                
                self.addChildNode(barNode)
                previousXPosition = xPosition
                
                if animationType == .grow || animationType == .progressiveGrow {
                    let delay = animationType == .progressiveGrow ? Double(index) * animationDuration / 10.0 : nil
                    let heightAnim = heightAnimation(withToValue: barHeight, duration: animationDuration, delay: delay)
                    let yPositionAnim = yPositionAnimation(withToValue: yPosition, duration: animationDuration, delay: delay)
                    barBox.addAnimation(heightAnim, forKey: "height")
                    barNode.addAnimation(yPositionAnim, forKey: "position.y")
                } else if animationType == .fadeIn || animationType == .progressiveFadeIn {
                    let delay = animationType == .progressiveFadeIn ? Double(index) * animationDuration / 10.0 : nil
                    let fadeInAnim = fadeInAnimation(withToValue: 1.0, duration: animationDuration, delay: delay)
                    barNode.addAnimation(fadeInAnim, forKey: "opacity")
                }
            }
            
            previousZPosition = zPosition
        }
    }
    
    /**
     * Calculates the actual size available for one series on the graph.
     * - parameter numberOfSeries: The number of series on the graph.
     * - parameter availableZSize: The available size on the Z axis of the graph.
     * - returns: The actual size available for one series on the graph.
     */
    private func seriesSize(withNumberOfSeries numberOfSeries: Int, zSizeAvailableForBars availableZSize: Float) -> Float {
        var totalGapCoefficient: Float = 0.0
        if let delegate = self.delegate {
            totalGapCoefficient = Array(0 ..< numberOfSeries).reduce(0, { (total, current) -> Float in
                total + delegate.barChart(self, gapSizeAfterSeries: current)
            })
        }
        
        return availableZSize / (Float(numberOfSeries) + totalGapCoefficient)
    }
    
    /**
     * Calculates the actual size available for one index on the graph.
     * - parameter numberOfIndices: The number of indices on the graph.
     * - parameter availableXSize: The available size on the X axis of the graph.
     * - returns: The actual size available for one index on the graph.
     */
    private func indexSize(withNumberOfIndices numberOfIndices: Int, xSizeAvailableForBars availableXSize: Float) -> Float {
        var totalGapCoefficient: Float = 0.0
        if let delegate = self.delegate {
            totalGapCoefficient = Array(0 ..< numberOfIndices).reduce(0, { (total, current) -> Float in
                total + delegate.barChart(self, gapSizeAfterIndex: current)
            })
        }
        
        return availableXSize / (Float(numberOfIndices) + totalGapCoefficient)
    }
    
    /**
     * Calculates the X position (Series Axis) for a specific index.
     * - parameter series: The index that requires the X position.
     * - parameter previousIndexXPosition: The X position of the previous index. This is useful for optimization.
     * - parameter indexSize: The acutal size available for one index on the graph.
     * - returns: The X position for a given index.
     */
    private func xPosition(forIndex index: Int, _ previousIndexXPosition: Float, _ indexSize: Float) -> Float {
        let gapSize: Float = index == 0 ? 0.0 : self.delegate?.barChart(self, gapSizeAfterIndex: index - 1) ?? 0.0
        
        return previousIndexXPosition + indexSize + indexSize * gapSize
    }
    
    /**
     * Calculates the Z position (Series Axis) for a specific series.
     * - parameter series: The series that requires the Z position.
     * - parameter previousSeriesZPosition: The Z position of the previous series. This is useful for optimization.
     * - parameter seriesSize: The acutal size available for one series on the graph.
     * - returns: The Z position for a given series.
     */
    private func zPosition(forSeries series: Int, _ previousSeriesZPosition: Float, _ seriesSize: Float) -> Float {
        let gapSize: Float = series == 0 ? 0.0 : self.delegate?.barChart(self, gapSizeAfterSeries: series - 1) ?? 0.0
        
        return previousSeriesZPosition + seriesSize + seriesSize * gapSize
    }
}
