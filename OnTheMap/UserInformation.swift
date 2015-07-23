//
//  UserInformation.swift
//  OnTheMap
//
//  Created by Sergey Krivov on 23.07.15.
//  Copyright (c) 2015 Sergey Krivov. All rights reserved.
//

import Foundation

struct UserInformation {
    var firstName = ""
    var lastName = ""
    
    /* Construct a PublicUserInformation from a dictionary */
    init(dictionary: NSDictionary) {
        firstName = dictionary["first_name"] as! String
        lastName = dictionary["last_name"] as! String
    }
}