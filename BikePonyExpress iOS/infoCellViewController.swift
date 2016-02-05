//
//  infoCellViewController.swift
//  BikePonyExpress iOS
//
//  Created by Raul Rondon on 2/3/16.
//  Copyright © 2016 BikePonyExpress. All rights reserved.
//

import UIKit

class infoCellViewController: UITableViewCell {
  
  @IBOutlet weak var infoField: UILabel!
  @IBOutlet weak var titleField: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }

}
