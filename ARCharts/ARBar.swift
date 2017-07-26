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
    
    public override var description: String {
        return "ARBarNode(series: \(series), index: \(index), value: \(value))"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(geometry: SCNBox, index: Int, series: Int, value: Double) {
        super.init()
        self.geometry = geometry
        
        self.series = series
        self.index = index
        self.value = value
    }
    
}
