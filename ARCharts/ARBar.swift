//
//  ARBar.swift
//  ARCharts
//
//  Created by Christopher Chute on 7/25/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import SceneKit
import UIKit

public class ARBar: SCNNode {
    
    public var series: Int = 0
    public var index: Int = 0
    public var value: Double = 0.0
    
    // Need to save the final bar height for highlighting animations
    public var finalHeight: Float = 0.0
    
    public override var description: String {
        return "ARBarNode(series: \(series), index: \(index), value: \(value))"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(geometry: SCNBox, index: Int, series: Int, value: Double, finalHeight: Float) {
        super.init()
        self.geometry = geometry
        self.finalHeight = finalHeight
        
        self.series = series
        self.index = index
        self.value = value
    }
    
}
