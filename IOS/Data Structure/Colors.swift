//
//  Colors.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 18.02.2018.
//  Copyright © 2018 Patrick Henriksen. All rights reserved.
//

import Foundation
import UIKit

class Color: NSObject, NSCoding{
    
    var name: String
    var uiColor: UIColor
    
    init(name: String, color: UIColor){
        self.name = name;
        self.uiColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        uiColor = aDecoder.decodeObject(forKey: "Color") as! UIColor
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(uiColor, forKey: "Color")
    }
}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    func rgb() -> Int? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            
            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
    
    //Multiplies the current brightness to current brightness * mulValue
    func modifiedBrightnes(mulValue: CGFloat) -> UIColor {
        
        var currentHue: CGFloat = 0.0
        var currentSaturation: CGFloat = 0.0
        var currentBrigthness: CGFloat = 0.0
        var currentAlpha: CGFloat = 0.0
        
        if self.getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentAlpha){
            var newBrightnes = currentBrigthness * mulValue
            newBrightnes = newBrightnes > 1 ? 1 : newBrightnes
            newBrightnes = newBrightnes < 0 ? 0 : newBrightnes
            let newColor = UIColor(hue: currentHue, saturation: currentSaturation, brightness: newBrightnes, alpha: currentAlpha)
            return UIColor(rgb: newColor.rgb()!)
        } else {
            return self
        }
    }
    
    //Creates a darker and lighter version of the given color, gradientMag indicates the difference between the colors
    static func createGradientColors(from color: UIColor, gradientMagnitude: CGFloat) -> [UIColor]{
        var mag = gradientMagnitude < 0 ? 0: gradientMagnitude
        mag = gradientMagnitude > 1 ? 1 : gradientMagnitude
        let colorLow = color.modifiedBrightnes(mulValue: 1 - mag)
        let colorHigh = color.modifiedBrightnes(mulValue: 1 + mag)
        return[colorHigh, colorLow]
    }
}



