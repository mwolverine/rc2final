//
//  CompareViewController.swift
//  RC2
//
//  Created by Chad Watts on 9/26/16.
//  Copyright © 2016 Chris Yoo. All rights reserved.
//

import UIKit
import Charts

class CompareViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var personalName: UILabel!
    @IBOutlet weak var personalMiles: UILabel!
    @IBOutlet weak var personalSteps: UILabel!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendMiles: UILabel!
    @IBOutlet weak var friendSteps: UILabel!
    @IBOutlet weak var segmentedView: UISegmentedControl!
    @IBOutlet weak var lineChart: LineChartView!
    
    var dataEntries: [ChartDataEntry] = []
    var user: User?
    var friend: Friend?
    
    var miles: [Double] {
        var miles: [Double] = []
        let milesArray = FacebookController.sharedController.sessions.flatMap({$0.miles})
        for mile in milesArray {
            miles.append(Double(mile)!)
        }
        let last7 = Array(miles.suffix(7))
        return last7
    }
    
    var dates: [String] {
        var finalDates: [String] = []
        let dates = FacebookController.sharedController.sessions.flatMap({$0.formattedDate})
        for date in dates {
            let newDate = String(date.characters.suffix(5))
            finalDates.append(newDate)
        }
        let last7 = Array(finalDates.suffix(7))
        return last7
    }
    
//    var compMiles: [Double] {
//        var miles: [Double]
//        
//    }
//    
//    var compDates: [String] {
//     
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        callPullUserData()
        setChart(dates, values: miles)
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        for i in 0..<dataPoints.count {
            
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Miles")
            let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
            dataEntries.append(dataEntry)
            lineChart.data = lineChartData
        }
    }
    
    func callPullUserData() {
        
        user = FacebookController.sharedController.userData
        friend = FacebookController.sharedController.friendlyData
        print(user?.userEmail)
        print(user?.userEmail)
        
        if let user = user {
            
            personalName.text = "\(user.userFirstName)"
            personalMiles.text = "Miles: \(user.userMiles)"
            personalSteps.text = "Steps: \(user.userSteps)"
            
            if let friend = friend {
                
            friendName.text = "\(friend.friendFirstName)"
            friendMiles.text = "Miles: \(friend.friendMiles)"
            friendSteps.text = "Steps: \(friend.friendSteps)"
                
            }
        }
    }
}

