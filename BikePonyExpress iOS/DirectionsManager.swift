import UIKit
import CoreLocation
import MapKit

protocol DirectionsManagerDelegate {
  func calculationDidFinish()
}


class DirectionsManager: NSObject  {
  
  static let sharedInstance = DirectionsManager()
  
  var delegate: DirectionsManagerDelegate!
  var routesCalculated: [MKRoute] = []
  var tasksManager : [BPETask] = []
  var accumulatedTime : NSTimeInterval = 0.0

  
  func calculateDirections(tasksArray: [BPETask],request: MKDirectionsRequest,indexSeed: Int) {
    
    if indexSeed == 0 {
      
      routesCalculated.removeAll()
      tasksManager.removeAll()
      accumulatedTime = 0.0
      
    }
    
    var destinationsCpy = tasksArray
    var indexToPass = indexSeed
    let placemark = MKPlacemark(coordinate: destinationsCpy[0].position, addressDictionary: nil)
    request.destination = MKMapItem(placemark: placemark)
    
    let directions = MKDirections(request: request)
    
    directions.calculateDirectionsWithCompletionHandler { (response: MKDirectionsResponse?, error: NSError?) -> Void in
      
      if error != nil{
        
        print("ERROR: " + error!.localizedDescription)
        return
      
      } else {
        
        for route in response!.routes as [MKRoute] {
          
          self.routesCalculated.append(route)
          
          let task = destinationsCpy[0]
          self.tasksManager.append(task)
          
          // TaskTime = BikeTime(=WalkTime/2.5) + CompletionTime(=300s)
          self.accumulatedTime = self.accumulatedTime + route.expectedTravelTime/2.5 + 300
          self.tasksManager[indexToPass].estimatedTime = NSDate(timeIntervalSinceNow: self.accumulatedTime)
          
        }
        
        //Response for direction calculation completed
        request.source = request.destination
        destinationsCpy.removeAtIndex(0)
        indexToPass++
        
        if destinationsCpy.count > 0 {
          
          self.calculateDirections(destinationsCpy,request: request, indexSeed: indexToPass)
        
        } else {
          
          if self.delegate != nil {
            
            self.accumulatedTime = 0.0
            self.delegate.calculationDidFinish()
            
          }
        }
      }
    }
  }
    
  
  func showRoutesOnMapView(routesToShow: [MKRoute], mapView: MKMapView) {
    
    for route in routesToShow {
      
      mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
      
    }
    
  }
  
  
  func createRequestInit() -> MKDirectionsRequest {
    
    let request = MKDirectionsRequest()
    request.source = MKMapItem(placemark: MKPlacemark(coordinate: myPosition, addressDictionary: nil))
    request.requestsAlternateRoutes = false
    request.transportType = MKDirectionsTransportType.Walking
    
    return request
  
  }
  
}