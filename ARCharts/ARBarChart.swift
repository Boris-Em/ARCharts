//
//  ARBarChart.swift
//  ARBarCharts
//
//  Created by Bobo on 7/15/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import Foundation
import SceneKit

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
        
        // Compute normalization constants to scale the bars to fit inside the bounding box
        let xRange = dataSource.numberOfSeries(in: self)
        let yRange = Array(0 ..< xRange).map({ dataSource.barChart(self, numberOfValuesInSeries: $0) }).max() ?? 1
        // TODO: Should we always let zMin be 0? I.e. minimum bar should always have some depth, right?
        var zMin = 0.0
        var zMax = 0.0
        for xValue in 0 ..< dataSource.numberOfSeries(in: self) {
            for yValue in 0 ..< dataSource.barChart(self, numberOfValuesInSeries: xValue) {
                let zValue = dataSource.barChart(self, valueAtIndex: yValue, forSeries: xValue)
                if zValue < zMin {
                    zMin = zValue
                }
                if zValue > zMax {
                    zMax = zValue
                }
            }
        }
        let zRange = (zMin == zMax) ? 1.0 : zMax - zMin
        
        let boxWidth = size.x / Float(xRange)
        let boxLength = size.y / Float(yRange)
        let zNormalizer = size.z / Float(zRange)
        
        // Construct the bars
        for yValue in 0 ..< dataSource.numberOfSeries(in: self) {
            for xValue in 0 ..< dataSource.barChart(self, numberOfValuesInSeries: yValue) {
                let zValue = dataSource.barChart(self, valueAtIndex: xValue, forSeries: yValue)
                
                // Construct a box with the bar's dimensions
                let boxHeight = Float(zValue) * zNormalizer
                let barBox = SCNBox(width: CGFloat(boxWidth),
                                    height: CGFloat(boxHeight),
                                    length: CGFloat(boxLength),
                                    chamferRadius: 0)
                let barNode = SCNNode(geometry: barBox)
                
                // Position the box
                let xPosition = Float(xValue) * Float(boxWidth)
                let zPosition = Float(yValue) * Float(boxLength)
                let yPosition = Float(zValue) * Float(zNormalizer) / 2.0
                barNode.position = SCNVector3(x: Float(xPosition), y: Float(yPosition), z: Float(zPosition))
                
                // Color the bar
                let barColor = delegate.barChart(self, colorForValueAtIndex: xValue, forSeries: yValue)
                barNode.geometry?.firstMaterial?.diffuse.contents = barColor
                
                self.addChildNode(barNode)
            }
        }
    }
}
