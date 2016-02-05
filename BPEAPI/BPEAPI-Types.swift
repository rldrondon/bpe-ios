//
//  BPEAPI-Types.swift
//  BikePonyExpress iOS
//
//  Copyright © 2015 BikePonyExpress. All rights reserved.
//

import Foundation
import MapKit


struct BPEAgent {
  
  let id: Int
  var name: String
  var surname: String
  var phone: String
  var status: BPEAgentStatus = BPEAgentStatus.Inactive
  var lastPosition: CLLocationCoordinate2D?
  var lastUpdate: NSDate?
  
}

struct BPETask {
  
  // Task fields
  let type: BPETaskType
  let address: String
  let position: CLLocationCoordinate2D
  let email: String
  let info: String
  var estimatedTime: NSDate?
  var actualTime: NSDate?

  // Delivery fields
  let deliveryId: Int
  var deliveryStatus: BPEDeliveryStatus
  let trackingCode: String
  let deliveryCode: String
  
}

struct BPEQuestion {
  
  let id: Int
  let text: String
  var vote: Int = 0
}


// Enumerations (for convenience, you know! :)

enum BPEAgentStatus: Int {
  
  case Inactive = 0
  case Active = 1
}

enum BPETaskType {
  
  case Pickup
  case Delivery
}

enum BPEDeliveryStatus: Int {
  
  case ToBePicked = 0
  case BeingDelivered = 1
  case Delivered = 2
}

enum BPEAPIError: ErrorType {
  // Server side
  case AccessDenied
  case BadRequest
  // Client side
  case InvalidData
  case UncompletedTasks
}
