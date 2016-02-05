//
//  TableViewCellController.swift
//  BikePonyExpress iOS
//
//  Created by Raul Rondon on 9/9/15.
//  Copyright © 2015 BikePonyExpress. All rights reserved.
//

import UIKit

class TableViewCellController: UITableViewCell {


  @IBOutlet weak var colorOfActivityView: UIView!
  @IBOutlet weak var typeOfActivityLabel: UILabel!
  @IBOutlet weak var addressOfActivityLabel: UILabel!
  @IBOutlet weak var codeOfActivityLabel: UILabel!
  @IBOutlet weak var expectedTimeOfActivityLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
