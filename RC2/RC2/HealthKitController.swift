//
//  HealthKitController.swift
//  RC2
//
//  Created by Ryan Plitt on 9/21/16.
//  Copyright © 2016 Chris Yoo. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitController {
    
    let healthKitStore = HKHealthStore()
    
    static let sharedController = HealthKitController()
    
    // Authorize Needs to be called before the app is loaded. Maybe View did load or app delegate
    func authorizeHealthKit(completion: ((success: Bool, error: NSError!) -> Void)?) {
        
        let healthDataToRead = Set(arrayLiteral: HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!)
        
        if !HKHealthStore.isHealthDataAvailable() {
            print("Can't access HealthKit.")
        }
        
        healthKitStore.requestAuthorizationToShareTypes(nil, readTypes: healthDataToRead) { (success, error) in
            if error != nil {
                print(error?.localizedDescription)
                print("There was an error requesting Authorization to use Health App")
            }
            if success {
                self.enableBackgroundDelivery()
            }
            completion?(success: success, error: error)
        }
    }
    
    
    func setupQuery() {
        
        guard let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning) else {
            return
        }
        
        let query = HKObserverQuery(sampleType: sampleType, predicate: nil, updateHandler: self.backgroundQueryHandler)
    }
    
    func enableBackgroundDelivery(){
        
        healthKitStore.enableBackgroundDeliveryForType(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!, frequency: .Hourly) { (success, error) in
            if error != nil {
                print(error!.localizedDescription)
                print("There was an error enabling Background Delivery from Health App")
            } else {
                print("The background fetches have been setup")
                self.setupQuery()
            }
        }
        
    }
    
    
    func backgroundQueryHandler(query: HKObserverQuery, completionHandler: HKObserverQueryCompletionHandler, error: NSError?) {
        
        guard error == nil else {
            print("There was an error handing the background Query from Health App")
            print(error?.localizedDescription)
            return
        }
        
        guard let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning) else {
            return
        }
        
        let sessionQuery = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: nil, options: .CumulativeSum, completionHandler: self.backgroundResultsHandler)
        
        
        self.healthKitStore.executeQuery(sessionQuery)
        
        
        completionHandler()
        
    }
    
    
    
    func backgroundResultsHandler(query: HKStatisticsQuery, results: HKStatistics?, error: NSError?) {
        
        let calendar = NSCalendar.currentCalendar()
        var totalMiles = 0.0
        
        if let value = results?.sumQuantity() {
            let unit = HKUnit.mileUnit()
            totalMiles = value.doubleValueForUnit(unit)
        }
        
        if let startDate = results?.startDate {
            let components = calendar.components([.Year,.Month, .Day, .Hour, .Minute], fromDate:startDate)
            let hours = components.hour
            let day = components.day
            let month = components.month
            let year = components.year
            
            self.sendResultsToFirebase(totalMiles, year: year, month: month, day: day, hour: hours)
        }
        
        
    }
    
    
    func sendResultsToFirebase(miles: Double, year: Int, month: Int, day: Int, hour: Int) {
        
    }
    
}
