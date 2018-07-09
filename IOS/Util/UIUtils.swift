//
//  UIUtils.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 08.03.2018.
//  Copyright © 2018 Patrick Henriksen. All rights reserved.
//

import UIKit

extension UITextField{
    /*
     * Adjusts the value in a text field to lie between the parameters lowNum and highNum
     *
     * If the textfield contains a valid number as interpreted by NumberFormatter() and the number is below lowNum or
     * above highNum, the string is set to lowNum/ highNum. If the string cant be interpreted as  a Number it is set to
     * lowNum.
     *
     * Args:
     *     lowNum (Int): The lower limit of allowed numbers
     *     highNum(Int): The higher limit of allowed numbers
     */
    func adjustToNumericRange(from lowNum: Int, to highNum: Int){
        assert(lowNum <= highNum, "Invalid parameters sent to func setTextFieldNumber()")
        var value: Int = lowNum
        if let str = text{
            if let NSValue = NumberFormatter().number(from: str){
                if(Int(truncating: NSValue) < lowNum) {value = lowNum}
                else if(Int(truncating: NSValue) > highNum) {value = highNum}
                else{value = Int(truncating: NSValue)}
            }
        }
        text? = String(value)
    }
}
