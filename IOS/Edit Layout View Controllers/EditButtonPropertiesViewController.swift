//
//  EditButtonPropertiesViewController.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 23.12.2017.
//  Copyright © 2017 Patrick Henriksen. All rights reserved.
//

import UIKit

protocol EditButtonPropertiesViewControllerDelegate: class{
    func editButtonPropertiesViewControllerDidCancel(_ controller: EditButtonPropertiesViewController)
    func editButtonPropertiesViewControllerDidSave(_ controller: EditButtonPropertiesViewController)
}

class EditButtonPropertiesViewController: UITableViewController, UITextFieldDelegate  {

    //MARK: - Properties
    
    var button: CustomButton!;
    weak var delegate: EditButtonPropertiesViewControllerDelegate!;
    
    let nf = NumberFormatter()

    
    //MARK: - Outlets
    
    @IBOutlet weak var posYTextField: UITextField!
    @IBOutlet weak var posXTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var widthTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var signalTextField: UITextField!
    
    @IBOutlet weak var minimumHoldTimeTextField: UITextField!
    @IBOutlet weak var repeatSignalDelayTextField: UITextField!
    
    //MARK: - System
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Number formater for coding/ decoding properties to/ from text field strings.
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = TEXT_FIELD_DECIMAL_DIGITS
        nf.minimumFractionDigits = TEXT_FIELD_DECIMAL_DIGITS
        
        //Using tap recognizer for resigning text field first responder
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.resignCurrentFirstResponder))
        tapRecognizer.cancelsTouchesInView = false;
        view.addGestureRecognizer(tapRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enterTextFieldInformation()
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
    
    //MARK: - TextFields Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Bar buttons

    @IBAction func cancel(){
        delegate.editButtonPropertiesViewControllerDidCancel(self);
    }
    
    @IBAction func save(){
        button.setTitle(nameTextField.text, for: .normal)
        updateButtonBluetoothSignal()
        updateButtonSize()
        updateButtonPosition()
        updateRepeatedSignalValues()
        button.updateDesign()
        delegate.editButtonPropertiesViewControllerDidSave(self)
    }
    
    //MARK: - Button Update
    
    func updateButtonBluetoothSignal(){
        if let signal = signalTextField.text{
            button.bluetoothSignal = signal
        }
    }
    /*
     * Uses the values entered in the text fields to update the height and width of the button. Invalid string values
     * not recognizd but NumberFormater will be discared and the old value will be kept
     */
    func updateButtonSize(){
        if let str = widthTextField.text{
            if let width = NumberFormatter().number(from: str) {
                var cgWidth = CGFloat(truncating: width)
                cgWidth = cgWidth < MINIMUM_BUTTON_WIDTH ? MINIMUM_BUTTON_WIDTH : cgWidth
                cgWidth = cgWidth > self.view.frame.size.width ? self.view.frame.size.width : cgWidth
                button.frame.size.width = cgWidth
            }
        }
        if let str = heightTextField.text{
            if let height = NumberFormatter().number(from: str) {
                var cgHeight = CGFloat(truncating: height)
                cgHeight = cgHeight < MINIMUM_BUTTON_HEIGHT ? MINIMUM_BUTTON_HEIGHT : cgHeight
                cgHeight = cgHeight > self.view.frame.size.height ? self.view.frame.size.height : cgHeight
                button.frame.size.height = cgHeight
            }
        }
    }
    
    /*
     * Uses the values entered in the text fields to update the x and y position of the button. Invalid string values
     * not recognized but NumberFormater will be discared and the old value will be kept
     */
    func updateButtonPosition(){
        if let str = posYTextField.text{
            if let y = NumberFormatter().number(from: str){
                let cgY = CGFloat(truncating: y)
                button.frame.origin.y = cgY
            }
        }
        
        if let str = posXTextField.text{
            if let x = NumberFormatter().number(from: str){
                let cgX = CGFloat(truncating: x)
                button.frame.origin.x = cgX
            }
        }
    }
    
    /*
     * Uses the values entered in the text fields to update the repeated signal values
     * minimumHoldTime is the minimum time for a button press to be recognized as a hold
     * repeatSignalDelay is the delay between repeated signal sends.
     */
    func updateRepeatedSignalValues(){
        if let str = minimumHoldTimeTextField.text{
            if let NSValue = NumberFormatter().number(from: str){
                var value = Double(truncating: NSValue)
                if(value < MINIMUM_HOLD_FOR_REPEAT){value = MINIMUM_HOLD_FOR_REPEAT}
                button.minLongPressDuration = value
            }
        }
        if let str = repeatSignalDelayTextField.text{
            if let NSValue = NumberFormatter().number(from: str){
                var value = Double(truncating: NSValue)
                if(value < MINIMUM_SIGNAL_REPEAT_TIME){value = MINIMUM_SIGNAL_REPEAT_TIME}
                button.repeatSignalDelay = value
            }
        }
    }
    
    //MARK: - Util
    
    func enterTextFieldInformation(){
        posXTextField.text = nf.string(from: NSNumber(value: Double(button.frame.minX)))
        posXTextField.delegate = self
        posYTextField.text = nf.string(from: NSNumber(value: Double(button.frame.minY)))
        posYTextField.delegate = self
        heightTextField.text = nf.string(from: NSNumber(value: Double(button.frame.size.height)))
        heightTextField.delegate = self
        widthTextField.text = nf.string(from: NSNumber(value: Double(button.frame.size.width)))
        widthTextField.delegate = self
        nameTextField.text = button.currentTitle
        nameTextField.delegate = self
        signalTextField.text = String(describing: button.bluetoothSignal)
        signalTextField.delegate = self
        minimumHoldTimeTextField.text = nf.string(from: NSNumber(value: Double(button.minLongPressDuration)))
        minimumHoldTimeTextField.delegate = self
        repeatSignalDelayTextField.text = nf.string(from: NSNumber(value: Double(button.repeatSignalDelay)))
        repeatSignalDelayTextField.delegate = self
    }
    
    //Resignes first responder for text fields
    @objc func resignCurrentFirstResponder(){
        view.endEditing(true)
    }
}

