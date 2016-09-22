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
    
    var lastDateSynced: NSDate = NSDate(timeInterval: -2000000, sinceDate: NSDate())
    
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
    
    
    func setupObserverQuery() {
        
        guard let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning) else {
            return
        }
        
        let query = HKObserverQuery(sampleType: sampleType, predicate: nil, updateHandler: self.backgroundQueryHandler)
        
        healthKitStore.executeQuery(query)
    }
    
    func setupCollectionStatisticQuery(){
        
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
                
                let formatter = NSLengthFormatter()
                formatter.forPersonHeightUse = true
                formatter.unitStyle = .Medium
                
                
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValueForUnit(mileUnit)
                    let components = calendar.components([.Year,.Month, .Day, .Hour, .Minute], fromDate:date)
                    
                    self.sendResultsToFirebase(value, date: date)
                }
                
            }
        }
        
        healthKitStore.executeQuery(query)
        
    }
    
    
    func enableBackgroundDelivery(){
        
        healthKitStore.enableBackgroundDeliveryForType(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!, frequency: .Hourly) { (success, error) in
            if error != nil {
                print(error!.localizedDescription)
                print("There was an error enabling Background Delivery from Health App")
            } else {
                print("The background fetches have been setup")
                self.setupObserverQuery()
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
            let day = components.day
            let month = components.month
            let year = components.year
            
//            self.sendResultsToFirebase(totalMiles, year: year, month: month, day: day)
        }
        
        
    }
    
    
    func sendResultsToFirebase(miles: Double, date: NSDate) {
        print(date)
        print(miles)
        
        let dateFormatter: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            formatter.timeStyle = .
            formatter.doesRelativeDateFormatting = true
            return formatter
        }()
    }
    
}
