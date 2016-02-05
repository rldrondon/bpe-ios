//
//  SettingsViewController.swift
//  BikePonyExpress iOS
//
//  Created by Raul Rondon on 9/17/15.
//  Copyright © 2015 BikePonyExpress. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
  
  @IBOutlet weak var oldPasswordTextField: UITextField!
  @IBOutlet weak var NewPasswordRepeatTextField: UITextField!
 
  @IBOutlet weak var newPasswordTextField: UITextField!
  @IBOutlet weak var switchStatus: UISwitch!
  @IBOutlet weak var agentNameTextField: UILabel!
  @IBOutlet weak var agentSurnameTextField: UILabel!
  @IBOutlet weak var agentEmailTextField: UILabel!
  @IBOutlet weak var changePasswordButton: UIButton!
  
  var visible : Bool = false
  
  var indexPathSaved : NSIndexPath?
  var buttonPressed  : Bool = false
  
  let defaultHeight : CGFloat = 44
  let expandedHeight : CGFloat = 200
  
  override func viewDidLoad() {
    super.viewDidLoad()
      
    //Navigation Bar Colors
    self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
    self.navigationController?.navigationBar.barTintColor = defaultColor
      
    //
    self.view.backgroundColor = grayBackGroundColor
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "newTaskWasAssigned", name: newTaksKey, object: nil)

  }
  
  func newTaskWasAssigned(){
    
    if visible{
      myAppDelegate.displayCustomAlert(self, title: "New Tasks", myMessageToShow: "You got new tasks =)", actionHandler: nil)
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    visible = true
    agentNameTextField.text = BPEAPI.api.agent?.name
    agentSurnameTextField.text = BPEAPI.api.agent?.surname
    agentEmailTextField.text = emailAgent
  }
  
  func statusUpdated(status: BPEAgentStatus?, error: BPEAPIError?) {
    //hide activity indicator
    if let errorType = error {
      
      if errorType == BPEAPIError.AccessDenied {
        
        print("Token expired, please reauthenticate!")
      }
      else {
        
        print("Ha! Bad Request, I bet. ;)")
      }
    } else {
      
      if let currentStatus = status {
        print("The agent is now \(currentStatus)")
        
      } else {
        print("Couldn't Update the Agent's status")
      }
    }
  
  }
  
  func changeStatusConfirmationHandler(actionAlert: UIAlertAction) {
    
    var status: BPEAgentStatus
    if switchStatus.on {
      status = BPEAgentStatus.Active
    } else {
      status = BPEAgentStatus.Inactive
    }
    //show activity indicator
    BPEAPI.api.updateStatus(status, handler: statusUpdated)
  }
  
  func changeStatusCancelled(actionAlert: UIAlertAction){
    switchStatus.on = !switchStatus.on
  }

  @IBAction func logOutWasPressed(sender: UIButton) {

    let messageToShow = "Are you sure you want to leave?"
    let messageTitle = "Wait!"
    
    let showThisAlert = UIAlertController(title: messageTitle, message: messageToShow, preferredStyle: UIAlertControllerStyle.Alert)
    let yesAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: confirmLogout)
    let noAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
    showThisAlert.addAction(yesAction)
    showThisAlert.addAction(noAction)
    self.presentViewController(showThisAlert, animated: true, completion: nil)
    
  }
  
  func confirmLogout(actionAlert: UIAlertAction){
       BPEAPI.api.logout(logoutHandler)
  }
  
  func logoutHandler(loggedOut: Bool, error:BPEAPIError?) {
    
    if loggedOut {
      myAppDelegate.displayCustomAlert(self, title: "See you soon!", myMessageToShow: "=)", actionHandler: seeYouSoon)
    } else {
      myAppDelegate.displayCustomAlert(self, title: "You can't leave now", myMessageToShow: "Costumers are waiting for you. You should finish your deliveries before loggin out", actionHandler: nil)
    }
  }
  
  func seeYouSoon(actionAlert: UIAlertAction){
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  @IBAction func changePasswordWasPressed(sender: UIButton) {
    buttonPressed = true
    tableView.reloadRowsAtIndexPaths([indexPathSaved!], withRowAnimation: UITableViewRowAnimation.Automatic)
    newPasswordTextField.hidden = false
    view.bringSubviewToFront(newPasswordTextField)
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    indexPathSaved = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section)
    print(indexPathSaved)
  }
  
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    if indexPath == indexPathSaved && buttonPressed {
      return expandedHeight
    } else {
      return defaultHeight
    }

  }

  
  @IBAction func statusWasChanged(sender: UISwitch) {
    
    var messageToShow = ""
    var messageTitle = ""
    if switchStatus.on {
      //inform you will be online
      messageToShow = "You will be now online and new deliveries can be assigned"
      messageTitle = "Going online?"
          } else {
      //inform you will be offline
      messageToShow = "You will be now offline and no deliveries will be assigned"
      messageTitle = "Going offline?"
    }
    
    let showThisAlert = UIAlertController(title: messageTitle, message: messageToShow, preferredStyle: UIAlertControllerStyle.Alert)
    let yesAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: changeStatusConfirmationHandler)
    let noAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: changeStatusCancelled)
    showThisAlert.addAction(yesAction)
    showThisAlert.addAction(noAction)
    self.presentViewController(showThisAlert, animated: true, completion: nil)
    
  }
  
  override func viewWillDisappear(animated: Bool) {
    visible = false
  }
 
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
 
}
