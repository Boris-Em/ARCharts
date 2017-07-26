//
//  SettingsTableViewController.swift
//  ARChartsSampleApp
//
//  Created by Boris Emorine on 7/25/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import UIKit
import  ARCharts

protocol SettingsDelegate {
    func didUpdateSettings(_ settings: Settings)
}

class SettingsTableViewController: UITableViewController, UITextFieldDelegate {
    
    var settings: Settings?
    var delegate: SettingsDelegate?
    
    @IBOutlet weak var longPressAnimationSegmentedControl: UISegmentedControl!
    @IBOutlet weak var entranceAnimationSegmentedControl: UISegmentedControl!
    @IBOutlet weak var opacitySlider: UISlider!
    @IBOutlet weak var opacityLabel: UILabel!
    @IBOutlet weak var labelSwitch: UISwitch!
    @IBOutlet weak var seriesTextField: UITextField!
    @IBOutlet weak var indicesTextField: UITextField!
    @IBOutlet weak var widthLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var widthSlider: UISlider!
    @IBOutlet weak var heightSlider: UISlider!
    @IBOutlet weak var lengthSlider: UISlider!
    @IBOutlet weak var randomDataSetCell: UITableViewCell!
    @IBOutlet weak var dataSetSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seriesTextField.delegate = self
        indicesTextField.delegate = self
        
        setupControlsState()
    }
    
    private func setupControlsState() {
        guard let settings = settings else {
            return
        }
        
        entranceAnimationSegmentedControl.selectedSegmentIndex = settings.index(forEntranceAnimationType: settings.animationType)
        longPressAnimationSegmentedControl.selectedSegmentIndex = settings.index(forLongPressAnimationType: settings.longPressAnimationType)
        opacitySlider.value = settings.barOpacity
        opacityLabel.text = String(format: "%.1f", arguments: [opacitySlider.value])
        labelSwitch.isOn = settings.labels
        seriesTextField.text = String(settings.numberOfSeries)
        indicesTextField.text = String(settings.numberOfIndices)
        widthSlider.value = settings.graphWidth
        heightSlider.value = settings.graphHeight
        lengthSlider.value = settings.graphLength
        widthLabel.text = String(format: "Width: %.1f", settings.graphWidth)
        heightLabel.text = String(format: "Height: %.1f", settings.graphHeight)
        lengthLabel.text = String(format: "Length: %.1f", settings.graphLength)
        dataSetSegmentedControl.selectedSegmentIndex = settings.dataSet
        if dataSetSegmentedControl.selectedSegmentIndex != 0 {
            randomDataSetCell.isHidden = true
        } else {
            randomDataSetCell.isHidden = false
        }
    }
    
    // MARK: Actions
    
    @IBAction func handleEntranceAnimationSegmentControlValueChange(_ sender: UISegmentedControl) {
        settings?.animationType = settings?.entranceAnimationType(forIndex: sender.selectedSegmentIndex) ?? .fade
    }
    
    @IBAction func handleLongPressAnimationSegmentControlValueChange(_ sender: UISegmentedControl) {
        settings?.longPressAnimationType = settings?.longPressAnimationType(forIndex: sender.selectedSegmentIndex) ?? .shrink
    }
    
    @IBAction func handleOpacitySliderValueChange(_ sender: UISlider) {
        settings?.barOpacity = sender.value
        opacityLabel.text = String(format: "%.1f", arguments: [sender.value])
    }
    
    @IBAction func handleSwitchValueChange(_ sender: UISwitch) {
        settings?.labels = sender.isOn
    }
    
    @IBAction func handleDataSetValueChange(_ sender: UISegmentedControl) {
        settings?.dataSet = sender.selectedSegmentIndex
        if sender.selectedSegmentIndex == 0 {
            randomDataSetCell.isHidden = false
        } else {
            randomDataSetCell.isHidden = true
        }
    }
        
    @IBAction func handleWidthSliderValueChange(_ sender: UISlider) {
        widthLabel.text = String(format: "Width: %.1f", sender.value)
        settings?.graphWidth = sender.value
    }
    
    @IBAction func handleHeightSliderValueChange(_ sender: UISlider) {
        heightLabel.text = String(format: "Height: %.1f", sender.value)
        settings?.graphHeight = sender.value
    }
    
    @IBAction func handleLengthSliderValueChange(_ sender: UISlider) {
        lengthLabel.text = String(format: "Length: %.1f", sender.value)
        settings?.graphLength = sender.value
    }
    
    @IBAction func handleTapSave(_ sender: Any) {
        if let settings = settings {
            delegate?.didUpdateSettings(settings)
        }
        self.dismiss(animated: true, completion: nil)
    }
        
    // MARK: UITextFieldDelegate
    
    let textFieldMaxValue = 500
    let textFieldMinValue = 1
    let textFieldDefaultValue = 10
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {
            if textField == seriesTextField {
                settings?.numberOfSeries = textFieldDefaultValue
            } else {
                settings?.numberOfIndices = textFieldDefaultValue
            }
            textField.text = String(textFieldDefaultValue)
            
            return true
        }
        
        var value = Int(text) ?? textFieldDefaultValue
        value = max(textFieldMinValue, min(textFieldMaxValue, value))
        if textField == seriesTextField {
            settings?.numberOfSeries = value
        } else {
            settings?.numberOfIndices = value
        }
        
        textField.text = String(value)
        textField.resignFirstResponder()
        
        return true
    }
    
}
