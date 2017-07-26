//
//  ARChartLabel.swift
//  ARCharts
//
//  Created by Christopher Chute on 7/26/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import Foundation
import SceneKit

public class ARChartLabel: SCNNode {
    
    public enum LabelType {
        case index
        case series
    }
    
    /// Type of label, either `.series` or `.index`.
    public let type: LabelType
    
    /// Numeric identifier for the label.
    /// Index number if `type` is `.index`, series number if `type` is `.series`.
    public let id: Int
    
    public override var description: String {
        switch type {
        case .index:
            return "IndexLabel(\(id))"
        case .series:
            return "SeriesLabel(\(id))"
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(text: SCNText, type: LabelType, id: Int, backgroundColor: UIColor) {
        self.type = type
        self.id = id
        
        super.init()
        self.geometry = text
        
        let backgroundWidth = CGFloat(1.05 * (text.boundingBox.max.x - text.boundingBox.min.x))
        let backgroundHeight = CGFloat(1.2 * (text.boundingBox.max.y - text.boundingBox.min.y))
        let backgroundPlane = SCNPlane(width: backgroundWidth, height: backgroundHeight)
        backgroundPlane.cornerRadius = 0.15 * min(backgroundPlane.width, backgroundPlane.height)
        backgroundPlane.firstMaterial?.diffuse.contents = backgroundColor
        let backgroundNode = SCNNode(geometry: backgroundPlane)
        // TODO: Position values came from trial-and-error. The positioning doesn't make any sense.
        backgroundNode.position = SCNVector3(0.495 * backgroundWidth,
                                             0.7 * backgroundHeight,
                                             -0.05)
        
        self.addChildNode(backgroundNode)
    }
    
}
