//
//  ChooseLayoutViewController.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 17.02.2018.
//  Copyright © 2018 Patrick Henriksen. All rights reserved.
//

import UIKit
import Foundation

class ChooseLayoutViewController: UITableViewController {

    var dataStructure = DataStructure();
    var deviceName: String!
    var currentLayout: Layout?
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        currentLayout = dataStructure.getLayout(usedWith: deviceName);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard currentLayout != nil else {return}
        for layout in dataStructure.layouts{
            if let index = layout.usedWith.index(of: deviceName){
                layout.usedWith.remove(at: index)
            }
        }
        currentLayout!.usedWith.append(deviceName)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataStructure.layouts.count > 0 ? dataStructure.layouts.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell?
        if dataStructure.layouts.count > 0{
            cell = getLayoutCell(at: indexPath)
        }
        else{
            cell = getNoLayoutsCell()
        }
        return cell!
    }
    
    func getLayoutCell(at indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "LayoutCell", for: indexPath)
        
        let label = cell.viewWithTag(10) as! UILabel
        let text = dataStructure.layouts[indexPath.row].name
        label.text = text
        
        if(dataStructure.layouts[indexPath.row] == currentLayout){
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        return cell
    }
    
    func getNoLayoutsCell() -> UITableViewCell{
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "NoDevicesCell")
        cell.isUserInteractionEnabled = false
        cell.textLabel!.text = "No layouts found!"
        cell.detailTextLabel!.text = "Press the Edit Layouts button to add layouts"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentLayout = dataStructure.layouts[indexPath.row]
        for otherCell in tableView.visibleCells{
            otherCell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        if let cell = tableView.cellForRow(at: indexPath){
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            cell.setSelected(true, animated: true)
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: {_ in cell.setSelected(false, animated: true)})
        }
    }
}
