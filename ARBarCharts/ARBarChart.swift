//
//  ARBarChart.swift
//  ARBarCharts
//
//  Created by Bobo on 7/15/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import Foundation
import SceneKit

public class ARBarChartNode: SCNNode {
    
    weak var dataSource: ARBarChartsDataSource?
    weak var delegate: ARBarChartsDelegate?
    
    // MARK: - Convenience Functions
    
    private lazy var numberOfSeries: Int = {
        guard let dataSource = self.dataSource else {
            return 0
        }
        
        return dataSource.numberOfSeries(in: self)
    }()
    
    private func numberOfValues(forSeries series: Int) -> Int {
        guard let dataSource = dataSource else {
            return 0
        }
        
        return dataSource.barChart(self, numberOfValuesInSeries: series)
    }
    
    private func valueAtIndex(index: Int, forSeries series: Int) -> Double? {
        guard let dataSource = dataSource else {
            return nil
        }
        
        return dataSource.barChart(self, valueAtIndex: index, forSeries: series)
    }
    
    private lazy var maxValue: Double? = {
        var seriesIndex = 0
        var maxValue = Double.leastNonzeroMagnitude
        while seriesIndex < self.numberOfSeries {
            var valuesIndex = 0
            while valuesIndex < self.numberOfValues(forSeries: seriesIndex) {
                guard let value = self.valueAtIndex(index: valuesIndex, forSeries: seriesIndex) else {
                    return nil
                }
                maxValue = max(maxValue, value)
                valuesIndex += 1
            }
            seriesIndex += 1
        }
        
        return maxValue
    }()
    
}
