//
//  ARBarChartsProtocols.swift
//  ARBarCharts
//
//  Created by Bobo on 7/15/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

public protocol ARBarChartsDataSource {
    
    func numberOfSeries(in barChart: ARBarChartNode) -> Int
    
    func barChart(_ barChart: ARBarChartNode,
                  numberOfValuesInSeries series: Int) -> Int
    
    func barChart(_ barChart: ARBarChartNode,
                  valueAtIndex index: Int,
                  forSeries series: Int) -> Double

}

public protocol ARBarChartsDelegate {
    
}
