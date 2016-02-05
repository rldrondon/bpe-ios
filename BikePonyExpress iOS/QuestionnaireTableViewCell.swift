//
//  QuestionnaireCellViewControllerTableViewCell.swift
//  BikePonyExpress iOS
//
//  Created by Raul Rondon on 9/18/15.
//  Copyright © 2015 BikePonyExpress. All rights reserved.
//

import UIKit

class QuestionnaireTableViewCell: UITableViewCell {

  @IBOutlet weak var ratingControl: RatingControl!
  @IBOutlet weak var questionText: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
