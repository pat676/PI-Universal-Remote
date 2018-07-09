//
//  Layout.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 28.12.2017.
//  Copyright © 2017 Patrick Henriksen. All rights reserved.
//

import UIKit


class Layout: NSObject, NSCoding{
    
    var name = ""
    var earlierConnectedBluetoothDevices = [String]()
    var buttons = [CustomButton]()
    var usedWith = [String]()
    var backgroundColor = GREY_BACKGROUND
    var customColor = GREY_BACKGROUND
    
    override init(){}
    
    //MARK: - Data Storage
    
    required init?(coder aDecoder: NSCoder) {
        if let decName = aDecoder.decodeObject(forKey: "Name") as? String {name = decName}
        if let decButtons = aDecoder.decodeObject(forKey: "Buttons") as? [CustomButton]{buttons = decButtons}
        if let decUsedWith = aDecoder.decodeObject(forKey: "UsedWith") as? [String] {usedWith = decUsedWith}
        if let decBackgroundColor = aDecoder.decodeObject(forKey: "BackgroundColor") as? Color {
            backgroundColor = decBackgroundColor
        }
        if let decCustomColor = aDecoder.decodeObject(forKey: "CustomColor") as? Color{customColor = decCustomColor}
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(buttons, forKey: "Buttons")
        aCoder.encode(usedWith, forKey: "UsedWith");
        aCoder.encode(backgroundColor, forKey: "BackgroundColor")
        aCoder.encode(customColor, forKey: "CustomColor")
    }
}
