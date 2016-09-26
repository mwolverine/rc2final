//
//  Session.swift
//  RC2
//
//  Created by Ryan Plitt on 9/26/16.
//  Copyright © 2016 Chris Yoo. All rights reserved.
//

import Foundation

class Session {
    
    let date: Double
    let miles: String
    let steps: String
    
    init(date: Double, miles: String, steps: String){
        self.date = date
        self.miles = miles
        self.steps = steps
    }
}