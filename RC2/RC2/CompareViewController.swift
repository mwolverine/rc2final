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
        print(friendUID)
        callPullUserData()
        callFriendData()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setChart(dates, miles1: miles, dates2: compDates, miles2: compMiles)
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
        
        self.setChart(dates, miles1: miles, dates2: compDates, miles2: compMiles)
    }

    
    func setChart(dates1: [String], miles1: [Double], dates2: [String], miles2: [Double]) {
        
        self.dataEntries = []
        
        for i in 0..<dates1.count {
            
            
            let dataEntry1 = ChartDataEntry(value: miles1[i], xIndex: i)
            let dataEntry2 = ChartDataEntry(value: miles2[i], xIndex: i)
            dataEntries.append(dataEntry1)
            dataEntries.append(dataEntry2)
            let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Miles")
            let lineChartData = LineChartData(xVals: dates1, dataSet: lineChartDataSet)
            lineChart.data = lineChartData
            lineChart.rightAxis.enabled = false
            lineChart.xAxis.drawGridLinesEnabled = false
            lineChart.rightAxis.drawGridLinesEnabled = false
            lineChart.xAxis.labelPosition = .Bottom
            lineChart.legend.enabled = false
            lineChartData.highlightEnabled = false
            lineChartDataSet.circleRadius = 4.0
            lineChartDataSet.circleColors = [UIColor(red: 247/255, green: 67/255, blue: 76/255, alpha: 1)]
            lineChartDataSet.setColor(UIColor(red: 247/255, green: 67/255, blue: 76/255, alpha: 1))
            lineChartDataSet.valueTextColor = .whiteColor()
            lineChart.leftAxis.axisMinValue = 0
            lineChart.xAxis.labelTextColor = .whiteColor()
            lineChart.leftAxis.labelTextColor = .whiteColor()
            lineChart.infoTextColor = UIColor.whiteColor()
            lineChart.leftAxis.gridColor = .yellowColor()
            lineChart.leftAxis.axisLineColor = .whiteColor()
            
            lineChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.5)
            lineChart.notifyDataSetChanged()
            lineChart.descriptionText = ""
            if segmentedView.selectedSegmentIndex == 0 {
                lineChart.xAxis.setLabelsToSkip(0)
            } else {
                lineChart.xAxis.resetLabelsToSkip()
                lineChartDataSet.valueTextColor = .clearColor()
            }
            
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

