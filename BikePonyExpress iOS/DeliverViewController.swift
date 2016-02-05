//
//  DeliverViewController.swift
//  BikePonyExpress iOS
//
//  Created by Raul Rondon on 9/8/15.
//  Copyright © 2015 BikePonyExpress. All rights reserved.
//

import UIKit

class DeliverViewController: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var navBar: UINavigationItem!
  @IBOutlet weak var activityCodeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var estimatedTimeLabel: UILabel!
  @IBOutlet weak var actualTimeLabel: UILabel!
  @IBOutlet weak var codeTextField: UITextField!
 
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var contentView: UIView!
  
  var visible: Bool = false
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    self.navigationController?.navigationBar.barTintColor = deliverColor
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
    
    visible = true
    self.tabBarController?.tabBar.hidden = true
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
  

  @IBAction func confirmButtomWasPressed(sender: UIButton) {
    
    view.endEditing(true)
    print("\(BPEAPI.api.tasks[activityIndex].deliveryCode)")
    
    if codeTextField.text == BPEAPI.api.tasks[activityIndex].deliveryCode {
      
      self.performSegueWithIdentifier("segueToSignatureView", sender: self)
      
    } else {
      
      myAppDelegate.displayCustomAlert(self, title: "Error", myMessageToShow: "Invalid delivery code!", actionHandler: nil)
      
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
