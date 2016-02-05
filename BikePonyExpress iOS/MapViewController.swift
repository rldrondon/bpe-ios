//
//  MapViewController.swift
//  BikePonyExpress iOS
//
//  Created by Raul Rondon on 9/5/15.
//  Copyright © 2015 BikePonyExpress. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController,  CLLocationManagerDelegate, DirectionsManagerDelegate, MKMapViewDelegate{
  
  let locationManager = CLLocationManager()
  var firstTime : Bool = true
  var oldTasks : [BPETask] = []
  var needToRefreshDirections : Bool = false
  var visible : Bool = false
  var oldTopTask : BPETask?
  var circle : MKCircle?
  var alertShouldAppear : Bool = false
  
  @IBOutlet weak var mapView: MKMapView!
  
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    locationManager.startUpdatingLocation()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "newTaskWasAssigned", name: newTaksKey, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "inRangeOfDestination", name: proximityKey, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "needAuthenticateAgain", name: errorAuthenticateKey, object: nil)
  }
  
  //Callback fot notification that the agent has arrived to the location
  func inRangeOfDestination(){
   
    if visible && alertShouldAppear {
      
      alertShouldAppear = false
      let messageTitle = "You have arrived"
      let messageToShow = BPEAPI.api.tasks[0].type == BPETaskType.Delivery ? "Have you found the Recipient? If not, you can look around... You are really close!" : "Have you found the Sender? If not, you can look around... You are really close!"
      let actionTitle = BPEAPI.api.tasks[0].type == BPETaskType.Delivery ? "Recipient found" : " Sender found "
      let showThisAlert = UIAlertController(title: messageTitle, message: messageToShow, preferredStyle: UIAlertControllerStyle.Alert)
      let yesAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default, handler: goToEndView)
      let noAction = UIAlertAction(title: "Not yet", style: UIAlertActionStyle.Default, handler: nil)
      showThisAlert.addAction(yesAction)
      showThisAlert.addAction(noAction)
      self.presentViewController(showThisAlert, animated: true, completion: nil)
    
    }
    
  }
  
  //callback for the alert action: found the person
  func goToEndView(actionAlert: UIAlertAction){
    
    jumpToDPViews = true
    tabBarController?.selectedIndex = 1
    
  }
  
  //callback for the notification that there are new tasks
  func newTaskWasAssigned(){
    
    if oldTasks.isEmpty {
     needToRefreshDirections = true
    }
    
    if visible{
      myAppDelegate.displayCustomAlert(self, title: "New Tasks", myMessageToShow: "You got new tasks =)", actionHandler: newTaskAlertHandler)
    }
    
  }
  
  //callback for the alert new tasks
  func newTaskAlertHandler(actionAlert: UIAlertAction){
    tabBarController?.selectedIndex = 1
  }
  
  //update location periodically
  func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
    
    myPosition = newLocation.coordinate
    
    if(firstTime == true){
    
      firstTime = false
      let span = MKCoordinateSpanMake(0.035, 0.035)
      let region = MKCoordinateRegion(center: newLocation.coordinate, span: span)
      mapView.setRegion(region, animated: true)
      mapView.showsUserLocation = true
    
      if BPEAPI.api.tasks.count > 0 {
        let request = DirectionsManager.sharedInstance.createRequestInit()
        DirectionsManager.sharedInstance.delegate = self
        DirectionsManager.sharedInstance.calculateDirections(BPEAPI.api.tasks, request: request, indexSeed: 0)
      }
        
    }
    
    if BPEAPI.api.tasks.count > 0 {
      
      let topTask = BPEAPI.api.tasks[0]
      
      if topTask.deliveryId == oldTopTask?.deliveryId && topTask.type == oldTopTask?.type {
        // the top task has not changed
      } else {
        alertShouldAppear = true
        oldTopTask = topTask
        addRadiusCircle(oldTopTask!.position)
      }

      let locationDest : CLLocation = CLLocation(latitude: BPEAPI.api.tasks[0].position.latitude, longitude: BPEAPI.api.tasks[0].position.longitude)
      let distance = newLocation.distanceFromLocation(locationDest)
      if (distance < 10) {
        //send proximity notification
        NSNotificationCenter.defaultCenter().postNotificationName(proximityKey, object: nil)
        //print("YOU ARE CLOSE NOW!")
      }
    }
  }
  
  //Overlay circle around the pin on the top location
  func addRadiusCircle(location: CLLocationCoordinate2D){

      self.mapView.delegate = self
      circle = MKCircle(centerCoordinate: location, radius: 10 as CLLocationDistance)
      self.mapView.addOverlay(circle!)
      print("circle")
    
  }
  
  //Callback for the Calculate directions function
  func calculationDidFinish() {
    
    BPEAPI.api.tasks = DirectionsManager.sharedInstance.tasksManager
    routes = DirectionsManager.sharedInstance.routesCalculated
  
    placeAnnotations(BPEAPI.api.tasks)
    drawRoutes()
    
    //for a in BPEAPI.api.tasks {
    //  print("Before saving: \(BPEAPI.api.formatter.stringFromDate(a.estimatedTime!))")
    //}
    
    BPEAPI.api.saveTasks(tasksSaved)
    
  }
  
  // callback for the savetaks function
  func tasksSaved(tasks: [BPETask]?, error: BPEAPIError?) {
    
    if let errorType = error {
      if errorType == BPEAPIError.AccessDenied {
        
        NSNotificationCenter.defaultCenter().postNotificationName("errorAuthenticateKey", object: nil)
      } else {
        
      }
    } else {
      if let updatedTasks = tasks {
        print("Tasks SAVED! :)")
        for a in BPEAPI.api.tasks {
          print("After saving: \(BPEAPI.api.formatter.stringFromDate(a.estimatedTime!))")
        }
      } else {
        print("Holy fuck! Couldn't save the tasks")
      }
    }
  }
  
  
  override func viewWillAppear(animated: Bool) {
    
    //This can be done with a notification
    self.view.backgroundColor = BPEAPI.api.agent?.status == BPEAgentStatus.Active ? activeColor : noActiveColor
    visible = true
    
    if BPEAPI.api.tasks.count > 0 {
      if tasksDidChanged(oldTasks) {
        if needToRefreshDirections == true {
          //calculate directions with the new order
          needToRefreshDirections = false
          let request = DirectionsManager.sharedInstance.createRequestInit()
          DirectionsManager.sharedInstance.delegate = self
          DirectionsManager.sharedInstance.calculateDirections(BPEAPI.api.tasks, request: request, indexSeed: 0)
        } else {
          placeAnnotations(BPEAPI.api.tasks)
          drawRoutes()
        }
      }
    } else {
      self.mapView.removeAnnotations(self.mapView.annotations)
      let overlays = mapView.overlays
      mapView.removeOverlays(overlays)
    }
  }
  
  
  override func viewWillDisappear(animated: Bool) {
    
    visible = false
    if needToRefreshDirections == false {
      oldTasks = BPEAPI.api.tasks
    }
    self.navigationController?.navigationBar.hidden = false

  }
  
  
  func placeAnnotations(tasks: [BPETask]){
    
    self.mapView.removeAnnotations(self.mapView.annotations)
    print("annotations")
   
    for task in tasks{
      
      let annotation = MKPointAnnotation()
      annotation.coordinate = task.position
      
      if task.type == BPETaskType.Delivery {
        annotation.title = "Delivery #\(task.deliveryId)"
      } else {
        annotation.title = "Pickup #\(task.deliveryId)"
      }
      annotation.subtitle = "\(task.address)"
    
      self.mapView.addAnnotation(annotation)
    }
  }

  
  func drawRoutes(){
    
    if(routes.count > 0){
      let overlays = mapView.overlays
      mapView.removeOverlays(overlays)
      mapView.addOverlay(circle!)
      DirectionsManager.sharedInstance.showRoutesOnMapView(routes, mapView: mapView)
    }
    
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
  }
  
  
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer{
    
    if overlay is MKCircle {
      let circle = MKCircleRenderer(overlay: overlay)
      let color = BPEAPI.api.tasks[0].type == BPETaskType.Delivery ? deliverColor : pickupColor
      circle.strokeColor = color
      circle.fillColor = color
      circle.alpha = 0.4
      circle.lineWidth = 0.1
      return circle
    } else {
      let draw = MKPolylineRenderer(overlay: overlay)
      draw.strokeColor = UIColor(red: CGFloat(88.0/255), green: CGFloat(165.0/255), blue: CGFloat(255.0/255), alpha: 0.8)
      draw.lineWidth = 5.0
      return draw
    }
    
  }
  
  
  func tasksDidChanged(oldTasks: [BPETask])->Bool {
    
    if oldTasks.count == BPEAPI.api.tasks.count {
      var counter = 0
      for task in oldTasks {
        if task.deliveryId == BPEAPI.api.tasks[counter].deliveryId && task.type != BPEAPI.api.tasks[counter].type{
          return true
        } else if task.deliveryId != BPEAPI.api.tasks[counter].deliveryId{
          return true
        }
        counter++
      }
      return false
    } else {
      return true
    }
  }

  @IBAction func centerMap(sender: UIButton) {
    let span = MKCoordinateSpanMake(0.035, 0.035)
    let region = MKCoordinateRegion(center: myPosition, span: span)
    mapView.setRegion(region, animated: true)
    mapView.showsUserLocation = true
  }
  
  func needAuthenticateAgain() {
    if visible {
      myAppDelegate.displayCustomAlert(self, title: "Error", myMessageToShow: "You need to authenticate again", actionHandler: exitApp)
    }
  }
  
  func exitApp(actionAlert: UIAlertAction){
    self.dismissViewControllerAnimated(true, completion: nil)
  }


}
