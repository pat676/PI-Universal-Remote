//
//  LayoutDetailsViewController.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 28.12.2017.
//  Copyright © 2017 Patrick Henriksen. All rights reserved.
//

import UIKit

protocol LayoutDetailsViewControllerDelegate: class{
    func layoutDetailsViewControllerDidCancel(_ controller: LayoutDetailsViewController)
    func layoutDetialsViewControllerDidSave(_ controller: LayoutDetailsViewController)
}

class LayoutDetailsViewController: UITableViewController {

    //MARK: - Properties
    
    var layout: Layout!
    weak var delegate: LayoutDetailsViewControllerDelegate!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    //MARK: - System
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = layout.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Bar Buttons
    
    @IBAction func save(){
        if let name = nameTextField.text{
            layout.name = (name != "") ? name : "New Layout"
        }
        delegate.layoutDetialsViewControllerDidSave(self)
    }
    
    @IBAction func cancel(){
        delegate.layoutDetailsViewControllerDidCancel(self)
    }
}
