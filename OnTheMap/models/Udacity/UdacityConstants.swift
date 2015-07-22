//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Sergey Krivov on 20.07.15.
//  Copyright (c) 2015 Sergey Krivov. All rights reserved.
//


extension UdacityClient {
    
    // MARK: - Constants
    struct Constants {
        // Parse app id and api key
        static let parseAppId: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let parseApiKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        static let UdacityBaseURL: String = "https://www.udacity.com/api/"
        static let ParseBaseURL: String = "https://api.parse.com/1/classes/StudentLocation"
    }
    
    // MARK: - Request to server
    struct RequestToServer {
        static let udacity : String = "udacity"
        static let parse : String = "parse"
    }
    
    // MARK: - Methods
    struct Methods {
        // get udacity session
        static let CreateSession : String = "session"
        // get public users data
        static let Users : String = "users/"
        // parse limit
        static let limit : String = ""
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        // udacity
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        static let Error = "error"
        static let Status = "status"
        
        // MARK: Student information
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MediaUrl = "mediaURL"
        
    }

}