//
//  SignatureViewController.swift
//  BikePonyExpress iOS
//
//  Created by Raul Rondon on 9/14/15.
//  Copyright © 2015 BikePonyExpress. All rights reserved.
//

import UIKit

class SignatureViewController: UIViewController, DirectionsManagerDelegate {

  @IBOutlet weak var drawView: DrawView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  let container: UIView = UIView()
  var deliveryID = 0
  
  
  override func viewDidLoad() {
      
    super.viewDidLoad()
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
    
    //Clear button
    let clearView = UIBarButtonItem(title: "Clear", style: UIBarButtonItemStyle.Plain, target: self, action: "clearWasPressed")
    self.navigationItem.rightBarButtonItem = clearView
    
  }
  

  override func didReceiveMemoryWarning() {
    
    super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
  }
  
  
  func clearWasPressed(){
    
    let clearView : DrawView = drawView
    clearView.lines = []
    clearView.setNeedsDisplay()
    
  }
  
    
  @IBAction func confirmWasPressed(sender: UIButton) {
    
    //start and show acivity indicator
    activityIndicator.hidden = false
    activityIndicator.startAnimating()
    self.view.bringSubviewToFront(container)
    container.hidden = false
    
    
    deliveryID = BPEAPI.api.tasks[activityIndex].deliveryId
    BPEAPI.api.completeTask(activityIndex, handler: taskCompletionFinished)

  }
  
  
  func taskCompletionFinished(tasks: [BPETask]?, error: BPEAPIError?){
    
    if let errorType = error {
      
      if errorType == BPEAPIError.AccessDenied {
        
        print("Token expired, please reauthenticate!")
      
      } else {
        
        print(errorType)
        
      }
    
    } else {
      
      print("Task Completed")
      
      let image = DrawView.drawViewManager.getUIImageFromUIView(drawView)
      let filePath = DrawView.drawViewManager.UIImageToPNG(image)
      let NSpath = NSURL(fileURLWithPath: filePath)
      
      BPEAPI.api.sendSignature(NSpath, deliveryId: deliveryID, handler: signatureSaved)
    
    }
  
  }
  
  
  func signatureSaved(signed: Bool, error:BPEAPIError?){
    
    if let errorType = error {
      
      if errorType == BPEAPIError.AccessDenied {
        
        print("Token expired, please reauthenticate!")
      
      } else {
        
        print(errorType)
      
      }
      
    } else {
      
      if signed == true {
        
        print("Signature SAVED! :)")
        
        //calculate directions with the rest of the tasks
        if BPEAPI.api.tasks.count > 0 {
          
          let request = DirectionsManager.sharedInstance.createRequestInit()
          DirectionsManager.sharedInstance.delegate = self
          DirectionsManager.sharedInstance.calculateDirections(BPEAPI.api.tasks, request: request, indexSeed: 0)
        
        } else if BPEAPI.api.tasks.count == 0 {
          
          //stop and hide activity indicator
          self.activityIndicator.hidden = true
          self.activityIndicator.stopAnimating()
          self.view.sendSubviewToBack(self.container)
          container.hidden = true
          
          self.performSegueWithIdentifier("segueToQuestionnaireView", sender: self)

        }
        
      } else {
        
        print("Holy fuck! Couldn't save the signature")
      
      }
    }
  }
  

  func calculationDidFinish() {
    
    BPEAPI.api.tasks = DirectionsManager.sharedInstance.tasksManager
    routes = DirectionsManager.sharedInstance.routesCalculated
    
    BPEAPI.api.saveTasks(BPEAPI.api.tasks, handler: tasksSaved)
    
  }
  
  
  func tasksSaved(tasks: [BPETask]?, error: BPEAPIError?) {
    
    if let errorType = error {
      
      if errorType == BPEAPIError.AccessDenied {
        
        print("Token expired, please reauthenticate!")
        
      } else {
        
        print(errorType)
        
      }
      
    } else {
      
      if let updatedTasks = tasks {
        
        print("Tasks SAVED! :)")
        
        //stop and hide activity indicator
        self.activityIndicator.hidden = true
        self.activityIndicator.stopAnimating()
        self.view.sendSubviewToBack(self.container)
        container.hidden = true
        
        self.performSegueWithIdentifier("segueToQuestionnaireView", sender: self)
        //self.navigationController?.popToRootViewControllerAnimated(true)
        
      } else {
        
        print("Holy fuck! Couldn't save the tasks")
        
      }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    self.navigationItem.hidesBackButton = true
  }

}
