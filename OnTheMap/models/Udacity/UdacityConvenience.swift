//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Sergey Krivov on 20.07.15.
//  Copyright (c) 2015 Sergey Krivov. All rights reserved.
//

import UIKit
import Foundation
import MapKit

// MARK: - Convenient Resource Methods

extension UdacityClient {
    
    // MARK: - POST Convenience Methods
    
    func userLogin(email: String, password: String, completionHandler: (result: String?, error: NSError?) -> Void) {
        
        // method
        var method = Methods.CreateSession
        
        let parameters : [String:String] = [
            UdacityClient.JSONBodyKeys.Username: email,
            UdacityClient.JSONBodyKeys.Password: password
        ]
        
        let jsonBody : [String:AnyObject] = [
            UdacityClient.JSONBodyKeys.Udacity: parameters
        ]
        
        // make the request
        let task = taskForPOSTMethod(UdacityClient.RequestToServer.udacity, method: Methods.CreateSession, parameters: parameters, jsonBody: jsonBody, subdata: 5) { (result, error) -> Void in
            if error != nil {
                completionHandler(result: nil, error: error)
            }
            else {
                if let errorMsg = result.valueForKey(UdacityClient.JSONResponseKeys.Error)  as? String {
                    completionHandler(result: nil, error: NSError(domain: "udacity login issue", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMsg]))
                }
                else {
                    let session = result["account"] as! NSDictionary
                    let key = session["key"] as! String
                    completionHandler(result: key, error: nil)
                }
            }
        }
    }
    
    // download student locations
    func getStudentLocations(completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) {
        
        // make the request
        let task = taskForGETMethod(UdacityClient.RequestToServer.parse, method: Methods.limit, parameters: ["limit":200]) { (result, error) -> Void in
            if error != nil {
                completionHandler(result: nil, error: error)
            }
            else {
                if let locations = result as? [NSObject: NSObject] {
                    if let usersResult = locations["results"] as? [[String : AnyObject]] {
                        var studentsData = StudentInformation.convertFromDictionaries(usersResult)
                        completionHandler(result: studentsData, error: nil)
                    }
                }
            }
        }
    }
    
    // set annotations for map with users data
    func createAnnotations(users: [StudentInformation], mapView: MKMapView) {
        for user in users {
            // set pin location
            var annotation = MKPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2DMake(user.latitude, user.longitude)
            annotation.title = "\(user.firstName) \(user.lastName)"
            annotation.subtitle = user.mediaURL
            
            mapView.addAnnotation(annotation)
        }
    }
}
