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
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(geometry: SCNGeometry) {
        super.init()
        self.geometry = geometry
    }
    
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
        drawGraph(withSize: size)
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
    
    private func drawGraph(withSize size: SCNVector3) {
        guard let dataSource = dataSource,
            let delegate = delegate,
            let numberOfSeries = self.numberOfSeries,
            let maxNumberOfIndices = self.maxNumberOfIndices else {
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
        let barsLength = size.x / Float(maxNumberOfIndices)
        let maxBarHeight = size.y / Float(biggestValueRange)
        
        var previousZPosition: Float = 0.0
        
        for series in 0 ..< numberOfSeries {
            guard let zPosition = self.zPosition(forSeries: series, previousZPosition, seriesSize) else {
                return
            }
            
            for index in 0 ..< dataSource.barChart(self, numberOfValuesInSeries: series) {
                let value = dataSource.barChart(self, valueAtIndex: index, forSeries: series)
                
                let barHeight = Float(value) * maxBarHeight
                let barBox = SCNBox(width: CGFloat(seriesSize),
                                    height: CGFloat(barHeight),
                                    length: CGFloat(barsLength),
                                    chamferRadius: 0)
                let barNode = SCNNode(geometry: barBox)
                
                let yPosition = Float(value) * Float(maxBarHeight) / 2.0
                let xPosition = Float(index) * barsLength
                barNode.position = SCNVector3(x: xPosition, y: yPosition, z: zPosition)
                
                let barColor = delegate.barChart(self, colorForBarAtIndex: index, forSeries: series)
                barNode.geometry?.firstMaterial?.diffuse.contents = barColor
                
                self.addChildNode(barNode)
            }
            
            previousZPosition = zPosition
        }
    }
    
    /**
     * Calculates the actual size available for one series on the graph.
     * - parameter numberOfSeries: The number of series on the graph.
     * - parameter availableZSize: The available size on the Z axis for graph.
     * - returns: The actual size available for one series on the graph.
     */
    private func seriesSize(withNumberOfSeries numberOfSeries: Int, zSizeAvailableForBars availableZSize: Float) -> Float {
        var totalGapCoefficient: Float = 0.0
        if let delegate = self.delegate {
            totalGapCoefficient = Array(0 ..< numberOfSeries).reduce(0, { (total, current) -> Float in
                total + delegate.barChart(self, gapAfterSeries: current)
            })
        }
        
        return availableZSize / (Float(numberOfSeries) + totalGapCoefficient)
    }
    
    /**
     * Calculates the Z position (Series Axis) for a specific series
     * - parameter series: The series that requires the Z position
     * - parameter previousSeriesZPosition: The Z position of the previous series. This is useful for optimization.
     * - parameter seriesSize: The acutal size available for one series on the graph.
     * - returns: The Z position for a given series.
     */
    private func zPosition(forSeries series: Int, _ previousSeriesZPosition: Float, _ seriesSize: Float) -> Float? {
        let gapSize: Float = series == 0 ? 0.0 : self.delegate?.barChart(self, gapAfterSeries: series - 1) ?? 0.0
        
        return previousSeriesZPosition + seriesSize + seriesSize * gapSize
    }
}
