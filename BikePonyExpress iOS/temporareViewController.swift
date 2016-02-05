//
//  temporareViewController.swift
//  BikePonyExpress iOS
//
//  Created by Raul Rondon on 9/15/15.
//  Copyright © 2015 BikePonyExpress. All rights reserved.
//

import UIKit

class temporareViewController: UIViewController {

  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  let container: UIView = UIView()
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      self.view.backgroundColor = grayBackGroundColor
      
      //Activity Indicator
      activityIndicator.hidden = true
      container.frame = self.view.frame
      container.center = self.view.center
      container.backgroundColor = UIColor.clearColor()//UIColor(red: CGFloat(255.0/255), green: CGFloat(255.0/255), blue: CGFloat(255.0/255), alpha: 0.9)
      self.view.addSubview(container)
      self.view.sendSubviewToBack(container)
      container.addSubview(activityIndicator)


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
