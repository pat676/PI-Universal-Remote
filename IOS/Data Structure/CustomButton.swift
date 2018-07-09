//
//  Button.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 22.12.2017.
//  Copyright © 2017 Patrick Henriksen. All rights reserved.
//

import UIKit

class CustomButton: UIButton{
    
    var bluetoothSignal = "0"
    var alignEdges = true
    
    var longPress: UILongPressGestureRecognizer?
    
    //The time in seconds for a press to be interpreted as a long press
    var minLongPressDuration:Double = MINIMUM_HOLD_FOR_REPEAT
    //If the user holds a button, this is the delay between repeated sending of the signal
    var repeatSignalDelay:Double = MINIMUM_SIGNAL_REPEAT_TIME
    
    var color: Color = GREY_BUTTON
    var customColor: Color = GREY_BUTTON
    var cornerRadius:CGFloat = 0; //A number between 0 and 1 indicating the amount of rounding in the corners
    
    var gradientColors: [UIColor]{
        get{
            return UIColor.createGradientColors(from: color.uiColor, gradientMagnitude: BUTTON_GRADIENT_MAGNITUDE)
        }
    }
    var borderColor: CGColor{
        get{
            return (color.uiColor.modifiedBrightnes(mulValue: BUTTON_BORDER_BRIGHTNES_VALUE)).cgColor
        }
    }
    
    override required init(frame: CGRect) {
        super.init(frame: frame)
        self.setTitle("New", for: [.normal])
        self.clipsToBounds = true
        updateDesign()
    }
    
    //MARK: - Util
    
    func updateDesign(){
        self.layer.borderWidth = BUTTON_BORDER_WIDTH

        let minSize = frame.size.height < frame.size.width ? frame.size.height : frame.size.width
        self.layer.cornerRadius = cornerRadius*minSize/2
        self.layer.borderColor = borderColor
        setGradientColors(inverted: false);
    }
    
    func setGradientColors(inverted: Bool?){
        if inverted == true{
            self.applyGradient(withColours: [gradientColors[1], gradientColors[0]], gradientOrientation: .vertical)
        }
        else{
            self.applyGradient(withColours: gradientColors, gradientOrientation: .vertical)
        }
    }
    
    func markSelected(){
        self.layer.borderColor = SELECTED_BUTTON_BORDER_COLOR
    }
    
    func deMarkSelected(){
        self.layer.borderColor = borderColor
    }
    
    //MARK: - Data Storage
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if let decColor = aDecoder.decodeObject(forKey: "Color") as? Color{color = decColor}
        if let decBluetoothSignal = aDecoder.decodeObject(forKey: "BluetoothSignal") as? String{
            bluetoothSignal = decBluetoothSignal
        }
        if let decCornerRadius = aDecoder.decodeObject(forKey: "CornerRadius") as? CGFloat{
            cornerRadius = decCornerRadius
        }
        if let decCustomColor = aDecoder.decodeObject(forKey: "CustomColor") as? Color{
            customColor = decCustomColor
        }
        if(aDecoder.containsValue(forKey: "AlignEdges")){
            alignEdges = aDecoder.decodeBool(forKey: "AlignEdges")
        }
        if(aDecoder.containsValue(forKey: "MinLongPressDuration")){
            minLongPressDuration = aDecoder.decodeDouble(forKey: "MinLongPressDuration")
            if(minLongPressDuration < MINIMUM_HOLD_FOR_REPEAT){ minLongPressDuration = MINIMUM_HOLD_FOR_REPEAT}
        }
        if(aDecoder.containsValue(forKey: "RepeatSignalDelay")){
            repeatSignalDelay = aDecoder.decodeDouble(forKey: "RepeatSignalDelay")
            if(repeatSignalDelay < MINIMUM_SIGNAL_REPEAT_TIME) {repeatSignalDelay = MINIMUM_SIGNAL_REPEAT_TIME}
        }
        updateDesign()
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder);
        aCoder.encode(bluetoothSignal, forKey: "BluetoothSignal")
        aCoder.encode(alignEdges, forKey: "AlignEdges")
        aCoder.encode(minLongPressDuration, forKey: "MinLongPressDuration")
        aCoder.encode(repeatSignalDelay, forKey: "RepeatSignalDelay")
        aCoder.encode(color, forKey: "Color")
        aCoder.encode(customColor, forKey: "CustomColor")
        aCoder.encode(cornerRadius, forKey: "CornerRadius")
    }
}


