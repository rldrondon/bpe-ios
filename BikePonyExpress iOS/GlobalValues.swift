//
//  NSNotificationCenterKeys.swift
//  BikePonyExpress iOS
//
//  Created by Raul Rondon on 9/16/15.
//  Copyright © 2015 BikePonyExpress. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

var myAppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

var timer = NSTimer()
var routes : [MKRoute] = []

var copyOfTasks: [BPETask] = []
var copyOfRoutes: [MKRoute] = []
var activityIndex = 0

var jumpToDPViews: Bool = false

var myPosition = CLLocationCoordinate2D()

let pickupColor = UIColor(red: CGFloat(241.0/255), green: CGFloat(132.0/255), blue: CGFloat(88.0/255), alpha: 1.0)
let deliverColor = UIColor(red: CGFloat(73.0/255), green: CGFloat(195.0/255), blue: CGFloat(111.0/255), alpha: 1.0)
let defaultColor = UIColor(red: CGFloat(166.0/255), green: CGFloat(179.0/255), blue: CGFloat(196.0/255), alpha: 1.0)
let activeColor = UIColor(red: CGFloat(88.0/255), green: CGFloat(165.0/255), blue: CGFloat(255.0/255), alpha: 1.0)
let noActiveColor = UIColor(red: CGFloat(171.0/255), green: CGFloat(169.0/255), blue: CGFloat(169.0/255), alpha: 1.0)
let grayBackGroundColor = UIColor(red: CGFloat(239.0/255), green: CGFloat(239.0/255), blue: CGFloat(244.0/255), alpha: 1.0)

//NSNotificaion Keys
let newTaksKey = "BPE.NewTasksWereAssigned"
let proximityKey = "BPE.InRangeOfDestination"
let errorKey = "BPE.ErrorFound"
let errorAuthenticateKey = "BPE.ErrorAuthenticate"
let notAvailableKey = "BPE.NotAvailable"

let changePasswordPressedKey = "BPE.ChangePasswordPressed"
let cancelChangePasswordPressedKey = "BPE.CancelChangePasswordPressed"
let confirmChangePasswordPressedKey = "BPE.ConfirmChangePasswordPressed"
let logOutPressedKey = "BPE.LogOutPressed"
let switchChangedKey = "BPE.SwitchChanged"

var emailAgent = ""