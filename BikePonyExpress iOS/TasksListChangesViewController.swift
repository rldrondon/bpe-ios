//
//  TaskListChangesViewController.swift
//  BikePonyExpress iOS
//
//  Created by Raul Rondon on 9/13/15.
//  Copyright © 2015 BikePonyExpress. All rights reserved.
//

import UIKit

class TasksListChangesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet weak var secondTableView: UITableView!
  @IBOutlet weak var navBarItem: UINavigationItem!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  var visible : Bool = false

  let container: UIView = UIView()
  
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
      
      //Cancel button
      let cancel = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelPressed")
      self.navigationItem.leftBarButtonItem = cancel
      
      //Confirm button
      let confirm = UIBarButtonItem(title: "Confirm", style: UIBarButtonItemStyle.Plain, target: self, action: "confirmPressed")
      self.navigationItem.rightBarButtonItem = confirm
      
      //Register Custom Cell
      let nib = UINib(nibName: "cellView", bundle: nil)
      secondTableView.registerNib(nib, forCellReuseIdentifier: "cell")
      
      //Clear empty cells
      let backGround = UIView(frame: CGRectZero)
      secondTableView.tableFooterView = backGround
      secondTableView.backgroundColor = grayBackGroundColor
      
      //Navigation Bar Colors
      self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
      self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
      
      //
      self.view.backgroundColor = grayBackGroundColor
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "newTaskWasAssigned", name: newTaksKey, object: nil)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "needAuthenticateAgain", name: errorAuthenticateKey, object: nil)
      
  }
  
  func newTaskWasAssigned(){
    
    if visible {
      myAppDelegate.displayCustomAlert(self, title: "New Tasks", myMessageToShow: "You got new tasks =)", actionHandler: nil)
    }
  }
  
  func cancelPressed() {
    
    copyOfTasks = BPEAPI.api.tasks
    self.navigationController?.popViewControllerAnimated(true)
    
  }
  
  
  func confirmPressed() {
    
    BPEAPI.api.tasks = copyOfTasks
    routes = copyOfRoutes
    
    //start and show acivity indicator
    activityIndicator.hidden = false
    activityIndicator.startAnimating()
    self.view.bringSubviewToFront(container)
    container.hidden = false
    
    //save tasks
    BPEAPI.api.saveTasks(tasksSaved)
    
  }
  
  override func viewWillAppear(animated: Bool) {
    secondTableView.reloadData()
    visible = true
  }
  
  //resize cell
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 97
  }
  
  //UITableViewDataSource
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return copyOfTasks.count
  }
  
  //Cells - Mandatory implementation
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell: TableViewCellController = self.secondTableView.dequeueReusableCellWithIdentifier("cell") as! TableViewCellController
    
    cell.addressOfActivityLabel.text = copyOfTasks[indexPath.row].address
    //print(tasksCpy[indexPath.row].address)
    if copyOfTasks[indexPath.row].type == BPETaskType.Pickup {
      
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
    let stringExpectedTime = formatter.stringFromDate(copyOfTasks[indexPath.row].estimatedTime!)
    cell.expectedTimeOfActivityLabel.text = stringExpectedTime
   
    //Delivery ID
    cell.codeOfActivityLabel.text = "#\(copyOfTasks[indexPath.row].deliveryId)"
    
    return cell
    
  }

  
  func tasksSaved(tasks: [BPETask]?, error: BPEAPIError?) {
    
    if let errorType = error {
      
      if errorType == BPEAPIError.AccessDenied {
        
        NSNotificationCenter.defaultCenter().postNotificationName("errorAuthenticateKey", object: nil)
      
      } else {
        
      }
    
    } else {
      
      if let updatedTasks = tasks {
        
        print("Tasks SAVED! :) dismiss view")
        
        //stop and hide activity indicator
        self.activityIndicator.hidden = true
        self.activityIndicator.stopAnimating()
        self.view.sendSubviewToBack(self.container)
        container.hidden = true
        
        self.navigationController?.popViewControllerAnimated(true)
        
      } else {
        print("Holy fuck! Couldn't save the tasks")
      }
    }
  }

  
  @IBAction func confirmChangesWasPressed(sender: UIButton) {
    
    BPEAPI.api.tasks = copyOfTasks
    routes = copyOfRoutes
    
    //start and show acivity indicator
    activityIndicator.hidden = false
    activityIndicator.startAnimating()
    self.view.bringSubviewToFront(container)
    container.hidden = false
    
    //save tasks
    BPEAPI.api.saveTasks(tasksSaved)
    
  }
  
  
  @IBAction func cancelWasPressed(sender: UIButton) {
    
    copyOfTasks = BPEAPI.api.tasks
    self.navigationController?.popViewControllerAnimated(true)
    
  }
  
  override func viewWillDisappear(animated: Bool) {
    visible = false
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
