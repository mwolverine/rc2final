//
//  User.swift
//  RC2
//
//  Created by Chris Yoo on 9/20/16.
//  Copyright © 2016 Chris Yoo. All rights reserved.
//

import Foundation

class User {
    
    let userFirstName: String
    let userLastName: String
    let userEmail: String
    //let userGender: String
    let userFID: String
    let userUID: String
    let userPhotoURL: String
    let userMiles: String
    let userSteps: String
    
    init(userFirstName: String, userLastName: String, userFID: String, userUID: String, userEmail: String, userPhotoURL: String, userMiles: String, userSteps: String){
        self.userFirstName = userFirstName
        self.userLastName = userLastName
        self.userEmail = userEmail
        //self.userGender = userGender
        self.userFID = userFID
        self.userUID = userUID
        self.userPhotoURL = userPhotoURL
        self.userMiles = userMiles
        self.userSteps = userSteps
    }
}