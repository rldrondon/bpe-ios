//
//  TasksListViewController.swift
//  BikePonyExpress iOS
//
//  Created by Raul Rondon on 9/5/15.
//  Copyright © 2015 BikePonyExpress. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class TasksListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DirectionsManagerDelegate{

  @IBOutlet weak var bikeLogo: UIImageView!
  @IBOutlet weak var emptyText: UITextView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  let container: UIView = UIView()
  var visible: Bool = true
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Activity Indicator
    activityIndicator.hidden = true
    container.frame = self.view.frame
    container.center = self.view.center
    container.backgroundColor = UIColor(red: CGFloat(255.0/255), green: CGFloat(255.0/255), blue: CGFloat(255.0/255), alpha: 0.5)
    self.view.addSubview(container)
    self.view.sendSubviewToBack(container)
    container.addSubview(activityIndicator)
    container.hidden = true
      
    //Edit button
    self.navigationItem.rightBarButtonItem = self.editButtonItem()
    self.navigationItem.backBarButtonItem?.title = "Back"
    
    //Register Custom Cell
    let nib = UINib(nibName: "cellView", bundle: nil)
    tableView.registerNib(nib, forCellReuseIdentifier: "cell")
      
    //Clear empty cells
    let backGround = UIView(frame: CGRectZero)
    tableView.tableFooterView = backGround
    tableView.backgroundColor = grayBackGroundColor
    
    //Navigation Bar Colors
    self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "newTaskWasAssigned", name: newTaksKey, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "needAuthenticateAgain", name: errorAuthenticateKey, object: nil)
  }
  
  //UITableViewDataSource - Mandatory implementation
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = BPEAPI.api.tasks.count
    if count == 0 {
      self.navigationItem.rightBarButtonItem = nil
      emptyText.hidden = false
      bikeLogo.hidden = false
      self.view.bringSubviewToFront(emptyText)
      self.view.bringSubviewToFront(bikeLogo)
    } else {
      self.navigationItem.rightBarButtonItem = self.editButtonItem()
      emptyText.hidden = true
      bikeLogo.hidden = true
      self.view.sendSubviewToBack(emptyText)
      self.view.sendSubviewToBack(bikeLogo)
    }
    return count
  }
  
  
  //Cells - Mandatory implementation
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    var tasksCpy = BPEAPI.api.tasks
    let cell: TableViewCellController = self.tableView.dequeueReusableCellWithIdentifier("cell") as! TableViewCellController
    cell.addressOfActivityLabel.text = tasksCpy[indexPath.row].address
    
    //print(tasksCpy[indexPath.row].address)
    if tasksCpy[indexPath.row].type == BPETaskType.Pickup {
      cell.typeOfActivityLabel.text = "PICKUP"
      cell.typeOfActivityLabel.textColor = pickupColor
      cell.colorOfActivityView.backgroundColor = pickupColor
    } else {
      cell.typeOfActivityLabel.text = "DELIVER"
      cell.typeOfActivityLabel.textColor = deliverColor
      cell.colorOfActivityView.backgroundColor = deliverColor
    }
    //Define expected time
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "it_IT")
    formatter.dateFormat = "HH:mm"
    let stringExpectedTime = formatter.stringFromDate(tasksCpy[indexPath.row].estimatedTime!)
    cell.expectedTimeOfActivityLabel.text = stringExpectedTime
    
    
    //Delivery ID
    cell.codeOfActivityLabel.text = "#\(tasksCpy[indexPath.row].deliveryId)"
    
    return cell
  }
  
  //resize cell
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 97
  }
  
  //Swipe Action
  func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    
    var tasksCpy = BPEAPI.api.tasks
    let ItemActivity = tasksCpy[indexPath.row].type
    var swipeAction = UITableViewRowAction()
    
    if(ItemActivity == BPETaskType.Delivery){
      swipeAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal , title: "Deliver", handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
        
        if self.wasPickedUp(BPEAPI.api.tasks[indexPath.row]) {
          //self.tabBarController?.tabBar.hidden = true
          activityIndex = indexPath.row
          self.performSegueWithIdentifier("segueToDeliverView", sender: self)
        } else {
          myAppDelegate.displayCustomAlert(self, title: "Error", myMessageToShow: "You have not visited yet the pickup address of this delivery", actionHandler: nil)
          tableView.reloadData()
        }
      })
      swipeAction.backgroundColor = deliverColor
    } else {
      swipeAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal , title: "Pickup", handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
        //self.tabBarController?.tabBar.hidden = true
        activityIndex = indexPath.row
        self.performSegueWithIdentifier("segueToPickupView", sender: self)
      })
      swipeAction.backgroundColor = pickupColor
    }
    return [swipeAction]
  }
  
  //UITableView Commit
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  }
  
  
  func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  
  func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
    
    if (tableView.editing == false){
      return UITableViewCellEditingStyle.Delete
    } else {
      return UITableViewCellEditingStyle.None
    }
  }
  
  
  func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }
  
  
  func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
    
    let itemToMove = copyOfTasks.removeAtIndex(sourceIndexPath.row)
    copyOfTasks.insert(itemToMove, atIndex: destinationIndexPath.row)
    
  }

  func prepareToUpdateTasks() {
    
    var changed : Bool = false
    var counter = 0
    
    for task in copyOfTasks {
      if task.deliveryId == BPEAPI.api.tasks[counter].deliveryId && task.type != BPEAPI.api.tasks[counter].type {
        changed = true
      } else if task.deliveryId != BPEAPI.api.tasks[counter].deliveryId {
        changed = true
      }
      counter++
    }
    
    if changed == true {
      
      for a in copyOfTasks {
        print("Before validating -> Time: \(BPEAPI.api.formatter.stringFromDate(a.estimatedTime!)), ID: \(a.deliveryId)")
      }
      
      if validateOrder(copyOfTasks) {
        //start and show acivity indicator
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        self.view.bringSubviewToFront(container)
        container.hidden = false
        
        //calculate directions with the new order
        let request = DirectionsManager.sharedInstance.createRequestInit()
        DirectionsManager.sharedInstance.delegate = self
        DirectionsManager.sharedInstance.calculateDirections(copyOfTasks, request: request, indexSeed: 0)
        
      } else {
        
        copyOfTasks = BPEAPI.api.tasks
        tableView.reloadData()
        
        myAppDelegate.displayCustomAlert(self, title: "Error", myMessageToShow: "Incorrect order. You must visit the pickup address of each task before its delivery address.", actionHandler: nil)
        
      }
    }
  }

  
  func validateOrder(tasks: [BPETask]) -> Bool {
    
    var A = 0
    var B = 0
    
    for taskA in tasks {
      B = 0
      for taskB in tasks {
        if taskA.deliveryId == taskB.deliveryId && taskA.type != taskB.type {
          if taskA.type == BPETaskType.Delivery && A < B {
            return false
          }
        }
        B++
      }
      A++
    }
    return true
  }
  
  
  func calculationDidFinish() {
    //save copy of results
    copyOfTasks = DirectionsManager.sharedInstance.tasksManager
    copyOfRoutes = DirectionsManager.sharedInstance.routesCalculated
    
    //stop and hide activity indicator
    self.activityIndicator.hidden = true
    self.activityIndicator.stopAnimating()
    self.view.sendSubviewToBack(self.container)
    container.hidden = true
    
    //show next screen
    self.performSegueWithIdentifier("segueToShowChangesView", sender: self)
    
  }
  
  func wasPickedUp(deliver: BPETask) -> Bool {
    for task in BPEAPI.api.tasks {
      if task.deliveryId == deliver.deliveryId && task.type == BPETaskType.Pickup {
        return false
      }
    }
    return true
  }
  
  func newTaskWasAssigned(){
    if visible{
      myAppDelegate.displayCustomAlert(self, title: "New Tasks", myMessageToShow: "You got new tasks =)", actionHandler: newTaskAlertHandler)
    }
  }
  
  func newTaskAlertHandler(actionAlert: UIAlertAction){
    tableView.reloadData()
  }


  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    tableView.reloadData()
    self.tabBarController?.tabBar.hidden = false
    self.navigationItem.hidesBackButton = false
    self.navigationController?.navigationBar.barTintColor = defaultColor
  }
  

  override func setEditing(editing: Bool, animated: Bool) {
    
    tableView.editing = !tableView.editing
    
    if tableView.editing == false {
      self.navigationItem.rightBarButtonItem?.title = "Edit"
      prepareToUpdateTasks()
    } else {
      copyOfTasks = BPEAPI.api.tasks
      self.navigationItem.rightBarButtonItem?.title = "Done"
    }
  }

  
  override func viewWillDisappear(animated: Bool) {
    visible = false
  }
  
  override func viewDidAppear(animated: Bool) {
    visible = true
    if jumpToDPViews {
      jumpToDPViews = false
      activityIndex = 0
      if BPEAPI.api.tasks[0].type == BPETaskType.Delivery {
        self.performSegueWithIdentifier("segueToDeliverView", sender: self)
      } else {
        self.performSegueWithIdentifier("segueToPickupView", sender: self)
      }
    }
  }
  
  func needAuthenticateAgain() {
    if visible {
      myAppDelegate.displayCustomAlert(self, title: "Error", myMessageToShow: "You need to authenticate again", actionHandler: exitApp)
    }
  }
  
  func exitApp(actionAlert: UIAlertAction){
    self.dismissViewControllerAnimated(true, completion: nil)
  }

}
