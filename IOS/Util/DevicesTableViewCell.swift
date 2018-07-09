//
//  DevicesTableViewCell.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 17.02.2018.
//  Copyright © 2018 Patrick Henriksen. All rights reserved.
//

import UIKit

class DevicesTableViewCell: UITableViewCell {

    var deviceName: String?;
    var layout: Layout?;
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        deviceName = aDecoder.decodeObject(forKey: "DeviceName") as? String
        layout = aDecoder.decodeObject(forKey: "Layout") as? Layout
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(deviceName, forKey: "DeviceName")
        aCoder.encode(layout, forKey: "Layout")
    }
}
