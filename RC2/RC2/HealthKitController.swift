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
    
    var lastDateSynced: NSDate = NSDate(timeInterval: -2592000, sinceDate: NSDate())
    var lastLoggedTime: NSTimeInterval?
    
    
    // Authorize Needs to be called after the facebook login but before the main view
    /////////////////////////////////////////////////////////////////////////////////
    
    func authorizeHealthKit(completion: ((success: Bool, error: NSError!) -> Void)?) {
        
        let healthDataToRead = Set(arrayLiteral: HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!, HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!)
        
        if !HKHealthStore.isHealthDataAvailable() {
            print("Can't access HealthKit.")
        }
        
        healthKitStore.requestAuthorizationToShareTypes(nil, readTypes: healthDataToRead) { (success, error) in
            if error != nil {
                print(error?.localizedDescription)
                print("There was an error requesting Authorization to use Health App")
            }
            if success {
                //                self.enableBackgroundDelivery()
                print("Successfully authorized Healthkit")
            }
            completion?(success: success, error: error)
        }
    }
    
    
    // Setup Queries need to be in the app Delegate//
    /////////////////////////////////////////////////
    
    //    func setupMilesObserverQuery() {
    //        
    //        guard let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning) else {
    //            return
    //        }
    //        
    //        let query = HKObserverQuery(sampleType: sampleType, predicate: nil, updateHandler: self.backgroundMilesQueryHandler)
    //        
    //        healthKitStore.executeQuery(query)
    //    }
    //    
    //    func setupStepsObserverQuery() {
    //        
    //        guard let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount) else {
    //            return
    //        }
    //        
    //        let query = HKObserverQuery(sampleType: sampleType, predicate: nil, updateHandler: self.backgroundStepsQueryHandler)
    //        
    //        healthKitStore.executeQuery(query)
    //    }
    
    func setupMilesCollectionStatisticQuery(){
        
        let calendar = NSCalendar.currentCalendar()
        
        let interval = NSDateComponents()
        interval.day = 1
        
        let today = NSDate()
        let anchorComponents = calendar.components([.Day, .Month, .Year], fromDate: today)
        
        guard let anchorDate = calendar.dateFromComponents(anchorComponents) else {
            return
        }
        
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning) else {
            return
        }
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: nil, options: .CumulativeSum, anchorDate: anchorDate, intervalComponents: interval)
        
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                return
            }
            
            let endDate = NSDate()
            
            let startDate = self.lastDateSynced
            
            statsCollection.enumerateStatisticsFromDate(startDate, toDate: endDate) { [unowned self] statistics, stop in
                
                let mileUnit = HKUnit.mileUnit()
                let date = statistics.startDate
                
                guard let quantity = statistics.sumQuantity() else {
                    FacebookController.sharedController.createSessionMiles("0.0", date: date)
                    return
                }
                
                let value = quantity.doubleValueForUnit(mileUnit)
                
                FacebookController.sharedController.createSessionMiles(String(format: "%.2f",value), date: date)
            }
        }
        
        healthKitStore.executeQuery(query)
        
    }
    
    func setupStepsCollectionStatisticQuery(){
        
        let calendar = NSCalendar.currentCalendar()
        
        let interval = NSDateComponents()
        interval.day = 1
        
        let today = NSDate()
        let anchorComponents = calendar.components([.Day, .Month, .Year], fromDate: today)
        
        guard let anchorDate = calendar.dateFromComponents(anchorComponents) else {
            return
        }
        
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount) else {
            return
        }
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: nil, options: .CumulativeSum, anchorDate: anchorDate, intervalComponents: interval)
        
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                fatalError("*** An error occurred while calculating the statistics: \(error?.localizedDescription) ***")
            }
            
            let endDate = NSDate()
            
            let startDate = self.lastDateSynced
            
            statsCollection.enumerateStatisticsFromDate(startDate, toDate: endDate) { [unowned self] statistics, stop in
                
                let stepUnit = HKUnit.countUnit()
                let date = statistics.startDate
                
                
                guard let quantity = statistics.sumQuantity() else {
                    FacebookController.sharedController.createSessionSteps("0", date: date)
                    return
                }
                
                let value = quantity.doubleValueForUnit(stepUnit)
                FacebookController.sharedController.createSessionSteps(String(Int(value)), date: date)
            }
        }
        
        healthKitStore.executeQuery(query)
        
    }
    
    //    func enableBackgroundDelivery(){
    //        
    //        let arrayOfType = [HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!, HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!]
    //        
    //        for type in arrayOfType {
    //            healthKitStore.enableBackgroundDeliveryForType(type, frequency: .Hourly) { (success, error) in
    //                if error != nil {
    //                    print(error!.localizedDescription)
    //                    print("There was an error enabling Background Delivery from Health App")
    //                } else {
    //                    print("The background fetches have been setup")
    //                    self.setupMilesObserverQuery()
    //                    self.setupStepsObserverQuery()
    //                }
    //            }
    //        }
    //    }
    
    
    func backgroundMilesQueryHandler(query: HKObserverQuery, completionHandler: HKObserverQueryCompletionHandler, error: NSError?) {
        
        guard error == nil else {
            print("There was an error handing the background Query from Health App")
            print(error?.localizedDescription)
            return
        }
        
        guard let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning) else {
            return
        }
        
        let sessionQuery = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: nil, options: .CumulativeSum, completionHandler: self.backgroundMilesResultsHandler)
        
        
        self.healthKitStore.executeQuery(sessionQuery)
        
        completionHandler()
        
    }
    
    
    func backgroundStepsQueryHandler(query: HKObserverQuery, completionHandler: HKObserverQueryCompletionHandler, error: NSError?) {
        
        guard error == nil else {
            print("There was an error handing the background Query from Health App")
            print(error?.localizedDescription)
            return
        }
        
        guard let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning) else {
            return
        }
        
        let sessionQuery = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: nil, options: .CumulativeSum, completionHandler: self.backgroundStepsResultsHandler)
        
        
        self.healthKitStore.executeQuery(sessionQuery)
        
        
        completionHandler()
        
    }
    
    
    func backgroundMilesResultsHandler(query: HKStatisticsQuery, results: HKStatistics?, error: NSError?) {
        
        var totalMiles = 0.0
        
        if let value = results?.sumQuantity() {
            let unit = HKUnit.mileUnit()
            totalMiles = value.doubleValueForUnit(unit)
        }
        
        guard let startDate = results?.startDate else {return}
        
        FacebookController.sharedController.createSessionMiles(String(format: "%.2f",totalMiles), date: startDate)
        
    }
    
    
    func backgroundStepsResultsHandler(query: HKStatisticsQuery, results: HKStatistics?, error: NSError?) {
        
        var totalSteps = 0.0
        
        if let value = results?.sumQuantity() {
            let unit = HKUnit.countUnit()
            totalSteps = value.doubleValueForUnit(unit)
        }
        
        guard let startDate = results?.startDate else {return}
        
        FacebookController.sharedController.createSessionSteps(String(Int(totalSteps)), date: startDate)
        
        
    }
    
    func setLastDaysToZero(){
        var timeIntervalSinceLastLogin = self.lastDateSynced.timeIntervalSinceNow
        var lastLoggedDate = NSCalendar.currentCalendar().startOfDayForDate(self.lastDateSynced)
        var rotatingDate = lastLoggedDate
        repeat {
            timeIntervalSinceLastLogin -= 86400.00
            let date = rotatingDate.dateByAddingTimeInterval(-86400.00)
            FacebookController.sharedController.createSessionSteps("0.0", date: date)
            FacebookController.sharedController.createSessionMiles("0.0", date: date)
            lastLoggedDate = lastLoggedDate.dateByAddingTimeInterval(-86400.00)
        } while timeIntervalSinceLastLogin > 86400
    }
    
    
}
