//
//  MainViewController.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 24.12.2017.
//  Copyright © 2017 Patrick Henriksen. All rights reserved.
//

import UIKit
import CoreBluetooth

class MainViewController: UITableViewController, BluetoothManagerDelegate, UIPopoverPresentationControllerDelegate{

    //MARK: - Properties
    
    var dataStructure = DataStructure()
    private var popoverSourceCell: DevicesTableViewCell?;
    
    //MARK: - Outlets
    
    @IBOutlet weak var layoutsBarButton: UIBarButtonItem!
    
    //MARK: - System
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bluetoothManager.delegate = self
        bluetoothManager.reset()
        bluetoothManager.startScan()
        tableView.reloadData()
        
        //These two lines fix a bug where the bar button will stay faded on reload
        layoutsBarButton.isEnabled = false
        layoutsBarButton.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        bluetoothManager.stopScan()
    }
    
    //MARK: - TableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bluetoothManager.devicesCount() > 0 ? bluetoothManager.devicesCount() : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        var cell: UITableViewCell!
        if(bluetoothManager.devicesCount() > 0){
            cell = getBluetoothCell(at: indexPath)
        }
        else{
            cell = getNoDevicesCell()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func getBluetoothCell(at indexPath: IndexPath) -> DevicesTableViewCell{
        let cell:DevicesTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "BluetoothCell", for : indexPath) as? DevicesTableViewCell;
        cell!.deviceName = bluetoothManager.deviceLocalName(at: indexPath.row)
        cell!.layout = dataStructure.getLayout(usedWith: cell!.deviceName!);
        
        
        //Adds the device and layout name to the cell
        let label = cell!.textLabel!;
        label.text = "Device: " + cell!.deviceName!;
        let subtitleLabel = cell!.detailTextLabel!
        var layoutName = "Layout: "
        layoutName += cell!.layout != nil ? cell!.layout!.name : "None"
        subtitleLabel.text = layoutName;
        
        return cell!
    }
    
    func getNoDevicesCell() -> UITableViewCell{
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "NoDevicesCell")
        cell.isUserInteractionEnabled = false
        cell.textLabel!.text = "No bluetooth devices detected!"
        cell.detailTextLabel!.text = "Make sure the bluetooh device is powered on!"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath){
        guard let cell = tableView.cellForRow(at: indexPath) as? DevicesTableViewCell else{return}
        if(cell.layout != nil){
            performSegue(withIdentifier: "MainToRemote", sender: indexPath)
        }
        else{
            cell.setSelected(false, animated: true)
            performSegue(withIdentifier: "ChooseLayoutPopover", sender: tableView.cellForRow(at: indexPath))
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "ChooseLayoutPopover", sender: tableView.cellForRow(at: indexPath))
    }
    
    //MARK: - UIPopoverPresentationControllerDelegate
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        if let rect = popoverSourceCell?.bounds{
            popoverPresentationController.sourceView = popoverSourceCell!;
            popoverPresentationController.sourceRect = rect
            popoverPresentationController.barButtonItem = nil;
        }
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController){
        popoverSourceCell = nil;
        tableView.reloadData()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    //MARK: BluetoothManagerDelegate
    
    func bluetoothManagerUpdatedDeviceCount(_ manager: BluetoothManager, count: Int){
        tableView.reloadData()
    }
    
    func bluetoothManagerNotPowered(_ manager: BluetoothManager){
        let bluetoothAlert = UIAlertController(title: "Bluetooth Turned Off", message: "Please turn on bluetooth to use this app", preferredStyle: .alert)
        bluetoothAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(bluetoothAlert, animated: true, completion: nil)
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "MainToLayouts"){
            let controller = segue.destination as! LayoutViewController
            controller.layouts = dataStructure.layouts
        }
        else if(segue.identifier == "MainToRemote"){
            let indexPath = sender as! IndexPath
            let cell = tableView.cellForRow(at: indexPath) as! DevicesTableViewCell
            
            let controller = segue.destination as! RemoteViewController
            controller.layout = cell.layout
            controller.bluetoothDeviceNumber = indexPath.row
        }
            
        else if(segue.identifier == "ChooseLayoutPopover"){
            let controller = segue.destination as! ChooseLayoutViewController;
            popoverSourceCell = sender as? DevicesTableViewCell;
            controller.deviceName = popoverSourceCell!.deviceName
            controller.popoverPresentationController!.delegate = self
            controller.preferredContentSize = CGSize(width: 320, height: 320)
            controller.dataStructure = dataStructure
        }
    }
}
