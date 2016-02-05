//
//  DrawView.swift
//  BikePonyExpress iOS
//
//  Created by Raul Rondon on 9/14/15.
//  Copyright © 2015 BikePonyExpress. All rights reserved.
//

import UIKit


class DrawView : UIView{
  
  static let drawViewManager = DrawView()
  
  var lines: [Line] = []
  var lastPoint: CGPoint!
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
    if let touch = touches.first as UITouch! {
      lastPoint = touch.locationInView(self)
    }
    
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
    var newPoint: CGPoint!
    
    if let touch = touches.first as UITouch! {
      newPoint = touch.locationInView(self)
    }
    
    let newline = Line(start: lastPoint, end: newPoint)
    lines.append(newline)
    lastPoint = newPoint
    
    self.setNeedsDisplay()
    
  }
  
  override func drawRect(rect: CGRect) {
    
    let context = UIGraphicsGetCurrentContext()
    CGContextBeginPath(context)
    
    for line in lines{
      CGContextMoveToPoint(context, line.start.x, line.start.y)
      CGContextAddLineToPoint(context, line.end.x, line.end.y)
    }
    
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1)
    CGContextSetLineWidth(context, 2)
    CGContextSetLineCap(context, CGLineCap.Round)
    CGContextStrokePath(context)
    
  }
  
  func getUIImageFromUIView(myUIView: UIView) ->UIImage{
    
    UIGraphicsBeginImageContextWithOptions(myUIView.frame.size, true, 0)
    let context:CGContextRef = UIGraphicsGetCurrentContext()!
    CGContextTranslateCTM(context, 0, 0)
    myUIView.layer.renderInContext(context)
    let renderedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return renderedImage
    
  }
  
  func UIImageToPNG(myUIImage: UIImage)->String{
    
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    let filePathToWrite = "\(paths)/SaveFile.png"
    let fileManager = NSFileManager.defaultManager()
    let imageData: NSData = UIImagePNGRepresentation(myUIImage)!
    fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
    
    return filePathToWrite
    
  }
  
  func getImageFromPath(path: String)-> UIImage{
    
    let fileManager = NSFileManager.defaultManager()
    
    if(fileManager.fileExistsAtPath(path)){
      return UIImage(contentsOfFile: path)!
    }else{
      return UIImage()
    }
    
  }
  
}
