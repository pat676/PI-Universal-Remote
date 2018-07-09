//
//  BluetoothDevice.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 02.01.2018.
//  Copyright © 2018 Patrick Henriksen. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothDevice{
    
    var peripheral: CBPeripheral!
    var advertisementData: [String : Any]!
    var writeCharacteristic: CBCharacteristic?

    init(peripheral: CBPeripheral, advertisementData: [String : Any]){
        self.peripheral = peripheral
        self.advertisementData = advertisementData
    }
}
