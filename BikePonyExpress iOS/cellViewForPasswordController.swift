//
//  cellViewForPasswordController.swift
//  BikePonyExpress iOS
//
//  Created by Raul Rondon on 2/3/16.
//  Copyright © 2016 BikePonyExpress. All rights reserved.
//

import UIKit

class cellViewForPasswordController : UITableViewCell {
  
  @IBOutlet weak var oldPasswordText: UITextField!
  @IBOutlet weak var newPasswordText: UITextField!
  @IBOutlet weak var repeatNewPasswordText: UITextField!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var cinfirmButton: UIButton!
  @IBOutlet weak var changePasswordButton: UIButton!

  
  class var expandedHeight : CGFloat { get {return 200}}
  class var defaultHeight : CGFloat { get {return 44}}
  
  var expanded : Bool = false

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }

  func hideViews (stateCell: Bool) {
    
    let state = stateCell
    oldPasswordText.hidden       = !state
    newPasswordText.hidden       = !state
    repeatNewPasswordText.hidden = !state
    cancelButton.hidden          = !state
    cinfirmButton.hidden         = !state
    
    if state {
    changePasswordButton.titleLabel?.textColor = noActiveColor
    }
 
  }
  
  
  @IBAction func changePasswordWasPressed(sender: UIButton ) {
    
    if changePasswordButton.enabled{
      NSNotificationCenter.defaultCenter().postNotificationName(changePasswordPressedKey, object: nil)
    }
  }
  
  @IBAction func confirmWasPressed(sender: UIButton) {
    
     NSNotificationCenter.defaultCenter().postNotificationName(confirmChangePasswordPressedKey, object: nil)

  }
  
  @IBAction func cancelWasPressed(sender: UIButton) {
    if cancelButton.enabled {
    NSNotificationCenter.defaultCenter().postNotificationName(cancelChangePasswordPressedKey, object: nil)
    }
  }
  
  
  
//  func textFieldDidBeginEditing(textField: UITextField) {
//   
//    print("sube")
//  }
//  
//  func textFieldDidEndEditing(textField: UITextField) {
//    
//    print("baja")
//  }
//  

  
  
}
