//
//  FriendList.swift
//  RC2
//
//  Created by Chris Yoo on 9/20/16.
//  Copyright © 2016 Chris Yoo. All rights reserved.
//

import Foundation

class Friend {
    
    let friendUID: String
    let friendFirstName: String
    let friendLastName: String
    let friendMiles: String
    let friendSteps: String
    
    init(friendUID: String, friendFirstName: String, friendLastName: String, friendMiles: String, friendSteps: String){
        self.friendUID = friendUID
        self.friendFirstName = friendFirstName
        self.friendLastName = friendLastName
        self.friendMiles = friendMiles
        self.friendSteps = friendSteps
    }
}