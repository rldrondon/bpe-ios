//
//  PickupViewController.swift
//  BikePonyExpress iOS
//
//  Created by Raul Rondon on 9/8/15.
//  Copyright © 2015 BikePonyExpress. All rights reserved.
//

import UIKit

class PickupViewController: UIViewController,UITextFieldDelegate, DirectionsManagerDelegate{

  @IBOutlet weak var navBar: UINavigationItem!
  @IBOutlet weak var activityCodeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var estimatedTimeLabel: UILabel!
  @IBOutlet weak var actualTimeLabel: UILabel!
  @IBOutlet weak var codeTextField: UITextField!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  let container: UIView = UIView()
  var visible:Bool = false
  
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var scrollView: UIScrollView!
  
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
    
    //Navigation Bar
    self.navigationController?.navigationBar.barTintColor = pickupColor
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
    
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
    contentView.addGestureRecognizer(tap)
    view.addGestureRecognizer(tap)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "newTaskWasAssigned", name: newTaksKey, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "needAuthenticateAgain", name: errorAuthenticateKey, object: nil)
  }
  
  func newTaskWasAssigned(){
    
    if visible {
      myAppDelegate.displayCustomAlert(self, title: "New Tasks", myMessageToShow: "You got new tasks =)", actionHandler: nil)
    }
  }
  
  func dismissKeyboard() {
    view.endEditing(true)
  }
  
  func textFieldDidBeginEditing(textField: UITextField) {
    //logoImage.hidden = true
    scrollView.setContentOffset(CGPointMake(0, 220), animated: true)
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    //logoImage.hidden = false
    scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }

  override func didReceiveMemoryWarning() {
    
    super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    
    self.tabBarController?.tabBar.hidden = true
    visible = true
    
    activityCodeLabel.text = "#\(BPEAPI.api.tasks[activityIndex].deliveryId)"
    addressLabel.text = "\(BPEAPI.api.tasks[activityIndex].address)"
    
    //Define expected time
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "it_IT")
    formatter.dateFormat = "HH:mm"
    let stringExpectedTime = formatter.stringFromDate(BPEAPI.api.tasks[activityIndex].estimatedTime!)
    let stringActualTime = formatter.stringFromDate(NSDate())
    
    estimatedTimeLabel.text = stringExpectedTime
    actualTimeLabel.text = stringActualTime

  }

  @IBAction func confirmWasPressed(sender: UIButton) {
    
    view.endEditing(true)
    
    print("\(BPEAPI.api.tasks[activityIndex].trackingCode)")
    
    if codeTextField.text == BPEAPI.api.tasks[activityIndex].trackingCode {
      
      //start and show acivity indicator
      activityIndicator.hidden = false
      activityIndicator.startAnimating()
      self.view.bringSubviewToFront(container)
      container.hidden = false
      
      BPEAPI.api.completeTask(activityIndex, handler: taskCompleted)
      
    } else {
      
      myAppDelegate.displayCustomAlert(self, title: "Error", myMessageToShow: "Invalid tracking code!", actionHandler: nil)
      
    }
  }
  
  func taskCompleted(tasks: [BPETask]?, error: BPEAPIError?){
    
    if let errorType = error {
      
      if errorType == BPEAPIError.AccessDenied {
        
        NSNotificationCenter.defaultCenter().postNotificationName("errorAuthenticateKey", object: nil)
      }
      else {
        
        
      }
    }
    else {
      
      print("Task Completed")
      
      //calculate directions with the rest of the tasks
      if BPEAPI.api.tasks.count > 0 {
        
        let request = DirectionsManager.sharedInstance.createRequestInit()
        DirectionsManager.sharedInstance.delegate = self
        DirectionsManager.sharedInstance.calculateDirections(BPEAPI.api.tasks, request: request, indexSeed: 0)
      
      }
      
    }
  
  }

  func calculationDidFinish() {
    
    BPEAPI.api.tasks = DirectionsManager.sharedInstance.tasksManager
    routes = DirectionsManager.sharedInstance.routesCalculated
    
    BPEAPI.api.saveTasks(BPEAPI.api.tasks, handler: tasksSaved)
    
  }
  
  func tasksSaved(tasks: [BPETask]?, error: BPEAPIError?) {
    
    if let errorType = error {
      
      if errorType == BPEAPIError.AccessDenied {
        
        NSNotificationCenter.defaultCenter().postNotificationName("errorAuthenticateKey", object: nil)
      
      } else {
        
      }
      
    } else {
      
      if let updatedTasks = tasks {
        
        print("Tasks SAVED! :)")
        
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
  
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  override func viewWillDisappear(animated: Bool) {
    visible = false
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
