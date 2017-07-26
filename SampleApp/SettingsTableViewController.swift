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
    
    @IBAction func handleTapSave(_ sender: Any) {
        if let settings = settings {
            delegate?.didUpdateSettings(settings)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleTapCancel(_ sender: Any) {
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
