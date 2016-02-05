//
//  LoginViewController.swift
//  BikePonyExpress iOS
//
//  Created by Raul Rondon on 9/5/15.
//  Copyright © 2015 BikePonyExpress. All rights reserved.
//

import UIKit
import MapKit

class LoginViewController: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var logoImage: UIImageView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var userEmailTextField: UITextField!
  @IBOutlet weak var userPasswordTextField: UITextField!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  var lastIdArray: [Int] = []
  var lastNumberOfTasks = 0
  var visible: Bool = true
  
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
    
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
    contentView.addGestureRecognizer(tap)
    view.addGestureRecognizer(tap)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "needAuthenticateAgain", name: errorAuthenticateKey, object: nil)
    
  }
  
  func dismissKeyboard() {
    view.endEditing(true)
  }
  
  func textFieldDidBeginEditing(textField: UITextField) {
    logoImage.hidden = true
    scrollView.setContentOffset(CGPointMake(0, 220), animated: true)
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    logoImage.hidden = false
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
  
    
  @IBAction func signinButtonPressed(sender: UIButton) {
    
    //performSegueWithIdentifier("segueToTabView", sender: self)
    view.endEditing(true)
    if userEmailTextField.text!.isEmpty || userPasswordTextField.text!.isEmpty {
      
      myAppDelegate.displayCustomAlert(self, title:"Error", myMessageToShow: "All fields are required", actionHandler: nil)
      
    } else {
      
      //start and show acivity indicator
      activityIndicator.hidden = false
      activityIndicator.startAnimating()
      self.view.bringSubviewToFront(container)
      container.hidden = false
      
      BPEAPI.api.authenticate(userEmailTextField.text!, password: userPasswordTextField.text!, handler: authenticationDidFinish)
    }
    
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.contentView.endEditing(true)
  }
  
  
  override func viewWillAppear(animated: Bool) {
    
    self.navigationController?.navigationBar.hidden = true
    userEmailTextField.text = ""
    userPasswordTextField.text = ""
    
  }
  
  
  func authenticationDidFinish(authenticated: Bool, error: BPEAPIError?){
    
    //stop and hide activity indicator
    self.activityIndicator.hidden = true
    self.activityIndicator.stopAnimating()
    self.view.sendSubviewToBack(self.container)
    container.hidden = true
    if let errorType = error {
      
      if errorType == BPEAPIError.AccessDenied {
        myAppDelegate.displayCustomAlert(self, title:"Error", myMessageToShow: "Invalid Credentials", actionHandler: nil)
      } else {
        myAppDelegate.displayCustomAlert(self, title:"Error", myMessageToShow: "Network Error", actionHandler: nil)
      }
      
    } else {
      
      if authenticated {
        emailAgent = userEmailTextField.text!
        BPEAPI.api.getAgent(agentUpdated);
      }
    }
  }
  
  func questionnaireReceived(questionnaire: [BPEQuestion]?, error: BPEAPIError?) -> Void {
    
    print("questionnaire received")
    
  }
  
  
  func agentUpdated(agent: BPEAgent?, error: BPEAPIError?) {
    
    if let errorType = error {
      if errorType == BPEAPIError.AccessDenied {
        
        NSNotificationCenter.defaultCenter().postNotificationName("errorAuthenticateKey", object: nil)
        
      } else {
    
      }
      
    } else {
      
      if let currentAgent = agent {
        
        BPEAPI.api.getQuestionnaire(questionnaireReceived)
        timer = NSTimer.scheduledTimerWithTimeInterval(30.0, target: self, selector: "timerFunc", userInfo: nil, repeats: true)
        timer.fire()
        
      } else {
        
        print("Couldn't get the agent, me sad :(")
      
      }
    }
    
  }
  
  
  func timerFunc() {
    
    if BPEAPI.api.agent != nil {
      
      lastIdArray.removeAll()
      
      for task in BPEAPI.api.tasks {
        if task.type == BPETaskType.Delivery {
          lastIdArray.append(task.deliveryId)
        }
      }
      
      lastNumberOfTasks = BPEAPI.api.tasks.count
      
      print("Timer function entered")
      
      BPEAPI.api.updatePosition(myPosition, handler: positionUpdated)

    
    }
    
  }
  
  
  func notifityErrorKey(){
    print("Notification sent")
  }
  
  
  func positionUpdated(tasks: [BPETask]?, error: BPEAPIError?) {
    
    if let errorType = error {
      
      if errorType == BPEAPIError.AccessDenied {
        // show alert session expired, segue to login view
        NSNotificationCenter.defaultCenter().postNotificationName("errorAuthenticateKey", object: nil)
      
      } else {
        
        print("Ha! Bad Request, I bet. ;)")
        
      }
    
    } else {
      
      if let updatedTasks = tasks {
        
        print("position and taks updated")
        
        if visible {
          
          //stop and hide activity indicator
          self.activityIndicator.hidden = true
          self.activityIndicator.stopAnimating()
          self.view.sendSubviewToBack(self.container)
          container.hidden = true
          
          for task in BPEAPI.api.tasks {
            if task.type == BPETaskType.Delivery {
              lastIdArray.append(task.deliveryId)
            }
          }
          
          lastNumberOfTasks = BPEAPI.api.tasks.count

          performSegueWithIdentifier("segueToTabView", sender: self)
          
        }
        
        print(lastIdArray)
        print(lastNumberOfTasks)
        
        if lastNumberOfTasks < BPEAPI.api.tasks.count {
      
          NSNotificationCenter.defaultCenter().postNotificationName(newTaksKey, object: nil)
          
        } else if thereIsNewID(lastIdArray, taskList: BPEAPI.api.tasks){
          
          NSNotificationCenter.defaultCenter().postNotificationName(newTaksKey, object: nil)
          
        }
        
      } else {
        
        print("Couldn't update the agent's position...")
        
      }
    }
  }
  
  
  func thereIsNewID (idList: [Int], taskList: [BPETask]) -> Bool {
    
    var isOld: Bool = false
    
    for task in taskList {
      
      if task.type == BPETaskType.Delivery {
      
        for idItem in idList {
        
          if task.deliveryId == idItem {
            
            isOld = true
            
          }
        }
        
        if !isOld {
          return true
        }
      }

    }
    
    return false

  }
  
  
  override func viewDidDisappear(animated: Bool) {
    visible = false
  }
  
  
  override func viewDidAppear(animated: Bool) {
    visible = true
  }

  
  func needAuthenticateAgain() {
    if visible {
      myAppDelegate.displayCustomAlert(self, title: "Error", myMessageToShow: "You need to authenticate again", actionHandler: nil)
    }
  }
  
}
