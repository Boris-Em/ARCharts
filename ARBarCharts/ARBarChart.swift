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
    
    public var dataSource: ARBarChartsDataSource?
    public var delegate: ARBarChartsDelegate?
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(geometry: SCNGeometry) {
        super.init()
        self.geometry = geometry
    }
    
    
    /// Initialize an `ARBarChart` with a dataSource and bounding dimensions.
    /// Dimensions should be read as if you were looking down on the graph from above.
    /// Width and height determine the square in the XY-plane on which the graph lies.
    /// Depth is the distance from the planar surface to the top of the bar in the graph.
    ///
    /// - Parameters:
    ///   - dataSource: Provides data to the chart.
    ///   - width: Distance taken up by x-dimension (columns).
    ///   - height: Distance taken up by y-dimension (rows).
    ///   - depth: Distance taken up by z-dimension (from surface to top of largest bar).
    public init(dataSource: ARBarChartsDataSource, width: CGFloat, height: CGFloat, depth: CGFloat) {
        super.init()
        self.dataSource = dataSource
        
        // Construct the graph's planar base
        let basePlane = SCNPlane(width: width, height: height)
        let baseNode = SCNNode(geometry: basePlane)
        let (origin, _) = baseNode.boundingBox
        self.addChildNode(baseNode)
        
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
        
        let boxWidth = width / CGFloat(xRange)
        let boxHeight = height / CGFloat(yRange)
        let zNormalizer = depth / CGFloat(zRange)
        
        // Construct the bars
        for yValue in 0 ..< dataSource.numberOfSeries(in: self) {
            for xValue in 0 ..< dataSource.barChart(self, numberOfValuesInSeries: yValue) {
                let zValue = dataSource.barChart(self, valueAtIndex: xValue, forSeries: yValue)
                
                // Construct a box with the bar's dimensions
                let barBox = SCNBox(width: boxWidth,
                                    height: boxHeight,
                                    length: CGFloat(zValue) * zNormalizer,
                                    chamferRadius: 0)
                let barNode = SCNNode(geometry: barBox)
                
                // Position the box
                let xPosition = origin.x + Float(xValue) * Float(boxWidth)
                let yPosition = origin.y + Float(yValue) * Float(boxHeight)
                let zPosition = origin.z + Float(zValue) * Float(zNormalizer) / 2.0
                barNode.position = SCNVector3(x: Float(xPosition), y: Float(yPosition), z: Float(zPosition))
                // barNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(-M_PI_2))
                
                // Color the bar
                let barColor = dataSource.barChart(self, colorForValueAtIndex: xValue, forSeries: yValue)
                barNode.geometry?.firstMaterial?.diffuse.contents = barColor
                
                self.addChildNode(barNode)
            }
        }
    }
    
}
