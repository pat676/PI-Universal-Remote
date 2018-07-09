//
//  EditButtonDesignViewController.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 19.02.2018.
//  Copyright © 2018 Patrick Henriksen. All rights reserved.
//

import UIKit

protocol EditButtonDesignViewControllerDelegate: class{
    func editButtonDesignViewControllerDidCancel(_ controller: EditButtonDesignViewController)
    func editButtonDesignViewControllerDidSave(_ controller: EditButtonDesignViewController)
}

class EditButtonDesignViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: - Properties
    
    var delegate: EditButtonDesignViewControllerDelegate?
    var button: CustomButton!
    
    var currentButtonColor: Color!{
        set(newColor){
            exampleButton.color = newColor
            exampleButton.updateDesign()
        }
        get{
            return exampleButton.color
        }
    }
    var currentButtonCornerRadius: CGFloat{
        set(newRadius){
            exampleButton.cornerRadius = newRadius
            exampleButton.updateDesign()
        }
        get{
            return exampleButton.cornerRadius
        }
    }
    var currentButtonCustomColor: Color!
    let exampleButton = CustomButton()
    
    //MARK: - Outlets
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var redTextField: UITextField!
    @IBOutlet weak var greenTextField: UITextField!
    @IBOutlet weak var blueTextField: UITextField!
    @IBOutlet weak var exampleButtonView: UIView!
    @IBOutlet weak var cornerRadiusSlider: UISlider!
    @IBOutlet weak var cornerRadiusTextField: UITextField!
    
    //MARK: - System
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Using tap recognizer for resigning text field first responder
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.resignCurrentFirstResponder))
        tapRecognizer.cancelsTouchesInView = false;
        view.addGestureRecognizer(tapRecognizer)
        setTextFieldsTargets()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentButtonColor = button.color;
        currentButtonCustomColor = button.customColor
        currentButtonCornerRadius = button.cornerRadius
        
        cornerRadiusSlider.value = Float(button.cornerRadius)
        setColorTextFieldValuesFromCurrentColor()
        pickerViewSelectRow(animated: false)
        setCornerRadiusTextField()
        
        view.bringSubview(toFront: pickerView)
        addExampleButton()
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
        return BUTTON_COLORS.count+1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == BUTTON_COLORS.count{
            return "Custom Color"
        }
        else{
            return BUTTON_COLORS[row].name
        }
    }
    
    //MARK: - PickerView Delegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == BUTTON_COLORS.count{
            currentButtonColor = currentButtonCustomColor
        }
        else{
            currentButtonColor = BUTTON_COLORS[row]
        }
        setColorTextFieldValuesFromCurrentColor()
    }
    
    func pickerViewSelectRow(animated: Bool){
        var row = BUTTON_COLORS.count;
        for i in 0..<BUTTON_COLORS.count{
            if(BUTTON_COLORS[i].name == currentButtonColor.name){
                row = i
                break
            }
        }
        pickerView.selectRow(row, inComponent: 0, animated: animated)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    //MARK: - IBAction
    
    @IBAction func cancel(){
        delegate?.editButtonDesignViewControllerDidCancel(self)
    }
    
    @IBAction func save(){
        button.color = currentButtonColor
        button.customColor = currentButtonCustomColor
        button.cornerRadius = currentButtonCornerRadius
        button.updateDesign()
        delegate?.editButtonDesignViewControllerDidSave(self)
    }
    
    @IBAction func cornerRadiusSliderChangedValue(_ sender: UISlider) {
        currentButtonCornerRadius = CGFloat(sender.value)
        setCornerRadiusTextField()
    }
    
    
    //MARK: - TextFields
    
    //Sets the color text field strings from the current color
    func setColorTextFieldValuesFromCurrentColor(){
        let mask = 0b11111111;
        var rgbVal = currentButtonColor.uiColor.rgb()
        rgbVal = rgbVal == nil ? 0 : rgbVal
        blueTextField.text = String(rgbVal! & mask)
        greenTextField.text = String((rgbVal! >> 8) & mask)
        redTextField.text = String((rgbVal! >> 16) & mask)
    }
    
    //Sets the current color from the text field values
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
        currentButtonColor = Color(name: "CustomColor", color: color)
        currentButtonCustomColor = currentButtonColor
        pickerViewSelectRow(animated: true)
    }
    
    //Sets the cornerRadiusTextField to the currentCornerRadius
    func setCornerRadiusTextField(){
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = TEXT_FIELD_DECIMAL_DIGITS
        nf.minimumFractionDigits = TEXT_FIELD_DECIMAL_DIGITS
        cornerRadiusTextField.text = nf.string(from: NSNumber(value: Double(currentButtonCornerRadius)))
    }
    
    //Adds targets to the color text fields
    func setTextFieldsTargets(){
        redTextField.addTarget(self, action: #selector(colorTextFieldDidChange(_:)), for: .editingChanged)
        blueTextField.addTarget(self, action: #selector(colorTextFieldDidChange(_:)), for: .editingChanged)
        greenTextField.addTarget(self, action: #selector(colorTextFieldDidChange(_:)), for: .editingChanged)
        cornerRadiusTextField.addTarget(self, action: #selector(cornerRadiusTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    //Adjusts the corner radius of the button to the new value given in the textfield
    @objc func cornerRadiusTextFieldDidChange(_ textField: UITextField){
        if let str = textField.text{
            if let NSValue = NumberFormatter().number(from: str) {
                var  value = CGFloat(truncating: NSValue)
                if(value < 0){
                    value = 0;
                    cornerRadiusTextField.text = String(describing: Int(value))
                }
                else if(value > 1){
                    value = 1;
                    cornerRadiusTextField.text = String(describing: Int(value))
                }
                cornerRadiusSlider.value = Float(value)
                currentButtonCornerRadius = value
            }
        }
    }
    
    @objc func colorTextFieldDidChange(_ textField: UITextField) {
        textField.adjustToNumericRange(from: 0, to: 255)
        setColorFromTextFields()
    }
    
    //MARK: - Util
    
    //Adds an example button to viualize the changes
    func addExampleButton(){
        exampleButton.setTitle(button.currentTitle, for: .normal)
        
        //Create buttons with the same scale as the original button
        var maxSize = button.frame.size.width
        maxSize = maxSize < button.frame.size.height ? button.frame.size.height : maxSize
        let scale = 100.0/maxSize
        exampleButton.frame.size.height = button.frame.size.height * scale;
        exampleButton.frame.size.width = button.frame.size.width * scale;
        
        exampleButton.color = currentButtonColor
        exampleButton.cornerRadius = currentButtonCornerRadius
        exampleButton.updateDesign()
        exampleButton.frame.origin.y = 20
        exampleButton.frame.origin.x = exampleButtonView.bounds.maxX / 2 - exampleButton.frame.width / 2.0
        exampleButtonView.addSubview(exampleButton)
    }
    
    //Resignes first responder for text fields
    @objc func resignCurrentFirstResponder(){
        view.endEditing(true)
        setCornerRadiusTextField()
    }
}
