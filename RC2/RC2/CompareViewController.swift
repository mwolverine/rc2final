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
    
    var friend: Friend?
    var dataEntries: [ChartDataEntry] = []
    var user: User?
    
    @IBOutlet weak var personalName: UILabel!
    @IBOutlet weak var personalMiles: UILabel!
    @IBOutlet weak var personalSteps: UILabel!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendMiles: UILabel!
    @IBOutlet weak var friendSteps: UILabel!
    @IBOutlet weak var segmentedView: UISegmentedControl!
    @IBOutlet weak var lineChart: LineChartView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let friendUID = friend?.friendUID
        FacebookController.sharedController.queryFriendMiles(friendUID!)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        callPullUserData()
        callFriendData()
        setChart(dates, values: miles)
        setChart(compDates, values: compMiles)
        
        
    }
    
    func returnNumberForSegmentController(int: Int) -> Int {
        switch int {
        case 0:
            return 7
        case 1:
            return 30
        case 2:
            return 90
        default: return 0
        }
    }
    
    var miles: [Double] {
        var miles: [Double] = []
        let milesArray = FacebookController.sharedController.sessions.flatMap({$0.miles})
        for mile in milesArray {
            miles.append(Double(mile)!)
        }
        let last7 = Array(miles.suffix(returnNumberForSegmentController(segmentedView.selectedSegmentIndex)))
        return last7
    }
    
    var dates: [String] {
        var finalDates: [String] = []
        let dates = FacebookController.sharedController.sessions.flatMap({$0.formattedDate})
        for date in dates {
            let newDate = String(date.characters.suffix(5))
            finalDates.append(newDate)
        }
        let last7 = Array(dates.suffix(returnNumberForSegmentController(segmentedView.selectedSegmentIndex)))
        return last7
    }
    
    var compMiles: [Double] {
        var miles: [Double] = []
        let milesArray = FacebookController.sharedController.friendSessions.flatMap({$0.miles})
        
        for mile in milesArray {
            miles.append(Double(mile)!)
        }
        
        let last7 = Array(miles.suffix(returnNumberForSegmentController(segmentedView.selectedSegmentIndex)))
        return last7
    }
    
    var compDates: [String] {
     
        var dates: [String] = []
        let datesArray = FacebookController.sharedController.friendSessions.flatMap({$0.formattedDate})
        
        for date in datesArray {
            let newDate = String(date.characters.suffix(5))
            dates.append(newDate)
        }
        
        let last7 = Array(dates.suffix(returnNumberForSegmentController(segmentedView.selectedSegmentIndex)))
        return last7
    }
    
  
    @IBAction func segmentValueChanged(sender: AnyObject) {
        
        self.setChart(dates, values: miles)
        self.setChart(compDates, values: compMiles)
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
 
        if let user = user {
            
            personalName.text = "\(user.userFirstName)"
            personalMiles.text = "Miles: \(user.userMiles)"
            personalSteps.text = "Steps: \(user.userSteps)"
        }
    }
    
    func callFriendData() {
        
        if let friend = friend {
            
            friendName.text = "\(friend.friendFirstName)"
            friendMiles.text = "Miles: \(friend.friendMiles)"
            friendSteps.text = "Steps: \(friend.friendSteps)"
            
        }
    }
}

