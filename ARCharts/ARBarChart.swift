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
    public var size: SCNVector3!
    public var animationType: ARChartPresenter.AnimationType? { didSet { updatePresenter() } }
    public var animationDuration = 1.0 { didSet { updatePresenter() } }
    
    private var presenter: ARChartPresenter!
    private var highlighter: ARChartHighlighter!
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init() {
        super.init()
    }
    
    public func reloadGraph() {
        draw()
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
            
            return Array(0..<numberOfSeries).map({ dataSource.barChart(self, numberOfValuesInSeries: $0) }).max()
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
    
    /**
     * Render the chart in the `SCNView`.
     */
    public func draw() {
        guard let dataSource = dataSource,
            let delegate = delegate,
            let numberOfSeries = self.numberOfSeries,
            let maxNumberOfIndices = self.maxNumberOfIndices,
            let size = self.size else {
                fatalError("Could not find values for dataSource, delegate, numberOfSeries, and maxNumberOfIndices.")
        }
        
        guard let minValue = self.minValue ?? self.minAndMaxChartValues?.minValue,
            let maxValue = self.maxValue ?? self.minAndMaxChartValues?.maxValue,
            minValue < maxValue else {
                fatalError("Invalid chart values detected (minValue >= maxValue)")
        }
        
        guard let spaceForSeriesLabels = self.delegate?.spaceForSeriesLabels(in: self),
            spaceForSeriesLabels >= 0.0 && spaceForSeriesLabels <= 1.0 else {
            fatalError("ARBarChartDelegate method spaceForSeriesLabels must return a value between 0.0 and 1.0")
        }
        
        guard let spaceForIndexLabels = self.delegate?.spaceForIndexLabels(in: self),
            spaceForIndexLabels >= 0.0 && spaceForIndexLabels <= 1.0 else {
            fatalError("ARBarChartDelegate method spaceForIndexLabels must return a value between 0.0 and 1.0")
        }
        
        let sizeAvailableForBars = SCNVector3(x: size.x * (1.0 - spaceForSeriesLabels),
                                              y: size.y,
                                              z: size.z * (1.0 - spaceForIndexLabels))
        let biggestValueRange = maxValue - minValue
        
        let barLength = self.seriesSize(withNumberOfSeries: numberOfSeries, zSizeAvailableForBars: sizeAvailableForBars.z)
        let barWidth = self.indexSize(withNumberOfIndices: maxNumberOfIndices, xSizeAvailableForBars: sizeAvailableForBars.x)
        let maxBarHeight = sizeAvailableForBars.y / Float(biggestValueRange)
        
        let xShift = size.x * (spaceForSeriesLabels - 0.5)
        let zShift = size.z * (spaceForIndexLabels - 0.5)
        var previousZPosition: Float = 0.0
        
        for series in 0..<numberOfSeries {
            let zPosition = self.zPosition(forSeries: series, previousZPosition, barLength)
            var previousXPosition: Float = 0.0
            
            for index in 0..<dataSource.barChart(self, numberOfValuesInSeries: series) {
                let value = dataSource.barChart(self, valueAtIndex: index, forSeries: series)
                let barHeight = Float(value) * maxBarHeight
                let startingBarHeight = animationType == .grow || animationType == .progressiveGrow ? 0.0 : barHeight
                let barOpacity = delegate.barChart(self, opacityForBarAtIndex: index, forSeries: series)
                let startingBarOpacity = animationType == .fade || animationType == .progressiveFade ? 0.0 : opacity
                
                let barChamferRadius = min(barLength, barWidth) * delegate.barChart(self, chamferRadiusForBarAtIndex: index, forSeries: series)
                let barBox = SCNBox(width: CGFloat(barWidth),
                                    height: CGFloat(startingBarHeight),
                                    length: CGFloat(barLength),
                                    chamferRadius: CGFloat(barChamferRadius))
                let barNode = ARBarChartBar(geometry: barBox,
                                            index: index,
                                            series: series,
                                            value: value,
                                            finalHeight: barHeight,
                                            finalOpacity: barOpacity)
                barNode.opacity = CGFloat(startingBarOpacity)

                let yPosition = 0.5 * Float(value) * Float(maxBarHeight)
                let startingYPosition = (animationType == .grow || animationType == .progressiveGrow) ? 0.0 : yPosition
                let xPosition = self.xPosition(forIndex: index, previousXPosition, barWidth)
                barNode.position = SCNVector3(x: xPosition + xShift, y: startingYPosition, z: zPosition + zShift)

                let barMaterial = delegate.barChart(self, materialForBarAtIndex: index, forSeries: series)
                barNode.geometry?.firstMaterial = barMaterial
                
                self.addChildNode(barNode)
                
                if series == 0 {
                    self.addLabel(forIndex: index, atXPosition: xPosition + xShift, withMaxHeight: barWidth)
                }
                previousXPosition = xPosition
                
                presenter?.addAnimation(to: barNode, in: self)
            }
            
            self.addLabel(forSeries: series, atZPosition: zPosition + zShift, withMaxHeight: barLength)
            previousZPosition = zPosition
        }
    }
    
    
    /**
     * Highlight a bar at a specific index within a specific series.
     * - parameter index: The index location (X axis) of the bar to highlight.
     * - parameter series: The series location (Z axis) of the bar to highlight.
     * - parameter animationStyle: Style of animation to use during highlighting.
     *   This same animation style will be used to reverse the highlighting.
     * - parameter animationDuration: Duration of highlighting animation.
     *   This same duration will also be used to reverse the highlighting
     */
    public func highlightBar(atIndex index: Int,
                             forSeries series: Int,
                             withAnimationStyle animationStyle: ARChartHighlighter.AnimationStyle,
                             withAnimationDuration animationDuration: TimeInterval) {
        guard highlighter == nil else { return }
            
        highlighter = ARChartHighlighter(animationStyle: animationStyle, animationDuration: animationDuration)
        highlighter.highlight(self, atIndex: index, forSeries: series)
    }
    
    /**
     * Highlight all bars in a specific series.
     * - parameter series: The series location (Z axis) of the bars to highlight.
     * - parameter animationStyle: Style of animation to use during highlighting.
     *   This same animation style will be used to reverse the highlighting.
     * - parameter animationDuration: Duration of highlighting animation.
     *   This same duration will also be used to reverse the highlighting.
     */
    public func highlightSeries(_ series: Int,
                                withAnimationStyle animationStyle: ARChartHighlighter.AnimationStyle,
                                withAnimationDuration animationDuration: TimeInterval) {
        guard highlighter == nil else { return }
        
        highlighter = ARChartHighlighter(animationStyle: animationStyle, animationDuration: animationDuration)
        highlighter.highlight(self, atIndex: nil, forSeries: series)
    }
    
    /**
     * Highlight all bars at a specific index.
     * - parameter series: The series location (Z axis) of the bars to highlight.
     * - parameter animationStyle: Style of animation to use during highlighting.
     *   This same animation style will be used to reverse the highlighting.
     * - parameter animationDuration: Duration of highlighting animation.
     *   This same duration will also be used to reverse the highlighting.
     */
    public func highlightIndex(_ index: Int,
                               withAnimationStyle animationStyle: ARChartHighlighter.AnimationStyle,
                               withAnimationDuration animationDuration: TimeInterval) {
        guard highlighter == nil else { return }
        
        highlighter = ARChartHighlighter(animationStyle: animationStyle, animationDuration: animationDuration)
        highlighter.highlight(self, atIndex: index, forSeries: nil)
    }
    
    /**
     * Remove any highlighting currently active on this chart.
     */
    public func unhighlight() {
        guard self.highlighter != nil else { return }
        
        self.highlighter.unhighlight(self)
        
        self.highlighter = nil
    }
    
    /**
     * Update the presenter to use the new animation type. Called on `didSet` for member `animationType`.
     */
    private func updatePresenter() {
        if let animationType = self.animationType {
            if presenter != nil {
                presenter.animationType = animationType
                presenter.animationDuration = animationDuration
            } else {
                presenter = ARChartPresenter(animationType: animationType, animationDuration: animationDuration)
            }
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
    
    /**
     * Add a series label to the Z axis for a given series and at a given Z position.
     * - parameter series: The series to be labeled.
     * - parameter zPosition: The Z position of the center of the bars for the specified series.
     */
    private func addLabel(forSeries series: Int, atZPosition zPosition: Float, withMaxHeight maxHeight: Float) {
        if let seriesLabelText = dataSource!.barChart(self, labelForSeries: series) {
            let seriesLabel = SCNText(string: seriesLabelText, extrusionDepth: 0.0)
            seriesLabel.truncationMode = kCATruncationNone
            seriesLabel.alignmentMode = kCAAlignmentCenter
            seriesLabel.font = UIFont.systemFont(ofSize: 10.0)
            seriesLabel.firstMaterial!.isDoubleSided = true
            seriesLabel.firstMaterial!.diffuse.contents = delegate!.barChart(self, colorForLabelForSeries: series)
            
            let backgroundColor = delegate!.barChart(self, backgroundColorForLabelForSeries: series)
            let seriesLabelNode = ARChartLabel(text: seriesLabel, type: .series, id: series, backgroundColor: backgroundColor)
            
            let unscaledLabelWidth = seriesLabelNode.boundingBox.max.x - seriesLabelNode.boundingBox.min.x
            let desiredLabelWidth = size.x * delegate!.spaceForSeriesLabels(in: self)
            let unscaledLabelHeight = seriesLabelNode.boundingBox.max.y - seriesLabelNode.boundingBox.min.y
            let labelScale = min(desiredLabelWidth / unscaledLabelWidth, maxHeight / unscaledLabelHeight)
            seriesLabelNode.scale = SCNVector3(labelScale, labelScale, labelScale)
            
            let zShift = 0.5 * maxHeight - (maxHeight - labelScale * unscaledLabelHeight)
            let position = SCNVector3(x: -0.5 * size.x,
                                      y: 0.0,
                                      z: zPosition + zShift)
            seriesLabelNode.position = position
            seriesLabelNode.eulerAngles = SCNVector3(-0.5 * Float.pi, 0.0, 0.0)
            
            self.addChildNode(seriesLabelNode)
        }
    }
    
    /**
     * Add an index label to the X axis for a given index and at a given X position.
     * - parameter index: The index (X axis) to be labeled.
     * - parameter zPosition: The Z position of the center of the bars for the specified series.
     */
    private func addLabel(forIndex index: Int, atXPosition xPosition: Float, withMaxHeight maxHeight: Float) {
        if let indexLabelText = dataSource!.barChart(self, labelForValuesAtIndex: index) {
            let indexLabel = SCNText(string: indexLabelText, extrusionDepth: 0.0)
            indexLabel.truncationMode = kCATruncationNone
            indexLabel.alignmentMode = kCAAlignmentCenter
            indexLabel.font = UIFont.systemFont(ofSize: 10.0)
            indexLabel.firstMaterial!.isDoubleSided = true
            indexLabel.firstMaterial!.diffuse.contents = delegate!.barChart(self, colorForLabelForValuesAtIndex: index)
            
            let backgroundColor = delegate!.barChart(self, backgroundColorForLabelForValuesAtIndex: index)
            let indexLabelNode = ARChartLabel(text: indexLabel, type: .index, id: index, backgroundColor: backgroundColor)
            
            let unscaledLabelWidth = indexLabelNode.boundingBox.max.x - indexLabelNode.boundingBox.min.x
            let desiredLabelWidth = size.z * delegate!.spaceForIndexLabels(in: self)
            let unscaledLabelHeight = indexLabelNode.boundingBox.max.y - indexLabelNode.boundingBox.min.y
            let labelScale = min(desiredLabelWidth / unscaledLabelWidth, maxHeight / unscaledLabelHeight)
            indexLabelNode.scale = SCNVector3(labelScale, labelScale, labelScale)
            
            let xShift = (maxHeight - labelScale * unscaledLabelHeight) - 0.5 * maxHeight
            let position = SCNVector3(x: xPosition + xShift,
                                      y: 0.0,
                                      z: -0.5 * size.z)
            indexLabelNode.position = position
            indexLabelNode.eulerAngles = SCNVector3(-0.5 * Float.pi, -0.5 * Float.pi, 0.0)
            
            self.addChildNode(indexLabelNode)
        }
    }
    
}
