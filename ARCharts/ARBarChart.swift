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
                fatalError("Could not find values for dataSource, delegate, numberOfSeries, and maxNumberOfIndices.")
        }
        
        guard let minValue = self.minValue ?? self.minAndMaxChartValues?.minValue,
            let maxValue = self.maxValue ?? self.minAndMaxChartValues?.maxValue,
            minValue < maxValue else {
                fatalError("Invalid chart values detected (minValue >= maxValue)")
        }
        
        let spaceForSeriesLabels = delegate.spaceForSeriesLabels(in: self)
        guard spaceForSeriesLabels >= 0.0 && spaceForSeriesLabels <= 1.0 else {
            fatalError("ARBarChartDelegate method spaceForSeriesLabels must return a value between 0.0 and 1.0")
        }
        let spaceForIndexLabels = delegate.spaceForIndexLabels(in: self)
        guard spaceForIndexLabels >= 0.0 && spaceForIndexLabels <= 1.0 else {
            fatalError("ARBarChartDelegate method spaceForIndexLabels must return a value between 0.0 and 1.0")
        }
        
        
        
        let sizeAvailableForBars = SCNVector3(x: size.x * (1.0 - delegate.spaceForSeriesLabels(in: self)),
                                              y: size.y,
                                              z: size.z * (1.0 - delegate.spaceForIndexLabels(in: self)))
        let biggestValueRange = maxValue - minValue
        
        let barsWidth = self.seriesSize(withNumberOfSeries: numberOfSeries, zSizeAvailableForBars: size.z)
        let barsLength = sizeAvailableForBars.x / Float(maxNumberOfIndices)
        let maxBarHeight = sizeAvailableForBars.y / Float(biggestValueRange)
        
        let xShift = size.x * (spaceForSeriesLabels - 0.5)
        let zShift = size.z * (spaceForIndexLabels - 0.5)
        var previousZPosition: Float = 0.0
        
        
        for series in 0 ..< numberOfSeries {
            guard let zPosition = self.zPosition(forSeries: series, previousZPosition, barsWidth) else {
                return
            }
            
            for index in 0 ..< dataSource.barChart(self, numberOfValuesInSeries: series) {
                let value = dataSource.barChart(self, valueAtIndex: index, forSeries: series)
                
                let barHeight = Float(value) * maxBarHeight
                let barBox = SCNBox(width: CGFloat(barsWidth),
                                    height: CGFloat(barHeight),
                                    length: CGFloat(barsLength),
                                    chamferRadius: 0)
                let barNode = SCNNode(geometry: barBox)
                
                let xPosition = Float(index) * barsLength + xShift
                let yPosition = Float(value) * Float(maxBarHeight) / 2.0
                barNode.position = SCNVector3(x: xPosition, y: yPosition, z: zPosition)
                
                let barColor = delegate.barChart(self, colorForBarAtIndex: index, forSeries: series)
                barNode.geometry?.firstMaterial?.diffuse.contents = barColor
                
                self.addChildNode(barNode)
            }
            
            previousZPosition = zPosition
            
            if let seriesLabelText = dataSource.barChart(self, labelForSeries: series) {
                let seriesLabel = SCNText(string: seriesLabelText, extrusionDepth: 0.0)
                seriesLabel.truncationMode = kCATruncationEnd
                seriesLabel.alignmentMode = kCAAlignmentLeft
                
                seriesLabel.font = UIFont.systemFont(ofSize: 10.0)
                seriesLabel.firstMaterial!.isDoubleSided = true
                seriesLabel.firstMaterial!.diffuse.contents = UIColor.white
                let seriesLabelNode = SCNNode(geometry: seriesLabel)
                
                seriesLabelNode.scale = SCNVector3(0.002, 0.002, 0.002)
                let position = SCNVector3(x: -size.x,
                                          y: 0.0,
                                          z: Float(series) * barsWidth + zShift + (barsWidth / 2.0))
                seriesLabelNode.position = position
                seriesLabelNode.geometry?.firstMaterial?.isDoubleSided = true
                seriesLabelNode.eulerAngles = SCNVector3(-Float.pi / 2.0, 0.0, 0.0)
                
                self.addChildNode(seriesLabelNode)
            }
            
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
                total + delegate.barChart(self, gapSizeAfterSeries: current)
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
        let gapSize: Float = series == 0 ? 0.0 : self.delegate?.barChart(self, gapSizeAfterSeries: series - 1) ?? 0.0

        return previousSeriesZPosition + seriesSize + seriesSize * gapSize
    }
}
