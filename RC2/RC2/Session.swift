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
    let formattedDate: String
    let miles: String
    let steps: String
    
    init(date: Double, formattedDate: String, miles: String, steps: String){
        self.date = date
        self.formattedDate = formattedDate
        self.miles = miles
        self.steps = steps
    }
}