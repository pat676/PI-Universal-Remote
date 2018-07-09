//
//  File.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 22.12.2017.
//  Copyright © 2017 Patrick Henriksen. All rights reserved.
//

import Foundation
import UIKit

let BUTTON_BORDER_COLOR = UIColor(rgb: 0xbdc3c7).cgColor
let SELECTED_BUTTON_BORDER_COLOR = UIColor(rgb: 0xffffff).cgColor

let BUTTON_STD_SIZE = CGFloat(75)
let BUTTON_BORDER_WIDTH = CGFloat(1);
let BUTTON_STD_CORNER_RADIUS = CGFloat(0.0)
let BUTTON_EDGE_FIT_DISTANCE = CGFloat(5) //The distance before button edges "snap" together in editLayout

let MINIMUM_BUTTON_WIDTH: CGFloat = 60 
let MINIMUM_BUTTON_HEIGHT: CGFloat = 60

let BUTTON_GRADIENT_MAGNITUDE: CGFloat = 0.1 // Determines the intensity of buttons gradient colors
let BUTTON_BORDER_BRIGHTNES_VALUE: CGFloat = 0.8 //Determines how much darker the border Color is than the button color

let TEXT_FIELD_DECIMAL_DIGITS = 2 //Num of decimal digits in text fields

let MINIMUM_SIGNAL_REPEAT_TIME:Double = 0.1 //Default time before a signal is repeated when a button is pressed and hold
let MINIMUM_HOLD_FOR_REPEAT:Double = 0.0 //Default time before a button press is recognized as a hold

let MAX_CONNECTION_TIME:TimeInterval = 5; //Max time before a connection attempt to a bluetooth device is aborted

let MAX_TIME_BETWEEN_DRAG_EVENTS: TimeInterval = 0.2


let SETTINGS_CELL_BORDER_WIDTH: CGFloat = 10
let SETTINGS_CELL_CORNER_RADIUS: CGFloat = 10


//Predefined background colors
var BACKGROUND_COLORS = [GREY_BACKGROUND, WHITE_BACKGROUND, BLUE_BACKGROUND, RED_BACKGROUND, CORAL_BACKGROUND,  GREEN_BACKGROUND, CYAN_BACKGROUND, YELLOW_BACKGROUND, PINK_BACKGROUND]

var GREY_BACKGROUND = Color(name: "Grey", color: UIColor(rgb: 0xecf0f1))
var WHITE_BACKGROUND = Color(name: "White", color: UIColor.white)
var BLUE_BACKGROUND = Color(name: "Blue", color: UIColor(rgb: 0x4bcffa))
var RED_BACKGROUND = Color(name: "Red", color: UIColor(rgb: 0xff7f7f))
var CORAL_BACKGROUND = Color(name: "Coral", color: UIColor(rgb: 0xff7f50))
var GREEN_BACKGROUND = Color(name: "Green", color: UIColor(rgb: 0x7bed9f))
var CYAN_BACKGROUND = Color(name: "Cyan", color: UIColor(rgb: 0xB2FFFF))
var YELLOW_BACKGROUND = Color(name: "Yellow", color: UIColor(rgb: 0xffff98))
var PINK_BACKGROUND = Color(name: "Pink", color: UIColor(rgb: 0xff9ff3))

//Predefined Button colors
var BUTTON_COLORS = [GREY_BUTTON, BLACK_BUTTON, ORANGE_BUTTON, BLUE_BUTTON, RED_BUTTON, GREEN_BUTTON, CYAN_BUTTON, YELLOW_BUTTON, PINK_BUTTON]

var GREY_BUTTON = Color(name: "Grey", color: UIColor(rgb: 0xDCDCDC))
var BLACK_BUTTON = Color(name: "Black", color: UIColor(rgb: 0x000000))
var ORANGE_BUTTON = Color(name: "Orange", color: UIColor(rgb: 0xff9600))
var BLUE_BUTTON = Color(name: "Blue", color: UIColor(rgb: 0x0066ff)) 
var RED_BUTTON = Color(name: "Red", color: UIColor(rgb: 0xEA2027))
var GREEN_BUTTON = Color(name: "Green", color: UIColor(rgb: 0x00cc00))
var CYAN_BUTTON = Color(name: "Cyan", color: UIColor(rgb: 0x00ffff))
var YELLOW_BUTTON = Color(name: "Yellow", color: UIColor(rgb: 0xffff00))
var PINK_BUTTON = Color(name: "Pink", color: UIColor(rgb: 0xEE3A8C))
