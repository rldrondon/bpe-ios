//
//  BPEAPI.swift
//  BPEAPI
//
//  Copyright © 2015 BikePonyExpress. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CryptoSwift
import MapKit



class BPEAPI {
  
  private let baseURL = "http://bikeponyexpress.me"
  private let oAuthClientId = "bpe_ios_id"
  private let oAuthClientSecret = "bpe_ios_secret"
  private let oAuthGrantType = "password"
  private var oAuthToken: String?
  
  let formatter = NSDateFormatter()

  var isAuthenticated = false
  var agent: BPEAgent?
  var tasks: [BPETask] = []
  var questionnaire: [BPEQuestion] = []
  
  static let api = BPEAPI()
  
  
  init() {
    
    self.formatter.locale = NSLocale(localeIdentifier: "it_IT")
    self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
  
  }
  
  
  // API methods:
  
  // Authenticate the user/agent
  
  func authenticate(username: String, password: String, handler: (authenticated: Bool, error:BPEAPIError?) -> Void ) {
    
    let oAuthParams = [ "grant_type":     oAuthGrantType,
                        "client_id":      oAuthClientId,
                        "client_secret":  oAuthClientSecret,
                        "username":       username,
                        "password":       password.md5()!.lowercaseString
                      ]
    
    Alamofire.request(.POST, baseURL+"/oauth/access_token", parameters: oAuthParams )
      .responseJSON { (request, response, result) in
        
        if(result.isFailure) {
          
          // If the request fails...
          
          self.agent = nil
          handler(authenticated: false, error: BPEAPIError.BadRequest)
        }
        else {
          
          let json = JSON(result.value!)
          
          if let error = json["error"].string {
            
            // If the result is an error...
            
            self.agent = nil
            let errorType = error == "invalid_credentials" ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
            handler(authenticated: false, error: errorType)
            
          }
          else {
            
            // Okay, success! :)
            
            self.oAuthToken = json["access_token"].stringValue
            
            self.isAuthenticated = true
            handler(authenticated: true, error: nil)
            
          }
        }
      }
    
  }
  
  // Get the current logged in Agent
  
  func getAgent(handler:(agent: BPEAgent?, error: BPEAPIError?) -> Void) {
    
    if !self.isAuthenticated {
      
      self.agent = nil;
      
      handler(agent: nil, error: BPEAPIError.AccessDenied)
      
    }
    else {
      
      Alamofire.request(.GET, baseURL+"/agent", parameters: ["access_token": self.oAuthToken!] )
        .responseJSON { (request, response, result) in
          if(result.isFailure || response?.statusCode != 200) {
            
            // If the request fails...
            handler(agent: nil, error: BPEAPIError.BadRequest)
          }
          else {
            
            let json = JSON(result.value!)
            
            
            if let error = json["error"].string {
              
              // If the result is an error...
              
              let errorType = error == "access_denied" ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
              handler(agent: nil, error: errorType)
              
            }
            else {
              
              // Okay, success! :)
              // Let's parse the last update to a NSDate?:
              
              var lastUpdateDate: NSDate?
              
              if let lastUpdateString = json["last_update"].string {
                
                lastUpdateDate = self.formatter.dateFromString(lastUpdateString)
              }
              
              // Let's parse the position to a CLLocationCoordinate2D?:
              
              var lastPosition2D: CLLocationCoordinate2D?
              
              if let lastPositionString = json["last_position"].string {
                let coordinates = lastPositionString.componentsSeparatedByString(",")
                lastPosition2D = CLLocationCoordinate2D(latitude: Double(coordinates[0])!, longitude: Double(coordinates[1])!)
              }
              
              self.agent = BPEAgent(
                
                id:           json["id"].intValue,
                name:         json["name"].stringValue,
                surname:      json["surname"].stringValue,
                phone:        json["phone"].stringValue,
                status:       BPEAgentStatus(rawValue: json["status"].intValue)!,
                lastPosition: lastPosition2D,
                lastUpdate:   lastUpdateDate
              )
              
              handler(agent: self.agent, error: nil)

            }
          }
      }
    }
  }
  
  
  // Current Agent position update
  
  func updatePosition(position: CLLocationCoordinate2D, handler: (tasks: [BPETask]?, error: BPEAPIError?) -> Void) {
        
    if !self.isAuthenticated || self.agent == nil {
      
      self.agent = nil;
      let errorType = !self.isAuthenticated ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
      handler(tasks: nil, error: errorType)
      
    }else {
      
      let positionString = "\(position.latitude),\(position.longitude)";
      
      let updateParams =  [ "access_token":   self.oAuthToken!,
                            "last_position":  positionString
                          ]
      
      Alamofire.request(.PUT, "\(baseURL)/agents/\(self.agent!.id)/update+deliveries", parameters: updateParams)
        .responseJSON { (request, response, result) in
          if(result.isFailure || response?.statusCode != 200) {
          
            // If the request fails...
            handler(tasks: nil, error: BPEAPIError.BadRequest)
          
          }
          else {
            
            let json = JSON(result.value!)
            
            if let error = json["error"].string {
              
              // If the result is an error...
              let errorType = error == "access_denied" ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
              handler(tasks: nil, error: errorType)
              
            }
            else {
            
              // Okay, success! :)

              self.agent!.lastPosition = position
              self.agent!.lastUpdate = NSDate()
              
              if let tasks = self.tasksFromJSON(JSON(result.value!)) {
                self.tasks = tasks
                handler(tasks: self.tasks, error: nil)
              }
              else {
                handler(tasks: nil, error: BPEAPIError.BadRequest)
              }
              
            }
          }
      }
    }
  }
  
  
  // Update Agent satuts (Active/Inactive)
  
  func updateStatus(status: BPEAgentStatus, handler: (status: BPEAgentStatus?, error: BPEAPIError?) -> Void) {
    
    if !self.isAuthenticated || self.agent == nil {
      
      self.agent = nil;
      let errorType = !self.isAuthenticated ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
      handler(status: nil, error: errorType)
    
    }else {
      
      let updateParams =  [ "access_token":   self.oAuthToken!,
                            "status":  String(status.rawValue)
                          ]
      
      Alamofire.request(.PUT, "\(baseURL)/agents/\(self.agent!.id)", parameters: updateParams)
        .responseJSON { (request, response, result) in
          if(result.isFailure || response?.statusCode != 200) {
            
            // If the request fails...
            handler(status: nil, error: BPEAPIError.BadRequest)
            
          }
          else {
            
            let json = JSON(result.value!)
            
            if let error = json["error"].string {
              
              // If the result is an error...
              let errorType = error == "access_denied" ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
              handler(status: nil, error: errorType)
            }
            else {
              
              // Okay, success! :)              
              self.agent!.status = status
              handler(status: self.agent!.status, error: nil)
            }
          }
      }
    }
  }
  
  
  // Get an updated list of the current agent's tasks, ordered by expectedTime
  func getTasks(handler:(tasks: [BPETask]?, error: BPEAPIError?) -> Void) {
    
    if !self.isAuthenticated || self.agent == nil {
      
      self.agent = nil;
      let errorType = !self.isAuthenticated ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
      handler(tasks: nil, error: errorType)
      
    }
    else {
      
      Alamofire.request(.GET, "\(baseURL)/agents/\(self.agent!.id)/deliveries", parameters: ["access_token": self.oAuthToken!] )
        .responseJSON { (request, response, result) in
          if(result.isFailure || response?.statusCode != 200) {
            
            // If the request fails...
            handler(tasks: nil, error: BPEAPIError.BadRequest)

          }
          else {
            
            let json = JSON(result.value!)
            
            
            if let error = json["error"].string {
              
              // If the result is an error...
              let errorType = error == "access_denied" ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
              handler(tasks: nil, error: errorType)
              
            }
            else {
              
              // Okay, success! :)
              if let tasks = self.tasksFromJSON(JSON(result.value!)) {
                self.tasks = tasks
                handler(tasks: self.tasks, error: nil)
              }
              else {
                handler(tasks: nil, error: BPEAPIError.BadRequest)
              }
              
            }
          }
      }
    }
  }
  
  // Update the deliveries according to the current Tasks estimatedTime(s)
  func saveTasks(tasks:[BPETask], handler:(tasks: [BPETask]?, error: BPEAPIError?) -> Void) {
    
    if !self.isAuthenticated || self.agent == nil {
      
      self.agent = nil;
      let errorType = !self.isAuthenticated ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
      handler(tasks: nil, error: errorType)
      
    }
    else {
      // Let's check and validate the tasks before
      if tasks.count > 0 && validateTasks(tasks) {
        
        // Okay, let's recombine the BPETasks into Deliveries
        
        var deliveries = [String:[String:String]]()
        
        for task in tasks {
          
          let id = String(task.deliveryId)
          
          if deliveries[id] == nil {
            deliveries[id] = [String:String]()
            deliveries[id]!["id"] = id
          }
          
          if task.type == BPETaskType.Pickup {
            
            if let actualTime = task.actualTime {
              deliveries[id]!["pickup_time"] = self.formatter.stringFromDate(actualTime)
            }
            else {
              deliveries[id]!["estimated_pickup"] = self.formatter.stringFromDate(task.estimatedTime!)
            }          
          }
          else {
            
            if let actualTime = task.actualTime {
              deliveries[id]!["delivery_time"] = self.formatter.stringFromDate(actualTime)
            }
            else {
              deliveries[id]!["estimated_delivery"] = self.formatter.stringFromDate(task.estimatedTime!)
            }
          }
        }
        
        // Now let's JSON encode the deliveries:
        let deliveriesJSON = JSON(deliveries).rawString()!
        
        // Okay, now let's make the request
        
        let updateParams =  [ "access_token": self.oAuthToken!,
                              "deliveries":   deliveriesJSON
                            ]
        
        Alamofire.request(.PUT, "\(baseURL)/deliveries", parameters: updateParams )
          .responseJSON { (request, response, result) in
            if(result.isFailure || response?.statusCode != 200) {
              
              // If the request fails...
              handler(tasks: nil, error: BPEAPIError.BadRequest)
            }
            else {
              
              let json = JSON(result.value!)
              
              
              if let error = json["error"].string {
                
                // If the result is an error...
                let errorType = error == "access_denied" ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
                handler(tasks: nil, error: errorType)
                
              }
              else {
                // Okay, success! :)
                if let tasks = self.tasksFromJSON(JSON(result.value!)) {
                  self.tasks = tasks
                  handler(tasks: self.tasks, error: nil)
                }
                else {
                  handler(tasks: nil, error: BPEAPIError.BadRequest)
                }
                
              }
            }
        }
      }
      else{
        
        handler(tasks: nil, error: BPEAPIError.InvalidData)
      }
    }
  }
  
  
  // Shorthand function to save self.tasks
  func saveTasks(handler:(tasks: [BPETask]?, error: BPEAPIError?) -> Void) {
    
    if self.tasks.count > 0 {
      self.saveTasks(self.tasks, handler: handler)
    }
    else{
      // We have nothing to save
      handler(tasks: nil, error: BPEAPIError.BadRequest)
    }
  }
  
  
  // Complete the first (or specified) task and updates the task list
  
  func completeTask(atIndex: Int = 0,  handler:(tasks: [BPETask]?, error: BPEAPIError?) -> Void) {
    
    if !self.isAuthenticated || self.agent == nil || self.tasks.count == 0 {
      
      self.agent = nil;
      let errorType = !self.isAuthenticated ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
      handler(tasks: nil, error: errorType)
      
    }
    else {
      
      if self.tasks.count > atIndex && taskCanBeCompleted(self.tasks[atIndex]) {
        
        // Okay, let's complete the task and increment the status
        self.tasks[atIndex].actualTime = NSDate()
        self.tasks[atIndex].deliveryStatus = BPEDeliveryStatus(rawValue: self.tasks[atIndex].deliveryStatus.rawValue + 1)!
        
        // Now let's update this shit
        self.saveTasks(self.tasks, handler: handler)

      }
      else {
        handler(tasks: nil, error: BPEAPIError.InvalidData)
      }
    }
  }
  
  // Alternate way: you can provide your own task you want to complete
  func completeTask(var task: BPETask, handler:(tasks: [BPETask]?, error: BPEAPIError?) -> Void) {
    
    if !self.isAuthenticated || self.agent == nil || self.tasks.count == 0 {
      
      self.agent = nil;
      let errorType = !self.isAuthenticated ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
      handler(tasks: nil, error: errorType)
      
    }
    else {
      
      if taskCanBeCompleted(task) {
        // Okay, let's complete the task and increment the status
        
        task.actualTime = NSDate()
        task.deliveryStatus = BPEDeliveryStatus(rawValue: task.deliveryStatus.rawValue + 1)!
        
        let tasksToBeCompleted: [BPETask] = [task]
        
        // Now let's update this shit
        self.saveTasks(tasksToBeCompleted, handler: handler)
      }
      else {
        handler(tasks: nil, error: BPEAPIError.InvalidData)
      }
    }
  }
  
  
  // Get the questionnnaire
  func getQuestionnaire(handler:(questionnaire: [BPEQuestion]?, error: BPEAPIError?) -> Void) {
    
    if !self.isAuthenticated || self.agent == nil {
      
      self.agent = nil;
      let errorType = !self.isAuthenticated ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
      handler(questionnaire: nil, error: errorType)
      
    }
    else {
      
      Alamofire.request(.GET, "\(baseURL)/questions", parameters: ["access_token": self.oAuthToken!] )
        .responseJSON { (request, response, result) in
          if(result.isFailure || response?.statusCode != 200) {
            
            // If the request fails...
            handler(questionnaire: nil, error: BPEAPIError.BadRequest)
            
          }
          else {
            
            let json = JSON(result.value!)
            
            
            if let error = json["error"].string {
              
              // If the result is an error...
              let errorType = error == "access_denied" ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
              handler(questionnaire: nil, error: errorType)
              
            }
            else {
              
              // Okay, success! :)
              
              var questions: [BPEQuestion] = []
              
              for (_,questionJSON):(String, JSON) in json {
              
                let question = BPEQuestion(
                  
                  id :  questionJSON["id"].intValue,
                  text: questionJSON["question_text"].stringValue,
                  vote: 0
                )
                
                questions.append(question)
              }
              
              self.questionnaire = questions
              handler(questionnaire: self.questionnaire, error: nil)
              
            }
          }
      }
    }
  }
  
  
  // Save the results of the Questionnaire
  
  func saveResponses(questionnaire:[BPEQuestion], handler:(responsesSaved: Bool, error: BPEAPIError?) -> Void) {
    
    if !self.isAuthenticated || self.agent == nil {
      
      self.agent = nil;
      let errorType = !self.isAuthenticated ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
      handler(responsesSaved: false, error: errorType)
      
    }
    else {
      // Let's check if there are questions
      if questionnaire.count > 0 {
        
        
        var responses = [String:[String:String]]()
        
        for question in questionnaire {
          
          let id = String(question.id)
          
          responses[id] = [String:String]()
          responses[id]!["question_id"] = id
          responses[id]!["vote"] = String(question.vote)
         
        }
        
        // Now let's JSON encode the responses:
        let responsesJSON = JSON(responses).rawString()!
        
        // Okay, now let's make the request
        
        let updateParams =  [ "access_token": self.oAuthToken!,
          "responses":   responsesJSON
        ]
        
        Alamofire.request(.PUT, "\(baseURL)/responses", parameters: updateParams )
          .responseJSON { (request, response, result) in
            if(result.isFailure || response?.statusCode != 200) {
              
              // If the request fails...
              handler(responsesSaved: false, error: BPEAPIError.BadRequest)
            }
            else {
              
              let json = JSON(result.value!)
              
              
              if let error = json["error"].string {
                
                // If the result is an error...
                let errorType = error == "access_denied" ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
                handler(responsesSaved: false, error: errorType)
                
              }
              else {
                // Okay, success! :)
                handler(responsesSaved: true, error: nil)
                
              }
            }
        }
      }
      else{
        
        handler(responsesSaved: false, error: BPEAPIError.InvalidData)
      }
    }
  }
  
  
  // Shorthand function to save the responses in self.questionnaire
  func saveResponses(handler:(responsesSaved: Bool, error: BPEAPIError?) -> Void) {
    
    if self.questionnaire.count > 0 {
      self.saveResponses(self.questionnaire, handler: handler)
    }
    else{
      // We have nothing to save
      handler(responsesSaved: false, error: BPEAPIError.BadRequest)
    }
  }

  
  
  // Log out the agent, if possible.
  func logout(handler: (loggedOut: Bool, error:BPEAPIError?) -> Void ) {
    
    if self.isAuthenticated {
      
      if self.tasks.count > 0 {
        
        handler(loggedOut: false, error: BPEAPIError.UncompletedTasks)
      }
      else {
        
        self.oAuthToken = nil
        self.agent = nil
        self.isAuthenticated = false
        handler(loggedOut: true, error: nil)
      }
    }
    else {
      
      handler(loggedOut: true, error: nil)
    }
  }
  
  
  // Send the image of the signature (after delivery)
  func sendSignature(signature: NSURL, delivery: BPETask, handler: (signed: Bool, error:BPEAPIError?) -> Void ) {
    
    if delivery.type == BPETaskType.Delivery {
      sendSignature(signature, deliveryId: delivery.deliveryId, handler: handler)
    }
    else
    {
      handler(signed: false, error: BPEAPIError.InvalidData)
    }
  }
  
  func sendSignature(signature: NSURL, deliveryId: Int, handler: (signed: Bool, error:BPEAPIError?) -> Void ) {
    
    
    if !self.isAuthenticated || self.agent == nil || !signature.checkResourceIsReachableAndReturnError(nil) {
      
      self.agent = nil;
      let errorType = !self.isAuthenticated ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
      handler(signed: false, error: errorType)
      
    }
    else {
      
      
      Alamofire.upload(
        .POST, "\(baseURL)/deliveries/\(deliveryId)/sign",
        multipartFormData: { multipartFormData in
          multipartFormData.appendBodyPart(data:self.oAuthToken!.dataUsingEncoding(NSUTF8StringEncoding)!, name: "access_token")
          multipartFormData.appendBodyPart(fileURL: signature, name: "signature")
        },
        encodingCompletion: { encodingResult in
          switch encodingResult {
          case .Success(let upload, _, _):
            
            upload.responseJSON { request, response, result in
              
              let json = JSON(result.value!)
              
              let error = json["error"].string
              if error != nil || response?.statusCode != 200 {
                // If the result is an error...
                let errorType = error == "access_denied" ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
                handler(signed: false, error: errorType)
                
              }
              else {
                // Okay, success! :)
                handler(signed: true, error: nil)
                
              }
              
              
            }
          case .Failure(_):
            
            handler(signed: false, error: BPEAPIError.BadRequest)
          }
        }
      )
    
    }
    
  }
  
  
  // Change the password of the Agent satuts
  
  func changePassword(oldPassword: String, newPassword:String, handler: (changed: Bool, error: BPEAPIError?) -> Void) {
    
    if !self.isAuthenticated || self.agent == nil {
      
      self.agent = nil;
      let errorType = !self.isAuthenticated ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
      handler(changed: false, error: errorType)
      
    }else {
      
      let updateParams =  [ "access_token":   self.oAuthToken!,
        "old_password":   oldPassword.md5()!,
        "new_password":   newPassword.md5()!
      ]
      
      Alamofire.request(.POST, "\(baseURL)/agent/password", parameters: updateParams)
        .responseJSON { (request, response, result) in
          if(result.isFailure || response?.statusCode != 200) {
            
            // If the request fails...
            handler(changed: false, error: BPEAPIError.BadRequest)
            
          }
          else {
            
            let json = JSON(result.value!)
            
            if let error = json["error"].string {
              
              // If the result is an error...
              let errorType = error == "access_denied" ? BPEAPIError.AccessDenied : BPEAPIError.BadRequest
              handler(changed: false, error: errorType)
            }
            else {
              
              // Okay, success! :)
              handler(changed: true, error: nil)
            }
          }
      }
    }
  }
  
  
  
  
  // Utility methods:
  
  private func tasksFromJSON(json:JSON) -> [BPETask]? {
    
    var tasks: [BPETask] = []
    
    for (_,delivery):(String, JSON) in json {
      
      let status = BPEDeliveryStatus(rawValue: delivery["state"].intValue)!
      
      // Let's break the Delivery in one or two Tasks, depending on its status:
      
      if status == BPEDeliveryStatus.ToBePicked {
        
        // Let's parse the sender position:
        let coordinates = delivery["sender_position"].stringValue.componentsSeparatedByString(",")
        
        if coordinates.count != 2 {
          return nil
        }
        
        let pickupPosition = CLLocationCoordinate2D(latitude: Double(coordinates[0])!, longitude: Double(coordinates[1])!)
        
        // Let's parse the estimated pickup time, if there's one:
        var estimatedPickupDate: NSDate?
        
        if let estimatedPickupString = delivery["estimated_pickup"].string {
          
          estimatedPickupDate = self.formatter.dateFromString(estimatedPickupString)
        }
        
        // Let's trim the address:
        var address = delivery["sender_address"].stringValue.componentsSeparatedByString(", Turin")[0]
        address = address.componentsSeparatedByString(", Torino")[0]
        
        // Okay, we are ready to create the pickup Task
        
        let pickup = BPETask(
          
          type:           BPETaskType.Pickup,
          address:        address,
          position:       pickupPosition,
          email:          delivery["sender_email"].stringValue,
          info:           delivery["sender_info"].stringValue,
          estimatedTime:  estimatedPickupDate,
          actualTime:     nil,
          deliveryId:     delivery["id"].intValue,
          deliveryStatus: status,
          trackingCode:   delivery["tracking_code"].stringValue,
          deliveryCode:   delivery["delivery_code"].stringValue
        )
        
        // Now we can add it to the Tasks array:
        
        tasks.append(pickup)
        
      }
      
      // Now let's create the delivery task:
      
      // Let's parse the recipient position:
      let coordinates = delivery["recipient_position"].stringValue.componentsSeparatedByString(",")
      
      if coordinates.count != 2 {
        return nil
      }
      
      let deliveryPosition = CLLocationCoordinate2D(latitude: Double(coordinates[0])!, longitude: Double(coordinates[1])!)
      
      // Let's parse the estimated delivery time, if there's one:
      var estimatedDeliveryDate: NSDate?
      
      if let estimatedDeliveryString = delivery["estimated_delivery"].string {
        
        estimatedDeliveryDate = self.formatter.dateFromString(estimatedDeliveryString)
      }
      
      // Let's trim the address:
      var address = delivery["recipient_address"].stringValue.componentsSeparatedByString(", Turin")[0]
      address = address.componentsSeparatedByString(", Torino")[0]
      
      let delivery = BPETask(
        
        type:           BPETaskType.Delivery,
        address:        address,
        position:       deliveryPosition,
        email:          delivery["recipient_email"].stringValue,
        info:           delivery["recipient_info"].stringValue,
        estimatedTime:  estimatedDeliveryDate,
        actualTime:     nil,
        deliveryId:     delivery["id"].intValue,
        deliveryStatus: status,
        trackingCode:   delivery["tracking_code"].stringValue,
        deliveryCode:   delivery["delivery_code"].stringValue
      )
      
      tasks.append(delivery)
    }
    
    // Let's sort it out right here, right now!
    
    tasks.sortInPlace { (a, b) -> Bool in
      
      let aDate = a.estimatedTime == nil ? NSDate.distantFuture() : a.estimatedTime!
      let bDate = b.estimatedTime == nil ? NSDate.distantFuture() : b.estimatedTime!
      
      return aDate.timeIntervalSinceReferenceDate < bDate.timeIntervalSinceReferenceDate
    }
  
    return tasks
  }
  
  // Does a sanity check on tasks estimatedTime(s)
  func validateTasks(tasks:[BPETask]) -> Bool {
    
    if tasks.count == 1 {
      return true
    }
    
    for pickup in tasks {
      if pickup.type == BPETaskType.Pickup {
        var valid = false
        for delivery in tasks {
          if delivery.type == BPETaskType.Delivery && delivery.deliveryId == pickup.deliveryId {
            
            if delivery.estimatedTime!.timeIntervalSinceReferenceDate < pickup.estimatedTime!.timeIntervalSinceReferenceDate {
              return false
            }
            valid = true
            break
          }
        }
        if !valid {
          return false
        }
      }
    }
    return true
  }
  
  // You can't complete a delivery if you still have to pickup the parcel...
  private func taskCanBeCompleted (task: BPETask) -> Bool {
    
    if task.type == BPETaskType.Delivery && task.deliveryStatus != BPEDeliveryStatus.BeingDelivered {
      return false
    }
    
    if task.type == BPETaskType.Pickup && task.deliveryStatus != BPEDeliveryStatus.ToBePicked {
      return false
    }
    
    return true
  }
  
}



