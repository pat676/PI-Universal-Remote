//
//  EditLayoutViewController.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 22.12.2017.
//  Copyright © 2017 Patrick Henriksen. All rights reserved.
//

import UIKit

class EditLayoutViewController: UIViewController, EditButtonPropertiesViewControllerDelegate, EditButtonDesignViewControllerDelegate, EditBackgroundViewControllerDelegate{

    //MARK: - Parameters
    
    var layout: Layout!
    
    //Used to determine if user is currently dragging a button.
    var dragingTimer: Timer?
    
    var selectedButton: CustomButton?{
        willSet{
            selectedButton?.deMarkSelected()
        }
        didSet{
            selectedButton?.markSelected()
            updateToolbar()
        }
    }
    var touchLocationInSelectedButton:  CGPoint?
    
    //MARK: - Outlets
    
    @IBOutlet weak var TrashButton: UIBarButtonItem!
    @IBOutlet weak var editPorpertiesBarButton: UIBarButtonItem!
    @IBOutlet weak var editDesignBarButton: UIBarButtonItem!
    
    //MARK: - System
    
    override func viewDidLoad() {
        title = layout.name
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = layout.backgroundColor.uiColor
        navigationController!.setToolbarHidden(false, animated: false)
        addAllButtons()
        addAllButtonGestures()
        updateToolbar()
        
        //These two lines fix a bug where the bar button will stay faded on reload
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController!.setToolbarHidden(true, animated: false)
        removeAllButtons()
        removeAllButtonGestures()
        selectedButton = nil;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = touches.first else {return};
        selectedButton = nil;
    }

    //MARK: - CustomButtons
    
    //Adds button to view
    func addAllButtons(){
        for button in layout.buttons{
            add(button: button)
        }
    }
    
    //Removes all buttons from view.
    func removeAllButtons(){
        for button in layout.buttons{
            button.removeFromSuperview();
        }
    }
    
    //Adds given button to view
    func add(button: CustomButton){
        view.addSubview(button)
    }
    
    //Adds tap gestures for all buttons
    func addAllButtonGestures(){
        for button in layout.buttons{
            addGestures(for: button)
        }
    }
    
    //Adds tap gesture for given button
    func addGestures(for button: CustomButton){
        button.addTarget(self, action: #selector(buttonSelected(sender:forEvent:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonDragged(sender:forEvent:)), for: .touchDragInside)
        button.addTarget(self, action: #selector(buttonDeselected(sender:forEvent:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonDeselected(sender:forEvent:)), for: .touchUpOutside)
    }
    
    //Removes tap gestures from all buttons
    func removeAllButtonGestures(){
        for button in layout.buttons{
            button.removeTarget(nil, action: nil, for: .allEvents)
        }
    }
    
    //Hides toobar and prepeares button for movement
    @objc func buttonSelected(sender: CustomButton!, forEvent event: UIEvent){
        guard let touch = event.allTouches?.first else{return}
        selectedButton = sender
        self.view.bringSubview(toFront: sender)
        touchLocationInSelectedButton = touch.location(in: sender);
    }

    //Moves button inside bounds and hides toolbar
    @objc func buttonDragged(sender: CustomButton!, forEvent event: UIEvent){
        navigationController!.setToolbarHidden(true, animated: true)
        guard let touch = event.allTouches?.first else{return}
        guard let touchLocationInButton = touchLocationInSelectedButton else{return}
        
        //Touch location is used to drag a button with anchors at thouched point
        let touchLocation = touch.location(in: self.view)

        sender.frame.origin.x = touchLocation.x - touchLocationInButton.x;
        sender.frame.origin.y = touchLocation.y - touchLocationInButton.y;
        if(sender.alignEdges){
            fitButtonToOtherButtons(button: sender)
        }
        fitButtonInsideScreen(button: sender)
    }
    
    //Shows toolbar and resets touchLocation
    @objc func buttonDeselected(sender: UIButton!, forEvent event: UIEvent){
        touchLocationInSelectedButton = nil;
        navigationController!.setToolbarHidden(false, animated: true)
    }
    
    //MARK: - Movement bounds
    
    //Adjusts button so it is inside view
    func fitButtonInsideScreen(button : CustomButton){
        let viewMinY = self.navigationController!.navigationBar.frame.maxY
        
        button.frame.origin.x = button.frame.minX <  0 ? 0 : button.frame.minX
        button.frame.origin.x = button.frame.maxX > self.view.frame.size.width ? self.view.frame.size.width - button.frame.width : button.frame.minX
        button.frame.origin.y = button.frame.minY < viewMinY ? viewMinY : button.frame.minY
        button.frame.origin.y = button.frame.maxY > self.view.frame.size.height ? self.view.frame.size.height - button.frame.height : button.frame.minY
    }
    
    //Makes button edges "snap" togheter if closer than BUTTON_EDGE_FIT_DISTANCE, declared in constants
    func fitButtonToOtherButtons(button: CustomButton){
        for otherButton in layout.buttons{
            if(otherButton == button){
                continue
            }
            
            //IntersectRect is used to calculated if buttons are close enough to align edges
            var intersectRect = button.frame
            intersectRect.size.height +=  BUTTON_EDGE_FIT_DISTANCE * 2
            intersectRect.size.width +=  BUTTON_EDGE_FIT_DISTANCE * 2
            intersectRect.origin.x -= BUTTON_EDGE_FIT_DISTANCE
            intersectRect.origin.y -= BUTTON_EDGE_FIT_DISTANCE
            
            if(!intersectRect.intersects(otherButton.frame)){
                continue
            }
            //Align x
            if(abs(button.frame.minX - otherButton.frame.maxX) < BUTTON_EDGE_FIT_DISTANCE){
                button.frame.origin.x = otherButton.frame.maxX
            }
            else if(abs(button.frame.maxX - otherButton.frame.minX) < BUTTON_EDGE_FIT_DISTANCE){
                button.frame.origin.x = otherButton.frame.minX - button.frame.width
            }
            else if(abs(button.frame.maxX - otherButton.frame.maxX) < BUTTON_EDGE_FIT_DISTANCE){
                button.frame.origin.x = otherButton.frame.maxX - button.frame.width
            }
            else if(abs(button.frame.minX - otherButton.frame.minX) < BUTTON_EDGE_FIT_DISTANCE){
                button.frame.origin.x = otherButton.frame.minX
            }
            
            //Align y
            if(abs(button.frame.minY - otherButton.frame.maxY) < BUTTON_EDGE_FIT_DISTANCE){
                button.frame.origin.y = otherButton.frame.maxY
            }
            else if(abs(button.frame.maxY - otherButton.frame.minY) < BUTTON_EDGE_FIT_DISTANCE){
                button.frame.origin.y = otherButton.frame.minY - button.frame.height
            }
            else if(abs(button.frame.maxY - otherButton.frame.maxY) < BUTTON_EDGE_FIT_DISTANCE){
                button.frame.origin.y = otherButton.frame.maxY - button.frame.height
            }
            else if(abs(button.frame.minY - otherButton.frame.minY) < BUTTON_EDGE_FIT_DISTANCE){
                button.frame.origin.y = otherButton.frame.minY
            }
        }
    }
    
    //MARK: - BarButton
    
    //Adds a new button to the layout
    @IBAction func addButtonToolbarButtonPressed(){
        let newButton = CustomButton(frame: CGRect(x : self.view.frame.size.width/2-BUTTON_STD_SIZE/2, y: self.view.frame.size.height/2-BUTTON_STD_SIZE/2, width : BUTTON_STD_SIZE, height: BUTTON_STD_SIZE))
        add(button: newButton)
        addGestures(for: newButton)
        layout.buttons.append(newButton)
    }
    
    //Changes view to the edit button properties view
    @IBAction func editButtonPropertiesToolbarButtonPressed(){
        performSegue(withIdentifier: "EditButtonProperties", sender: selectedButton)
    }
    
    @IBAction func editButtonDesignToolbarButtonPressed(){
        performSegue(withIdentifier: "EditButtonDesign", sender: selectedButton)
    }
    
    @IBAction func trashButtonPressed(){
        let buttonIndex = layout.buttons.index{$0 === selectedButton}
        assert(buttonIndex != nil, "Button to be removed not in buttons array")
        selectedButton!.removeFromSuperview()
        layout.buttons.remove(at: buttonIndex!)
        selectedButton = nil;
        updateToolbar()
    }
    
     //Disables the edit properties and edit design toolbar buttons when no button is selected
    func updateToolbar(){
        if(selectedButton == nil){
            editPorpertiesBarButton.isEnabled = false
            editDesignBarButton.isEnabled = false;
            TrashButton.isEnabled = false;

        }
        else{
            editPorpertiesBarButton.isEnabled = true
            editDesignBarButton.isEnabled = true
            TrashButton.isEnabled = true

        }
    }
    
    // MARK: - EditButtonPropertiesViewControllerDelegate
    
    func editButtonPropertiesViewControllerDidCancel(_ controller: EditButtonPropertiesViewController){
        selectedButton = controller.button
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editButtonPropertiesViewControllerDidSave(_ controller: EditButtonPropertiesViewController){
        selectedButton = controller.button
        fitButtonInsideScreen(button: controller.button)
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - EditButtonDesignViewControllerDelegate
    
    func editButtonDesignViewControllerDidCancel(_ controller: EditButtonDesignViewController) {
        selectedButton = controller.button
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editButtonDesignViewControllerDidSave(_ controller: EditButtonDesignViewController) {
        selectedButton = controller.button
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - EditBackgroundViewControllerDelegate
    
    func editLayoutBackgroundViewControllerDidCancel(_ controller: EditLayoutBackgroundViewController){
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editLayoutBackgroundViewControllerDidSave(_ controller: EditLayoutBackgroundViewController){
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        selectedButton = nil;
        if (segue.identifier == "EditButtonProperties"){
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! EditButtonPropertiesViewController
            controller.button = sender as! CustomButton
            controller.delegate = self
            controller.view.backgroundColor = layout.backgroundColor.uiColor
        }
            
        else if(segue.identifier == "EditButtonDesign"){
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! EditButtonDesignViewController
            controller.button = sender as! CustomButton
            controller.delegate = self
            controller.view.backgroundColor = layout.backgroundColor.uiColor
        }
            
        else if(segue.identifier == "EditLayoutToEditBackground"){
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! EditLayoutBackgroundViewController
            controller.layout = layout
            controller.delegate = self
        }
    }
}
