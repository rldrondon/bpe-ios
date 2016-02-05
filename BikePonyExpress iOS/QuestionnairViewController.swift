//
//  QuestionnairViewController.swift
//  BikePonyExpress iOS
//
//  Created by Raul Rondon on 9/14/15.
//  Copyright © 2015 BikePonyExpress. All rights reserved.
//

import UIKit

class QuestionnairViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet weak var questionsTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = grayBackGroundColor
    
    //Register Custom Cell
    let nib = UINib(nibName: "questionnaireCellView", bundle: nil)
    questionsTableView.registerNib(nib, forCellReuseIdentifier: "cell")

        // Do any additional setup after loading the view.
  }

  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
  }
  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return BPEAPI.api.questionnaire.count
  }
  
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell: QuestionnaireTableViewCell = self.questionsTableView.dequeueReusableCellWithIdentifier("cell") as! QuestionnaireTableViewCell
    
    cell.questionText.text = BPEAPI.api.questionnaire[indexPath.row].text
    
    cell.ratingControl.ratingButtons[0].tag = indexPath.row
    cell.ratingControl.ratingButtons[1].tag = indexPath.row
    cell.ratingControl.ratingButtons[2].tag = indexPath.row
    cell.ratingControl.ratingButtons[3].tag = indexPath.row
    cell.ratingControl.ratingButtons[4].tag = indexPath.row
    
    return cell
    
  }

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 112
  }
  
  override func viewWillAppear(animated: Bool) {
    questionsTableView.reloadData()
    self.navigationItem.hidesBackButton = true
  }
  
  @IBAction func confirmWasPressed(sender: UIButton) {
    var i = 0
    for item in RatingArray {
      BPEAPI.api.questionnaire[i].vote = item
      print(BPEAPI.api.questionnaire[i].vote)
      i++
    }
    
    BPEAPI.api.saveResponses(saveResponsesHandler)
  }
  
  func saveResponsesHandler (responsesSaved: Bool, error: BPEAPIError?) -> Void {
    
    if let errorType = error {
      
      if errorType == BPEAPIError.AccessDenied {
        // show alert session expired, segue to login view
        print("Token expired, please reauthenticate!")
        
      } else {
        
        print("Ha! Bad Request, I bet. ;)")
        
      }
      
    } else {
      
      self.navigationController?.popToRootViewControllerAnimated(true)
      
    }
      

  
  }

}
