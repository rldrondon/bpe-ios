//
//  switchCellViewController.swift
//  BikePonyExpress iOS
//
//  Created by Raul Rondon on 2/3/16.
//  Copyright © 2016 BikePonyExpress. All rights reserved.
//

import UIKit

class SwitchCellViewController : UITableViewCell {
  
  @IBOutlet weak var acceptTaskTextField: UILabel!
  
  @IBOutlet weak var switchValue: UISwitch!
  
  @IBAction func switchAction(sender: UISwitch) {
    NSNotificationCenter.defaultCenter().postNotificationName(switchChangedKey, object: nil)
  }
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
  
  func cancelChange(){
      switchValue.on = !switchValue.on
  }

}
