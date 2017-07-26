//
//  SettingsTableViewController.swift
//  ARChartsSampleApp
//
//  Created by Boris Emorine on 7/25/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import UIKit
import  ARCharts

class SettingsTableViewController: UITableViewController {
    
    public var barChart: ARBarChart?
    
    @IBOutlet weak var entranceAnimationSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupControlsState()
    }
    
    private func setupControlsState() {
        guard barChart = barChart else {
            return
        }
        
        
    }
    
    private index(forEntranceAnimationType animationType: 

}
