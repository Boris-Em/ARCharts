//
//  ViewController+ARBarChartDataSource.swift
//  ARBarChartsSampleApp
//
//  Created by Christopher Chute on 7/16/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import ARBarCharts
import UIKit

// Implements ARBarChartsDataSource protocol for the Fruit Sales sample data set.
extension ViewController: ARBarChartsDataSource {
    
    /// Read sample data from the fruit sales CSV file
    internal func readData() {
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
    
}
