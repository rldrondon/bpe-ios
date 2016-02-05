//
//  RatingControl.swift
//  BikePonyExpress iOS
//
//  Created by Raul Rondon on 9/18/15.
//  Copyright © 2015 BikePonyExpress. All rights reserved.
//

import UIKit

var RatingArray: [Int] = [0,0,0]

class RatingControl: UIView {
  
  //Properties
  
  var rating = 0 {
    didSet {
      setNeedsLayout()
    }
  }
  var ratingButtons = [UIButton]()
  var spacing = 1
  var stars = 5
  var buttonTag: Int = 0
  
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    let filledStarImage = UIImage(named: "fullStar")
    let emptyStarImage = UIImage(named: "emptyStar")
    
    for _ in 0..<stars {
      let button = UIButton()
      
      button.setImage(emptyStarImage, forState: .Normal)
      button.setImage(filledStarImage, forState: .Selected)
      button.setImage(filledStarImage, forState: [.Highlighted, .Selected])
      
      button.adjustsImageWhenHighlighted = false
      button.addTarget(self, action: "ratingButtonTapped:", forControlEvents: .TouchDown)
      ratingButtons += [button]
      addSubview(button)
    }
  }
  
  func ratingButtonTapped(button: UIButton) -> Int {
    
    rating = ratingButtons.indexOf(button)! + 1
    updateButtonSelectionStates()
    buttonTag = button.tag
    RatingArray[buttonTag] = rating
    return rating
    
  }
  
  override func layoutSubviews() {
    // Set the button's width and height to a square the size of the frame's height.
    let buttonSize = Int(2*frame.size.height/2.2)
    var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
    
    // Offset each button's origin by the length of the button plus some spacing.
    for (index, button) in ratingButtons.enumerate() {
      let widthInd = Int(self.frame.width)/stars
      
      let offInd = (widthInd - buttonSize)/2
      buttonFrame.origin.x = CGFloat((index*widthInd)+offInd)
    
      //buttonFrame.origin.x = CGFloat(index * (buttonSize + spacing))
      button.frame = buttonFrame
    }
    
    updateButtonSelectionStates()
    
  }
  
  override func intrinsicContentSize() -> CGSize {
    let buttonSize = Int(frame.size.height)
    let width = (buttonSize + spacing) * stars
    
    return CGSize(width: width, height: buttonSize)
  }
  
  
  func updateButtonSelectionStates() {
    
    for (index, button) in ratingButtons.enumerate() {
      // If the index of a button is less than the rating, that button should be selected.
      button.selected = index < rating
    }
    
  }
  
}
