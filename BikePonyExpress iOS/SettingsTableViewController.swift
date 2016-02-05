import UIKit

class SettingsTableViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{

  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var settingsTable: UITableView!
  
  let container: UIView = UIView()
  
  let indexPathPasswordChange = NSIndexPath(forRow: 0, inSection: 2)
  var expanded :Bool = false
  var switchStatus : UISwitch!
  var visible: Bool = false
  var offset: Int = 0
  

  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Navigation Bar Colors
    self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
    self.navigationController?.navigationBar.barTintColor = defaultColor
    
    //
    self.view.backgroundColor = grayBackGroundColor
    
    //Activity Indicator
    activityIndicator.hidden = true
    container.frame = self.view.frame
    container.center = self.view.center
    container.backgroundColor = UIColor(red: CGFloat(255.0/255), green: CGFloat(255.0/255), blue: CGFloat(255.0/255), alpha: 0.5)
    self.view.addSubview(container)
    self.view.sendSubviewToBack(container)
    container.addSubview(activityIndicator)
    container.hidden = true
    
    
    //Register Custom Cell
    let nib1 = UINib(nibName: "switchCellViewController", bundle: nil)
    let nib2 = UINib(nibName: "infoCellViewController", bundle: nil)
    let nib3 = UINib(nibName: "cellViewForPassword", bundle: nil)
    let nib4 = UINib(nibName: "logoutButtonCellViewController", bundle: nil)
    settingsTable.registerNib(nib1, forCellReuseIdentifier: "cell1")
    settingsTable.registerNib(nib2, forCellReuseIdentifier: "cell2")
    settingsTable.registerNib(nib3, forCellReuseIdentifier: "cell3")
    settingsTable.registerNib(nib4, forCellReuseIdentifier: "cell4")
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "changePasswordPressedCB", name: changePasswordPressedKey, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "confirmChangePasswordPressedCB", name: confirmChangePasswordPressedKey, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "cancelChangePasswordPressedCB", name: cancelChangePasswordPressedKey, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "logOutPressedCB", name: logOutPressedKey, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "switchChangedCB", name: switchChangedKey, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "newTaskWasAssigned", name: newTaksKey, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "needAuthenticateAgain", name: errorAuthenticateKey, object: nil)
    
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
    settingsTable.addGestureRecognizer(tap)
    view.addGestureRecognizer(tap)
  
  }
  
  /***** TABLE VIEW MANDATORY FUNCTION *****/
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else if section == 1 {
      return 3
    } else {
      return 2
    }
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 3
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if indexPath.section == 0 {
      
      let cell : SwitchCellViewController = self.settingsTable.dequeueReusableCellWithIdentifier("cell1") as! SwitchCellViewController
      return cell
      
    } else if indexPath.section == 1 {
      
      let cell : infoCellViewController = self.settingsTable.dequeueReusableCellWithIdentifier("cell2") as! infoCellViewController
      if indexPath.row == 0 {
        
        cell.titleField.text = "Name"
        cell.infoField.text = BPEAPI.api.agent?.name
        
      } else if indexPath.row == 1 {
        
        cell.titleField.text = "Surname"
        cell.infoField.text = BPEAPI.api.agent?.surname
        
      } else {
        
        cell.titleField.text = "Email"
        cell.infoField.text = emailAgent
        
      }
      return cell
      
    } else {
      
      if indexPath.row == 0 {
        
        let cell : cellViewForPasswordController = self.settingsTable.dequeueReusableCellWithIdentifier("cell3") as! cellViewForPasswordController
        cell.hideViews(expanded)
        cell.oldPasswordText.delegate = self
        cell.oldPasswordText.text = ""
        cell.newPasswordText.delegate = self
        cell.newPasswordText.text = ""
        cell.repeatNewPasswordText.delegate = self
        cell.repeatNewPasswordText.text = ""
        if expanded {
          cell.changePasswordButton.enabled = false
          cell.cancelButton.enabled = true
          cell.cancelButton.enabled = true
        } else {
          cell.changePasswordButton.enabled = true
          cell.cancelButton.enabled = false
          cell.cancelButton.enabled = false
        }
        
        return cell
      } else {
        
        let cell : logoutCellViewController = self.settingsTable.dequeueReusableCellWithIdentifier("cell4") as! logoutCellViewController
        return cell
      }
    }
    
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 2 && indexPath.row == 0  && expanded {
      return CGFloat(240)
    } else {
      return CGFloat(44)
    }
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "ACTIVITY"
    } else if section == 1 {
      return "AGENT INFO"
    } else {
      return ""
    }
  }
  
    /***** KEYBOARD & SCROLLING *****/

  func textFieldDidBeginEditing(textField: UITextField) {
    offset = 280
    self.settingsTable.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    offset = 0
    self.settingsTable.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
  }
  
  func dismissKeyboard() {
    view.endEditing(true)
    if expanded {
      offset = 240
      settingsTable.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    visible = true
  }
  
  override func viewWillDisappear(animated: Bool) {
    visible = false
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }

  
    /********** CALLBACKS **********/
  
  /* New Task */
  func newTaskWasAssigned(){
    
    if visible{
      myAppDelegate.displayCustomAlert(self, title: "New Tasks", myMessageToShow: "You got new tasks =)", actionHandler: nil)
    }
  }
  /**********/
  
   /* Status Change */
  func switchChangedCB(){
    
    let cell = settingsTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
    var messageToShow = ""
    var messageTitle = ""
    switchStatus = (cell as! SwitchCellViewController).switchValue
    
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
    let yesAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: changeStatusConfirmation)
    let noAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: switchChangeCancelled)
    showThisAlert.addAction(yesAction)
    showThisAlert.addAction(noAction)
    self.presentViewController(showThisAlert, animated: true, completion: nil)
    
  }
  
  func changeStatusConfirmation(actionAlert: UIAlertAction) {
  
    var status: BPEAgentStatus
    if switchStatus.on {
      status = BPEAgentStatus.Active
    } else {
      status = BPEAgentStatus.Inactive
    }
    
    //start and show acivity indicator
    activityIndicator.hidden = false
    activityIndicator.startAnimating()
    self.view.bringSubviewToFront(container)
    container.hidden = false
    
    BPEAPI.api.updateStatus(status, handler: statusUpdated)
  }
  
  func switchChangeCancelled(actionAlert: UIAlertAction){
    (settingsTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! SwitchCellViewController).cancelChange()
  }
  
  func statusUpdated(status: BPEAgentStatus?, error: BPEAPIError?) {
 
    //stop and hide activity indicator
    self.activityIndicator.hidden = true
    self.activityIndicator.stopAnimating()
    self.view.sendSubviewToBack(self.container)
    container.hidden = true
    
    if let errorType = error {
      
      if errorType == BPEAPIError.AccessDenied {
        NSNotificationCenter.defaultCenter().postNotificationName("errorAuthenticateKey", object: nil)
      } else {
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
  /**********/
   
  /* Change Password */
   
  func changePasswordPressedCB(){
    
      expanded = true
      settingsTable.reloadRowsAtIndexPaths([indexPathPasswordChange], withRowAnimation: UITableViewRowAnimation.Automatic)
      offset = 240
      settingsTable.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
    
  }
  
  func confirmChangePasswordPressedCB(){
    
    dismissKeyboard()
    let cell = settingsTable.cellForRowAtIndexPath(indexPathPasswordChange) as! cellViewForPasswordController
    
    if cell.oldPasswordText.text!.isEmpty || cell.newPasswordText.text!.isEmpty || cell.repeatNewPasswordText.text!.isEmpty {
      myAppDelegate.displayCustomAlert(self, title:"Error", myMessageToShow: "All fields are required", actionHandler: invalidPasswords)
    } else if cell.newPasswordText.text != cell.repeatNewPasswordText.text {
      myAppDelegate.displayCustomAlert(self, title:"Error", myMessageToShow: "Passwords don't match", actionHandler: invalidPasswords)
    } else if cell.newPasswordText.text == cell.oldPasswordText.text {
      myAppDelegate.displayCustomAlert(self, title:"Error", myMessageToShow: "New password should be different to the old one", actionHandler: invalidPasswords)
    } else if cell.newPasswordText.text?.characters.count < 8 {
      myAppDelegate.displayCustomAlert(self, title:"Error", myMessageToShow: "New password should have at least 8 characters", actionHandler: invalidPasswords)
    } else {
      
      //start and show acivity indicator
      activityIndicator.hidden = false
      activityIndicator.startAnimating()
      self.view.bringSubviewToFront(container)
      container.hidden = false
      
      BPEAPI.api.changePassword(cell.oldPasswordText.text!, newPassword: cell.newPasswordText.text!, handler: changePasswordHandler)
    }
  }
  
  func cancelChangePasswordPressedCB(){
    closeCell()
  }
  
  func invalidPasswords(actionAlert: UIAlertAction){
    settingsTable.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
  }
  
  func PasswordChanged(actionAlert: UIAlertAction){
    closeCell()
  }
  
  func closeCell(){
    expanded = false
    settingsTable.reloadRowsAtIndexPaths([indexPathPasswordChange], withRowAnimation: UITableViewRowAnimation.Automatic)
    offset = 0
    settingsTable.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
  }

  func changePasswordHandler(changed: Bool, error:BPEAPIError?) {
    
    //stop and hide activity indicator
    self.activityIndicator.hidden = true
    self.activityIndicator.stopAnimating()
    self.view.sendSubviewToBack(self.container)
    container.hidden = true
    
    if changed {
      
      myAppDelegate.displayCustomAlert(self, title: "Success", myMessageToShow: "Your password has been changed", actionHandler: PasswordChanged)
    } else {
      print("ERROR HERE")
        myAppDelegate.displayCustomAlert(self, title:"Error", myMessageToShow: "Invalid Password", actionHandler: invalidPasswords)
      
    }
  }
  
  /**********/
   
  /* Logout */
  func logOutPressedCB(){
    
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
    
    //start and show acivity indicator
    activityIndicator.hidden = false
    activityIndicator.startAnimating()
    self.view.bringSubviewToFront(container)
    container.hidden = false
    
    BPEAPI.api.logout(logoutHandler)
  }
  
  func logoutHandler(loggedOut: Bool, error:BPEAPIError?) {
    
    //stop and hide activity indicator
    self.activityIndicator.hidden = true
    self.activityIndicator.stopAnimating()
    self.view.sendSubviewToBack(self.container)
    container.hidden = true
    
    if loggedOut {
      myAppDelegate.displayCustomAlert(self, title: "See you soon!", myMessageToShow: "=)", actionHandler: seeYouSoon)
    } else {
      myAppDelegate.displayCustomAlert(self, title: "You can't leave now", myMessageToShow: "Costumers are waiting for you. You should finish your deliveries before loggin out", actionHandler: nil)
    }
  }
  
  func seeYouSoon(actionAlert: UIAlertAction){
    self.dismissViewControllerAnimated(true, completion: nil)
    
    
  }
  
  /**********/
  

  
  func needAuthenticateAgain() {
    if visible {
      myAppDelegate.displayCustomAlert(self, title: "Error", myMessageToShow: "You need to authenticate again", actionHandler: exitApp)
    }
  }
  
  func exitApp(actionAlert: UIAlertAction){
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}