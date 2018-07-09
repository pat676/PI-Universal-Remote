//
//  EditLayoutBackgroundViewController.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 18.02.2018.
//  Copyright © 2018 Patrick Henriksen. All rights reserved.
//

import UIKit

protocol EditBackgroundViewControllerDelegate: class{
    func editLayoutBackgroundViewControllerDidCancel(_ controller: EditLayoutBackgroundViewController)
    func editLayoutBackgroundViewControllerDidSave(_ controller: EditLayoutBackgroundViewController)
}

class EditLayoutBackgroundViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    //MARK: - Properties
    
    var delegate: EditBackgroundViewControllerDelegate?
    var layout: Layout!
    var currentBackgroundColor: Color!
    var currentCustomColor: Color!
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var greenTextField: UITextField!
    @IBOutlet weak var redTextField: UITextField!
    @IBOutlet weak var blueTextField: UITextField!
    
    //MARK: - System
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Using tap recognizer for resigning text field first responder
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.resignCurrentFirstResponder))
        tapRecognizer.cancelsTouchesInView = false;
        view.addGestureRecognizer(tapRecognizer)
        setColorTextFieldsTarget()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = layout.backgroundColor.uiColor
        currentBackgroundColor = layout.backgroundColor
        currentCustomColor = layout.customColor
        
        setColorTextFieldValuesFromCurrentColor()
        pickerViewSelectRow(animated: false)
        view.bringSubview(toFront: pickerView)
    }
    
    //MARK: - BarButtons
    
    @IBAction func saveBarButtonPressed(){
        layout.backgroundColor = currentBackgroundColor
        layout.customColor = currentCustomColor
        delegate?.editLayoutBackgroundViewControllerDidSave(self)
    }
    
    @IBAction func cancelBarButtonPressed(){
        delegate?.editLayoutBackgroundViewControllerDidCancel(self)
    }
    
    //MARK: - TableViewDelegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let settingsCell = cell as? SettingsCell{
            if (tableView.numberOfRows(inSection: indexPath.section) == 1){
                settingsCell.type = .Single
                settingsCell.setSingleCellDesign()
            }
            else if(indexPath.row == 0){
                settingsCell.type = .Top
                settingsCell.setTopCellDesign()
            }
            else if(indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1){
                settingsCell.type = .Bottom
                settingsCell.setBottomCellDesign()
            }
            else{
                settingsCell.type = .Mid
                settingsCell.setMidCellDesign()
            }
            return settingsCell
        }
        return cell
    }
    
    //MARK: - PickerView Data Source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return BACKGROUND_COLORS.count+1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(row == BACKGROUND_COLORS.count) {return "Custom Color"}
        else {return BACKGROUND_COLORS[row].name}
    }
    
    //MARK: - PickerView Delegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (row == BACKGROUND_COLORS.count){
            //Custom Color
            currentBackgroundColor = currentCustomColor
        }
        else{
            currentBackgroundColor = BACKGROUND_COLORS[row]
        }
        view.backgroundColor = currentBackgroundColor.uiColor
        setColorTextFieldValuesFromCurrentColor()
    }
    
    //MARK: - TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Color Text Fields
    
    //Selects the currently used color in the picker view
    func pickerViewSelectRow(animated: Bool){
        //Select pickerView row
        var row = BACKGROUND_COLORS.count;
        for i in 0..<BACKGROUND_COLORS.count{
            if(BACKGROUND_COLORS[i].name == currentBackgroundColor.name){
                row = i
                break
            }
        }
        pickerView.selectRow(row, inComponent: 0, animated: animated)
    }
    
    
     // Adjusts the String of the color text fields to match current background color
    func setColorTextFieldValuesFromCurrentColor(){
        let mask = 0b11111111;
        var rgbVal = currentBackgroundColor.uiColor.rgb()
        rgbVal = rgbVal == nil ? 0 : rgbVal
        blueTextField.text = String(rgbVal! & mask)
        greenTextField.text = String((rgbVal! >> 8) & mask)
        redTextField.text = String((rgbVal! >> 16) & mask)
    }
    
    //Sets the current background color to the color defined in the color textFields.
    func setColorFromTextFields(){
        var rgbVal: Int = 0;
        
        if let str = redTextField.text{
            if let NSValue = NumberFormatter().number(from: str){
                rgbVal += (Int(truncating:(NSValue)) << 16)
            }
        }
        
        if let str = greenTextField.text{
            if let NSValue = NumberFormatter().number(from: str){
                rgbVal += (Int(truncating:(NSValue)) << 8)
            }
        }
        
        if let str = blueTextField.text{
            if let NSValue = NumberFormatter().number(from: str){
                rgbVal += Int(truncating: NSValue);
            }
        }
        
        let color = UIColor(rgb: rgbVal)
        currentBackgroundColor = Color(name: "CustomColor", color: color)
        currentCustomColor = currentBackgroundColor
        view.backgroundColor = currentBackgroundColor.uiColor
        pickerViewSelectRow(animated: true)
    }
    
    
    //Adds the textFieldDidChange target to all color text fields
    func setColorTextFieldsTarget(){
        redTextField.addTarget(self, action: #selector(colorTextFieldDidChange(_:)), for: .editingChanged)
        blueTextField.addTarget(self, action: #selector(colorTextFieldDidChange(_:)), for: .editingChanged)
        greenTextField.addTarget(self, action: #selector(colorTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    //Adjusts all color text fields to be numbers in range 0...255
    @objc func colorTextFieldDidChange(_ textField: UITextField) {
        textField.adjustToNumericRange(from: 0, to: 255)
        setColorFromTextFields()
    }
    
    //MARK: - Util
    
    //Resignes first responder for text field
    @objc func resignCurrentFirstResponder(){
        view.endEditing(true)
    }
}
