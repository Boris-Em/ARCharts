//
//  ViewController+ARBarChartDataSource.swift
//  ARChartsSampleApp
//
//  Created by Christopher Chute on 7/16/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import ARCharts
import UIKit

extension ViewController: ARBarChartDataSource {
    
    // TODO: We will need to use ARDataSeries eventually, as our sample app should reflect the "default" customization state. The data is very specific right now as well. We will eventually need a more generic way of handling / displaying the data.
    
    internal func parseData() {
        let dataPath = Bundle.main.path(forResource: "fruit_sales", ofType: "csv") ?? ""
        if let fruitSalesCSV = try? String(contentsOfFile: dataPath) {
            self.data = []
            self.rowLabels = []
            self.columnLabels = []
            
            // Store the column labels
            let lines = fruitSalesCSV.components(separatedBy: "\n")
            let headerEntries = lines[0].components(separatedBy: ",")
            for columnLabel in headerEntries[1...] {
                self.columnLabels.append(columnLabel)
            }
            
            // Store the row labels and data entries
            for line in lines[1...] {
                let lineEntries = line.components(separatedBy: ",")
                if lineEntries.count == headerEntries.count {
                    self.rowLabels.append(lineEntries[0])
                    self.data.append(lineEntries[1...].map({ Double($0) ?? 0.0 }))
                }
            }
        }
    }
    
    func numberOfSeries(in barChart: ARBarChart) -> Int {
        return self.data.count
    }
    
    func barChart(_ barChart: ARBarChart, numberOfValuesInSeries series: Int) -> Int {
        return self.data[series].count
    }
    
    func barChart(_ barChart: ARBarChart, valueAtIndex index: Int, forSeries series: Int) -> Double {
        return self.data[series][index]
    }
    
    func barChart(_ barChart: ARBarChart, colorForBarAtIndex index: Int, forSeries series: Int) -> UIColor {
        let colors = [UIColor.red, UIColor.green, UIColor.blue]
        return colors[generateRandomNumber(withRange: 0 ..< colors.count)]
    }
    
}
