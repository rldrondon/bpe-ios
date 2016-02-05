//
//  FirstViewController.swift
//  BikePonyExpress iOS
//
//  Copyright © 2015 BikePonyExpress. All rights reserved.
//

import UIKit
import MapKit

class FirstViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    BPEAPI.api.authenticate("ciccio@pasticc.io", password: "qualunque", handler: authenticationDidFinish)
  }
  
  // BPEAPIDelegate methods:
  
  func authenticationDidFinish(authenticated: Bool, error: BPEAPIError?) {
    
    if let errorType = error {
      
      if errorType == BPEAPIError.AccessDenied {
        
        print("Invalid Credentials!")
      }
      else {
        
        print("Ha! Bad Request, I bet. ;)")
      }
    }
    else
    {
      if authenticated {
        print("Authenticated! :)")
        BPEAPI.api.getAgent(agentUpdated);
      }
    }
  }
  
  func agentUpdated(agent: BPEAgent?, error: BPEAPIError?) {
    
    if let errorType = error {
      
      if errorType == BPEAPIError.AccessDenied {
        
        print("Token expired, please reauthenticate!")
      }
      else {
        
        print("Ha! Bad Request, I bet. ;)")
      }
    }
    else {
      
      if let currentAgent = agent {
        print(currentAgent)
        
        // Now let's update the agent's position:
        BPEAPI.api.updatePosition(CLLocationCoordinate2D(latitude: CLLocationDegrees("45.042326")!, longitude: CLLocationDegrees("7.644228")!), handler: positionUpdated)
        
      }
      else {
        print("Couldn't get the agent, me sad :(")
      }
    }
  }
  
  func positionUpdated(tasks: [BPETask]?, error: BPEAPIError?) {
    
    if let errorType = error {
      
      if errorType == BPEAPIError.AccessDenied {
        
        print("Token expired, please reauthenticate!")
      }
      else {
        
        print("Ha! Bad Request, I bet. ;)")
      }
    }
    else {
      
      if let updatedTasks = tasks {
        print("Agent's position updated!! Here is the updated list of your tasks:")
        print(updatedTasks)
        
        // // Now Let's try to update the agent Status to Inactive
        // BPEAPI.api.updateStatus(BPEAgentStatus.Inactive)
        
        // No, now let's try something more interesting instead, let's get the Task list!
        // BPEAPI.api.getTasks(tasksUpdated)
        
        // Those were cheap tricks. Let's try to get the QUESTIONNAIRE!!!1
//        BPEAPI.api.getQuestionnaire({ (questionnaire, error) -> Void in
//          
//          if let questions = questionnaire {
//            print("HERE ARE YOUR FUCKING QUESTIONS:")
//            print(questions)
//            
//            for i in 0 ..< BPEAPI.api.questionnaire.count {
//              BPEAPI.api.questionnaire[i].vote = 5
//            }
//            
//            BPEAPI.api.saveResponses({ (responsesSaved, error) -> Void in
//              if responsesSaved {
//                print("Thanks for responding the shitty questionnaire, bro ;)")
//              }
//            })
//            
//          }
//          
//        })
        
        // This is crazy: uploading a file?!
        
//        if let imagePath = NSBundle.mainBundle().pathForResource("am", ofType: "png") {
//          
//          let imageURL = NSURL.fileURLWithPath(imagePath)
//          
//          BPEAPI.api.sendSignature(imageURL, delivery:BPEAPI.api.tasks[3], handler: { (signed, error) -> Void in
//            
//            if signed {
//              print("Delivery signed, sir!")
//            }
//            else
//            {
//              print("Couldn't send the signature :(")
//            }
//          })
//          
//        }
//        else
//        {
//          print("Can't find da image, bro...")
//        }
//        
//        
        
        // Ahahah, hilarious. This is way more serious: Let's change the password!
//        BPEAPI.api.changePassword("amore", newPassword: "qualunque", handler: { (changed, error) -> Void in
//          if changed {
//            print("Password changed, honey!")
//          }
//          else {
//            print("Couldn't change da pwdwdwdwdw.")
//          }
//        })
        
      }
      else {
        print("Couldn't update the agent's position...")
      }
    }
  }
  
  func statusUpdated(status: BPEAgentStatus?, error: BPEAPIError?) {
    
    if let errorType = error {
      
      if errorType == BPEAPIError.AccessDenied {
        
        print("Token expired, please reauthenticate!")
      }
      else {
        
        print("Ha! Bad Request, I bet. ;)")
      }
    }
    else {
    
      if let currentStatus = status {
        print("The agent is now \(currentStatus)")
        
        if currentStatus == BPEAgentStatus.Inactive {
          // This was fun, let's go back online:
          BPEAPI.api.updateStatus(BPEAgentStatus.Active, handler: statusUpdated)
        }
      }
      else {
        print("Couldn't Update the Agent's status")
      }
    }
  }
  
  func tasksUpdated(tasks: [BPETask]?, error: BPEAPIError?) {
    
    if let errorType = error {
      
      if errorType == BPEAPIError.AccessDenied {
        
        print("Token expired, please reauthenticate!")
      }
      else {
        
        print("Ha! Bad Request, I bet. ;)")
      }
    }
    else {
      
      if let updatedTasks = tasks {
        print("Tasks Updated! :) You have \(updatedTasks.count) tasks:")
        print(updatedTasks)
        
        // Invalid times:
        // BPEAPI.api.tasks![0].estimatedTime = BPEAPI.api.tasks![0].estimatedTime!.dateByAddingTimeInterval(280000)
        // BPEAPI.api.tasks![3].estimatedTime = NSDate() // another test, valid this time
        //Let's try this saveTasks method
        // BPEAPI.api.saveTasks(tasksSaved)
        
        
        // Let's try to complete the first task on the list instead, (and let's use a closure to handle the response)
//        BPEAPI.api.completeTask(handler: { (tasks, error) -> Void in
//          
//          if let errorType = error {
//            
//            if errorType == BPEAPIError.AccessDenied {
//              
//              print("Token expired, please reauthenticate!")
//            }
//            else {
//              
//              print(errorType)
//            }
//          }
//          else {
//            
//            if let updatedTasks = tasks {
//              print("Task completed, tasks list updated! :)")
//              print(updatedTasks)
//              
//            }
//            else {
//              print("Holy shit! Couldn't complete the task")
//            }
//          }
//        })
        
        
      }
      else {
        print("Holy fuck! Couldn't update the task list")
      }
    }
  }
  
  func tasksSaved(tasks: [BPETask]?, error: BPEAPIError?) {
    
    if let errorType = error {
      
      if errorType == BPEAPIError.AccessDenied {
        
        print("Token expired, please reauthenticate!")
      }
      else {
        
        print(errorType)
      }
    }
    else {
      
      if let updatedTasks = tasks {
        print("Tasks SAVED! :)")
        print(updatedTasks)
        
      }
      else {
        print("Holy fuck! Couldn't save the tasks")
      }
    }
  }
  
  ///
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

