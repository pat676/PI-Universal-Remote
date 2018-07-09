//
//  SettingsCell.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 11.03.2018.
//  Copyright © 2018 Patrick Henriksen. All rights reserved.
//

import UIKit

enum SettingsCellType: Int{
    case Single = 0, Top, Mid, Bottom
    
}
class SettingsCell:UITableViewCell{
    
    /*
    * A class for grouped tableViewCells with a width smaller than the tableView and rounded corners
    */
    
    //Adjusts the border width of a cell to be smaller than the tableViewWidth
    override var frame: CGRect{
        get{
            return super.frame
        }
        set(newFrame){
            super.frame = CGRect(x: newFrame.minX + SETTINGS_CELL_BORDER_WIDTH, y:newFrame.minY, width:newFrame.width - 2*SETTINGS_CELL_BORDER_WIDTH, height: newFrame.height)
        }
    }
    
    var type: SettingsCellType = .Single
    var cornerRadius: CGFloat = SETTINGS_CELL_CORNER_RADIUS
    var edgeLayer: CAShapeLayer?
    
    override func layoutMarginsDidChange() {
        if let currentLayer = edgeLayer{
            currentLayer.removeFromSuperlayer()
        }
        if(type == .Single){
            setSingleCellDesign()
        }
        else if(type == .Top){
            setTopCellDesign()
        }
        else if(type == .Mid){
            setMidCellDesign()
        }
        else if(type == .Bottom){
            setBottomCellDesign()
        }
    }
    
    //Ads a border and sets all corners to be rounded, intended for a single cell, not grouped with other cells.
    func setSingleCellDesign(){
        layer.borderWidth = 0.5;
        layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = cornerRadius
    }
    
    //Sets the two top corners as rounded and adds a border to the top and sides, intended for the top cell in a grouping
    func setTopCellDesign(){
        
        //Setting rounded top corners
        let maskRect = CGRect(x: bounds.minX, y:bounds.minX, width: bounds.width, height: bounds.height + 1)
        let maskPath = UIBezierPath(roundedRect:maskRect,
                                    byRoundingCorners:[.topRight, .topLeft],
                                    cornerRadii: CGSize(width: cornerRadius, height:  cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        
        //Setting border left top and right
        let path = UIBezierPath()
        edgeLayer = CAShapeLayer()
        
        let cornerCenterLeft = CGPoint(x:cornerRadius, y:cornerRadius)
        let cornerCenterRight = CGPoint(x:layer.bounds.maxX - cornerRadius, y:cornerRadius)
        let pi = Double.pi
        
        path.move(to: CGPoint(x:0, y:bounds.maxY))
        path.addLine(to: CGPoint(x:0, y: cornerRadius))
        path.addArc(withCenter: cornerCenterLeft, radius: cornerRadius, startAngle: CGFloat(pi), endAngle: CGFloat(3*pi/2), clockwise: true)
        path.addLine(to: CGPoint(x: bounds.maxX - cornerRadius, y:0))
        path.addArc(withCenter: cornerCenterRight, radius: cornerRadius, startAngle: CGFloat(3*pi/2), endAngle: CGFloat(2*pi), clockwise: true)
        path.addLine(to: CGPoint(x:bounds.maxX, y:bounds.maxY))
        
        edgeLayer!.path = path.cgPath
        edgeLayer!.lineWidth = 1
        edgeLayer!.strokeColor = UIColor.gray.cgColor
        edgeLayer!.fillColor = nil
        
        layer.mask = maskLayer
        layer.masksToBounds = true
        layer.addSublayer(edgeLayer!)
    }
    
    //Ads border to the sides, intended for a cell in the middle of a group
    func setMidCellDesign(){
        
        let path = UIBezierPath()
        edgeLayer = CAShapeLayer()
        path.move(to: CGPoint(x:0, y:bounds.maxY))
        path.addLine(to: CGPoint.zero)
        path.move(to: CGPoint(x:bounds.maxX, y:0))
        path.addLine(to: CGPoint(x:bounds.maxX, y:bounds.maxY))
        
        edgeLayer!.path = path.cgPath
        edgeLayer!.lineWidth = 1
        edgeLayer!.strokeColor = UIColor.gray.cgColor
        edgeLayer!.fillColor = nil
        
        layer.addSublayer(edgeLayer!)
    }
    
    //Sets the two bottom corners as rounded and adds a border to the bottom and sides, intended for the bottom cell in a grouping
    func setBottomCellDesign(){
        
        //Setting rounded top corners
        var path = UIBezierPath(roundedRect:bounds,
                                byRoundingCorners:[.bottomRight, .bottomLeft],
                                cornerRadii: CGSize(width: cornerRadius, height:  cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        
        //Setting border left top and right
        path = UIBezierPath()
        edgeLayer = CAShapeLayer()
        
        let cornerCenterLeft = CGPoint(x:cornerRadius, y:bounds.maxY - cornerRadius)
        let cornerCenterRight = CGPoint(x:layer.bounds.maxX - cornerRadius, y:bounds.maxY - cornerRadius)
        let pi = Double.pi
        
        path.move(to: CGPoint(x:0, y:0))
        path.addLine(to: CGPoint(x:0, y: bounds.maxY - cornerRadius))
        path.addArc(withCenter: cornerCenterLeft, radius: cornerRadius, startAngle: CGFloat(pi), endAngle: CGFloat(pi/2), clockwise: false)
        path.addLine(to: CGPoint(x: bounds.maxX - cornerRadius, y:bounds.maxY))
        path.addArc(withCenter: cornerCenterRight, radius: cornerRadius, startAngle: CGFloat(pi/2), endAngle: CGFloat(0), clockwise: false)
        path.addLine(to: CGPoint(x:bounds.maxX, y:0))
        
        edgeLayer!.path = path.cgPath
        edgeLayer!.lineWidth = 1
        edgeLayer!.strokeColor = UIColor.gray.cgColor
        edgeLayer!.fillColor = nil
        
        layer.mask = maskLayer
        layer.masksToBounds = true
        layer.addSublayer(edgeLayer!)
    }
}
