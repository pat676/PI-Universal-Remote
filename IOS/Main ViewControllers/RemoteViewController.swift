//
//  RemoteViewController.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 22.12.2017.
//  Copyright © 2017 Patrick Henriksen. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth

class RemoteViewController: UIViewController, BluetoothManagerDelegate{
    
    //MARK: - Outlets
    @IBOutlet weak var editLayoutButton: UIBarButtonItem!
    
    //MARK: - Parameters
    var layout: Layout!
    var bluetoothDeviceNumber: Int! //The array number of the current bluetooth device
    
    private var buttonPressedTimer: Timer? //Used for press and hold button to repeat signals
    private var selectedButton: CustomButton? //The button currently selected by the user
    private var timer: Timer? //Used for loading screen
    
    //Setting this parameter will control the loading screen
    private var isLoading: Bool = false{
        willSet(newValue){
            if(newValue == true){
                navigationItem.hidesBackButton = true
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
            else if(isLoading == true && newValue == false){
                dismiss(animated: true, completion: nil)
                navigationItem.hidesBackButton = false
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }

    //MARK: - System
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = layout.backgroundColor.uiColor
        
        //Theese two lines fix a bug where the bar button stays faded after reload
        editLayoutButton.isEnabled = false
        editLayoutButton.isEnabled = true
        
        bluetoothConnect()
        addAllButtons()
        addAllButtonGestures()
    }
    
    override func viewWillDisappear(_ animated: Bool){
        bluetoothDisconnect()
        removeAllButtons()
        removeAllButtonGestures()
        
        //Hide the back button until bluetooth connection is achieved
        navigationItem.hidesBackButton = true
    }
    
    @objc func applicationWillEnterForeground(){
        deselectAllButtons()
    }
    
    //MARK: - Buttons
    
    private func addAllButtons(){
        for button in layout.buttons{
            view.addSubview(button)
        }
    }
    
    private func removeAllButtons(){
        for button in layout.buttons{
            button.removeFromSuperview()
        }
    }
    
    private func addAllButtonGestures(){
        for button in layout.buttons{
            //Press and hold functionallity
            button.longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressHandler(gesture:)))
            button.longPress!.minimumPressDuration = button.minLongPressDuration;
            button.addGestureRecognizer(button.longPress!);
        
            //Tap functionallity
            button.addTarget(self, action: #selector(buttonSelected(sender:forEvent:)), for: .touchDown)
            button.addTarget(self, action: #selector(buttonDeselected(sender:forEvent:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(buttonDeselected(sender:forEvent:)), for: .touchUpOutside)
        }
    }
    
    private func removeAllButtonGestures(){
        for button in layout.buttons{
            guard let longPress = button.longPress else{continue}
            button.removeGestureRecognizer(longPress)
            button.removeTarget(nil, action: nil, for: .allEvents)
        }
    }
    
    @objc func buttonSelected(sender: CustomButton!, forEvent event: UIEvent){
        sender.setGradientColors(inverted: true)
        selectedButton = sender;
        sendSignal()
    }
    
    @objc func buttonDeselected(sender: CustomButton!, forEvent event: UIEvent){
        sender.setGradientColors(inverted: false)
        selectedButton = nil;
    }

    @objc func longPressHandler(gesture: UILongPressGestureRecognizer){
        guard let button = gesture.view as? CustomButton else{return}
        if gesture.state == .began{
            button.setGradientColors(inverted: true)
            buttonPressedTimer = Timer.scheduledTimer(timeInterval: button.repeatSignalDelay, target: self, selector: #selector(sendSignal), userInfo: nil, repeats: true)
        }
        else if (gesture.state == .ended || gesture.state == .cancelled){
            button.setGradientColors(inverted: false)
            buttonPressedTimer?.invalidate()
            buttonPressedTimer = nil;
        }
    }
    
    @objc func sendSignal(){
        if let button = selectedButton{
            bluetoothManager.write(message: button.bluetoothSignal)
        }
    }
    
    private func deselectAllButtons(){
        for button in layout.buttons{
            button.setGradientColors(inverted: false)
        }
    }
    

    //MARK: - BluetoothManagerDelegate
    
    func bluetoothManagerDeviceReady(_ manager: BluetoothManager, device: BluetoothDevice){
        isLoading = false
    }
    
    func bluetoothManagerNotPowered(_ manager: BluetoothManager){
        lostConnection()
    }
    
    func bluetoothManagerDidFailToConnect(_ manager: BluetoothManager){
        lostConnection()
    }

    func bluetoothManagerDidLooseConnection(_ manager: BluetoothManager) {
        lostConnection()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RemoteToEditLayout"{
            let controller = segue.destination as! EditLayoutViewController
            controller.layout = layout
        }
    }
    
    //Mark: - Util
    
    // Connects to the bluetooth device and presents a loading screen
    private func bluetoothConnect(){
        bluetoothManager.delegate = self
        
        let alert = UIAlertController(title: nil, message: "Connecting...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        
        present(alert, animated: true, completion: {bluetoothManager.setActiveDevice(to: self.bluetoothDeviceNumber)})
        
        connectingTimer()
        isLoading = true
    }
    
    //Disconnects from active bluetooth device. Should only be called when view is dismissed
    private func bluetoothDisconnect(){
        isLoading = false
        timer?.invalidate();
        bluetoothManager.delegate = nil
        bluetoothManager.disconnectActiveDevice()
    }
    
    //Connecting timer, aborts connection after MAX_CONNECTION_TIME
    private func connectingTimer(){
        timer = Timer.scheduledTimer(withTimeInterval: MAX_CONNECTION_TIME, repeats: false, block: {_ in self.abortConnection()})
    }
    
    //MARK: - Connection Error Messages
    
    //This function will be called by the timer if bluetooth connection fails, controll is returned to MainViewController
    private func abortConnection(){
        guard isLoading else{return}
        dismiss(animated: true, completion: nil)
        let connectionFailedAlert = UIAlertController(title: "Error", message: "Failed to connect", preferredStyle: .alert)
        connectionFailedAlert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: {_ in self.navigationController?.popViewController(animated: true)}))
        present(connectionFailedAlert, animated: true, completion: nil)
    }
    
    //This function will be called if connection is lost during session. An alert will be displayed and controll is returned to MainViewController
    private func lostConnection(){
        guard !isLoading else{return}
        deselectAllButtons()
        let lostConnectionAlert = UIAlertController(title: "Error", message: "Connection to bluetooth device lost", preferredStyle: .alert)
        lostConnectionAlert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: {_ in self.navigationController?.popViewController(animated: true)}))
        present(lostConnectionAlert, animated: true, completion: nil)
    }
}

