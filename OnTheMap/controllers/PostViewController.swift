//
//  PostViewController.swift
//  OnTheMap
//
//  Created by Sergey Krivov on 20.07.15.
//  Copyright (c) 2015 Sergey Krivov. All rights reserved.
//

import UIKit
import MapKit

class PostViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var linkField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var mainText: UILabel!
    
    var latitude : CLLocationDegrees = CLLocationDegrees()
    var longitude : CLLocationDegrees = CLLocationDegrees()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        changeVisibility(true)
        
        // add cancel button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel")
        
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func findOnMapAction(sender: UIButton) {
        if (!locationField.text.isEmpty) {
            getGeocodLocation(locationField.text)
        }
        else {
            locationField.becomeFirstResponder()
        }
        
    }
    
    // find user location via geocoder
    func getGeocodLocation(address : String) {
        showActivityIndicator()
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                self.hideActivityIndicator()
                UdacityClient.sharedInstance().showAlert(error!, viewController: self)
            }
            else {
                self.map.hidden = false
                self.submitButton.hidden = false
                self.linkField.hidden = false
                
                if let placemark = placemarks?[0] as? CLPlacemark {
                    self.latitude = placemark.location.coordinate.latitude
                    self.longitude = placemark.location.coordinate.longitude
                    self.placeMarkerOnMap(placemark)
                }
                self.hideActivityIndicator()
                self.changeVisibility(false)
            }
            
        })
    }
    
    // Set marker on map and zoom in
    func placeMarkerOnMap(placemark: CLPlacemark) {
        // set zoom
        var latDelta : CLLocationDegrees = 0.01
        var longDelta : CLLocationDegrees = 0.01
        
        // make span
        var span : MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        // create location
        var location : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        // create region
        var region : MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        map.setRegion(region, animated: true)
        
        map.addAnnotation(MKPlacemark(placemark: placemark))
    }
    
    // MARK: - Activity indicator
    func showActivityIndicator() {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
    }
    
    @IBAction func submitAction(sender: UIButton) {
        // get public data udacity
        if (!linkField.text.isEmpty) {
            
            if (self.isValidURL(linkField.text)) {
                // user data
                showActivityIndicator()
                sendUserLocation()
            }
            else {
                let error = NSError(domain: "Invalid URL", code: 0, userInfo: ["NSLocalizedDescriptionKey" : "Invalid URL"])
                UdacityClient.sharedInstance().showAlert(error, viewController: self)
            }
        }
        else {
            linkField.becomeFirstResponder()
        }
    }
    
    func changeVisibility(firstStep: Bool) {
        findButton.hidden = !firstStep
        submitButton.hidden = firstStep
        locationField.hidden = !firstStep
        linkField.hidden = firstStep
        map.hidden = firstStep
        
        if (firstStep) {
            mainText.text = "Where are you studying today?"
        } else {
            mainText.text = "Enter associated link"
        }
    }
    
    // go back to map view
    func cancel() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // validate url
    func isValidURL(urlString: String) -> Bool {
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        return NSURLConnection.canHandleRequest(request)
    }
    
    // get user data from udacity and post user location to parse
    func sendUserLocation() {
        
        var userData : [String: AnyObject] = [String: AnyObject]()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        UdacityClient.sharedInstance().getUserPublicData(appDelegate.studentKey, completionHandler: { userInformation, error in
            if userInformation != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    userData  = [
                        UdacityClient.JSONBodyKeys.UniqueKey: appDelegate.studentKey,
                        UdacityClient.JSONBodyKeys.FirstName: userInformation!.firstName,
                        UdacityClient.JSONBodyKeys.LastName: userInformation!.lastName,
                        UdacityClient.JSONBodyKeys.MapString: self.locationField.text,
                        UdacityClient.JSONBodyKeys.MediaURL: self.linkField.text,
                        UdacityClient.JSONBodyKeys.Latitude: self.latitude,
                        UdacityClient.JSONBodyKeys.Longitude: self.longitude
                    ]
                    
                    //send request to parse
                    UdacityClient.sharedInstance().sendUserLocation(userData, completionHandler: { (result, error) -> Void in
                        if error != nil {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.hideActivityIndicator()
                                UdacityClient.sharedInstance().showAlert(error!, viewController: self)
                            })
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.hideActivityIndicator()
                                self.cancel()
                            })
                        }
                    })
                })
            } else {
                if error != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        UdacityClient.sharedInstance().showAlert(error!, viewController: self)
                    })
                }
            }
        })
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
