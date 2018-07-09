//
//  LayoutViewController.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 24.12.2017.
//  Copyright © 2017 Patrick Henriksen. All rights reserved.
//

import UIKit

class LayoutViewController: UITableViewController, LayoutDetailsViewControllerDelegate {

    //MARK: - Parameters
    var layouts = ArrayWrap<Layout>();
    var isDeletingLastCell = false
    
    //MARK: - System
    
    override func viewDidLoad() {
        self.navigationController!.view.backgroundColor = UIColor.white
        tableView.allowsSelectionDuringEditing = true
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.setToolbarHidden(false, animated: false)
        updateNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController!.setToolbarHidden(true, animated: false)
    }


    // MARK: - TableView data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isDeletingLastCell) {return 0}
        return layouts.count > 0 ? layouts.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "LayoutCell", for: indexPath)
        if(layouts.count > 0){
            cell.textLabel!.text = layouts[indexPath.row].name
        }
        else{
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "NoLayoutsCell")
            cell.isUserInteractionEnabled = false
            cell.textLabel!.text = "No layouts found!"
            cell.detailTextLabel!.text = "Press the Add button to add layouts"
        }
        return cell
    }
    
    //MARK: - TableView delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(!tableView.isEditing){
            performSegue(withIdentifier: "EditLayout", sender: layouts[indexPath.row])
        }
        else{
            performSegue(withIdentifier: "LayoutDetails", sender: layouts[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle{
        if(layouts.count == 0){
            return UITableViewCellEditingStyle.none
        }
        else{
            return UITableViewCellEditingStyle.delete
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            layouts.remove(at: indexPath.row)
            
            // The if tests are there to avoid numbersOfRowsInSection returning 1  when the last cell is deleted,
            // since this will result in an error.
            if(layouts.count == 0){
                isDeletingLastCell = true
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            if(isDeletingLastCell){
                isDeletingLastCell = false
                tableView.isEditing = false
                updateNavigationBar()
                tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = layouts[sourceIndexPath.row]
        layouts.remove(at: sourceIndexPath.row)
        layouts.insert(movedObject, at: destinationIndexPath.row)
    }
    
    //MARK: - LayoutDetailsViewControllerDelegate
    
    func layoutDetailsViewControllerDidCancel(_ controller: LayoutDetailsViewController){
        controller.dismiss(animated: true, completion: nil)
    }
    
    func layoutDetialsViewControllerDidSave(_ controller: LayoutDetailsViewController){
        if (!layouts.contains(controller.layout)){ //New layout
            layouts.append(controller.layout)
        }
        tableView.reloadData()
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Navigation Bar    
    
    @objc func edit(){
        tableView.setEditing(true, animated: true)
        updateNavigationBar()
    }
    
    @objc func done(){
        tableView.setEditing(false, animated: true)
        updateNavigationBar()
    }
    
    @IBAction func add(){
        let newLayout = Layout()
        performSegue(withIdentifier: "LayoutDetails", sender: newLayout)
    }
    
    func updateNavigationBar(){
        
        if(tableView.isEditing == false){
            let rightButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
            navigationItem.setRightBarButton(rightButton, animated: true)
        }
        else if(tableView.isEditing == true){
            let rightButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
            navigationItem.setRightBarButton(rightButton, animated: true)
        }
        navigationItem.rightBarButtonItem?.isEnabled = layouts.count > 0 ? true : false
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "EditLayout"){
            let controller = segue.destination as! EditLayoutViewController
            controller.layout = sender as! Layout
        }
        else if(segue.identifier == "LayoutDetails"){
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LayoutDetailsViewController
            controller.layout = sender as! Layout
            controller.delegate = self
        }
    }
}
