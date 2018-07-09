//
//  BluetoothManager.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 02.01.2018.
//  Copyright © 2018 Patrick Henriksen. All rights reserved.
//

/*
 * A singleton class for simple one way comunication to one bluetooth peripheral.
 *
 * All discovered perpiherals with service UUID specified in the SERVICE_UUID constants will be stored as BluetoothDevice
 * objects in the bluetoothDevices array variable. No variables except delegate should be directly accesed, use given
 * functions to manipulate theese instead
 *
 * Known possible issues:
 *
 * When disconnecting a peripheral, the activeDevice variable will be set to nil immediatly, before the
 * centralManager(peripheralDidDisconnect) delegate function is called. This shouldn't be a problem since multiple
 * connections to peripherals are allowed by BLE. This might create problems when connecting to the same device several
 * times in fast succsesion, but no such issues were found during testing.
 *
 * I have not been able to reproduce the problem commented in: http://stackoverflow.com/questions/13286487, where
 * "disconnected" devices will stay connected for an extended periode of time and therefor not be detected by the
 * peripheral scan. I assume this issue is fixed by coreBluetooth updates, but if devices arent found by the scan after
 * the first connection, this might be the issue.
 *
 * Both these issues have easy fixes, but i havn't implemented them to maintain optimal speed.
 * Two-way comunication wasn't needed, but should be easy to implement
 */

import UIKit
import CoreBluetooth

var bluetoothManager = BluetoothManager()

protocol BluetoothManagerDelegate: class{
    
    //Required
    
    //Called when bluetooth is not available
    func bluetoothManagerNotPowered(_ manager: BluetoothManager)
    //Called when a connection failed
    
    //Optional
    func bluetoothManagerDidFailToConnect(_ manager: BluetoothManager)
    //Called when a bluetooth device has connected and is ready for comunication
    func bluetoothManagerDeviceReady(_ manager: BluetoothManager, device: BluetoothDevice)
    //Called when connection to active device is lost
    func bluetoothManagerDidLooseConnection(_ manager: BluetoothManager)
    //Called when number of availible devices is updated
    func bluetoothManagerUpdatedDeviceCount(_ manager: BluetoothManager, count: Int)
    //Called when RSSI is read
    func bluetoothManagerRSSIRead(_ manager: BluetoothManager, RSSI: NSNumber)
}

//Creating delegate optional functions
extension BluetoothManagerDelegate{
    func bluetoothManagerDidFailToConnect(_ manager: BluetoothManager){}
    func bluetoothManagerDeviceReady(_ manager: BluetoothManager, device: BluetoothDevice){}
    func bluetoothManagerDidLooseConnection(_ manager: BluetoothManager){}
    func bluetoothManagerUpdatedDeviceCount(_ manager: BluetoothManager, count: Int){}
    func bluetoothManagerRSSIRead(_ manager: BluetoothManager, RSSI: NSNumber){}
}

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    //MARK: - Variables
    weak var delegate : BluetoothManagerDelegate?
    private var manager : CBCentralManager!
    private var bluetoothDevices = ArrayWrap<BluetoothDevice>()
    private var activeDevice: BluetoothDevice?
    private var deviceReady = false
    
    //MARK: - Constants
    
    //FFE0: HM-10 bluetooth module service UUID
    private let SERVICE_UUID: [CBUUID]? = [CBUUID(string: "FFE0")]
    //FFE1: HM-10 bluetooth module write characteristic UUID
    private let CHARACTERISTIC_UUID = [CBUUID(string:"FFE1")]
    //Change this to stop auto start scanning when state changes to .poweredOn
    private let AUTO_START_SCAN = true
    //Write type
    private let WRITE_TYPE = CBCharacteristicWriteType.withResponse
    
    //MARK: - Class functions
    
    override init(){
        super.init()
        manager = CBCentralManager()
        manager.delegate = self
    }
    
    //Resets the list with discovered devices and attempts to disconnect active device
    func reset(){
        bluetoothDevices = ArrayWrap<BluetoothDevice>()
        disconnectActiveDevice()
        delegate?.bluetoothManagerUpdatedDeviceCount(self, count: bluetoothDevices.count)
    }
    
    //MARK: - Available Devices
    
    //Returns number of available devices
    func devicesCount() -> Int{
        return bluetoothDevices.count
    }
    
    //Returns the local name of device at bluetoothDevices[index]
    func deviceLocalName(at index: Int) -> String?{
        return (bluetoothDevices[index].advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? String
    }
    
    //MARK: - Active Device
    
    //Returns active device if devise ready == true, else nil
    func getActiveDevice() -> BluetoothDevice?{
        let device = deviceReady ? activeDevice : nil
        return device
    }
    
    //Sets active device to bluetoothDevices[index]
    func setActiveDevice(to index: Int){
        disconnectActiveDevice()
        activeDevice = bluetoothDevices[index]
        activeDevice!.peripheral.delegate = self
        manager.connect(activeDevice!.peripheral, options: nil)
    }
    
    //Disconnects active device
    func disconnectActiveDevice(){
        if manager.state == CBManagerState.poweredOn && activeDevice != nil{
            manager.cancelPeripheralConnection(activeDevice!.peripheral)
        }
        deviceReady = false
        activeDevice = nil
    }
    
    //Writes string to active device
    func write(message: String){
        guard deviceReady == true else{return}
        let data = message.data(using: String.Encoding.utf8)!
        if(activeDevice?.peripheral.state == .disconnected){
            disconnectActiveDevice()
            delegate?.bluetoothManagerDidLooseConnection(self)
            return
        }
        if let device = activeDevice{
            device.peripheral.writeValue(data, for: device.writeCharacteristic!, type: WRITE_TYPE)
        }
    }
    
    //Sends read RSSI command to active device, delegate is notified when result returns
    func readRSSI(){
        guard activeDevice != nil && deviceReady else{return}
        activeDevice!.peripheral.readRSSI()
    }
    
    //MARK: - Scanning
    
    //Starts scanning for peripherals, note the introductory comment under known issues
    func startScan(){
        guard manager.state == .poweredOn else {return}
        manager.scanForPeripherals(withServices: SERVICE_UUID, options:nil)
    }
    
    func stopScan(){
        guard manager.state == .poweredOn else {return}
        manager.stopScan()
    }
    
    //MARK: - CBCentralManagerDelegate
    
    //If new state is not poweredOn, reset() is called and delegate notified
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn && AUTO_START_SCAN{
            central.scanForPeripherals(withServices: SERVICE_UUID, options: nil)
        } else{
            reset()
            delegate?.bluetoothManagerNotPowered(self)
        }
    }
    
    //Ads the discovered device to bluetoothDevices
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard (!bluetoothDevices.contains(where: {$0.peripheral == peripheral})) else{return}
        if let _ = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString{
            let bluetoothDevice = BluetoothDevice(peripheral: peripheral, advertisementData: advertisementData)
            bluetoothDevices.append(bluetoothDevice)
            delegate?.bluetoothManagerUpdatedDeviceCount(self, count: bluetoothDevices.count)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate?.bluetoothManagerDidFailToConnect(self)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral){
        peripheral.discoverServices(SERVICE_UUID)
    }
    
    //MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services!{
            peripheral.discoverCharacteristics(CHARACTERISTIC_UUID, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics!{
            if  CHARACTERISTIC_UUID.contains(characteristic.uuid) && activeDevice != nil{
                activeDevice!.writeCharacteristic = characteristic
                deviceReady = true
                delegate?.bluetoothManagerDeviceReady(self, device: activeDevice!)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        delegate?.bluetoothManagerRSSIRead(self, RSSI: RSSI)
    }
}

