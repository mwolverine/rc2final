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
    var dataEntries1: [ChartDataEntry] = []
    var dataEntries2: [ChartDataEntry] = []
    var user: User?
    
    @IBOutlet weak var personalName: UILabel!
    @IBOutlet weak var personalMiles: UILabel!
    @IBOutlet weak var personalSteps: UILabel!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendMiles: UILabel!
    @IBOutlet weak var friendSteps: UILabel!
    @IBOutlet weak var segmentedView: UISegmentedControl!
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var pieChart: PieChartView!
   
    @IBOutlet weak var scrollView: UIScrollView!
    
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
        setPieChart(miles, oppMiles: compMiles)
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
        var dates: [String] = []
        let datesArray = FacebookController.sharedController.sessions.flatMap({$0.formattedDate})
        
        for date in datesArray {
            let newDate = String(date.characters.suffix(5))
            dates.append(newDate)
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
        
        //scroll view + segmented control
        switch sender.selectedSegmentIndex {
        case 0:
            scrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
        case 1:
            scrollView.setContentOffset(CGPoint(x: 375, y: 0), animated: true)
        default:
            print(1234)
        }
        
        
    }

    
    func setChart(dates1: [String], miles1: [Double], dates2: [String], miles2: [Double]) {
        
        self.dataEntries1 = []
        self.dataEntries2 = []
        
        for i in 0..<dates1.count {
            
            
            let dataEntry1 = ChartDataEntry(value: miles1[i], xIndex: i)
            let dataEntry2 = ChartDataEntry(value: miles2[i], xIndex: i)
            dataEntries1.append(dataEntry1)
            dataEntries2.append(dataEntry2)
            let lineChartDataSet1 = LineChartDataSet(yVals: dataEntries1, label: "Miles")
            let lineChartDataSet2 = LineChartDataSet(yVals: dataEntries2, label: "Miles")
            let lineChartData = LineChartData(xVals: dates1, dataSets: [lineChartDataSet2,lineChartDataSet1])
            lineChart.data = lineChartData
            lineChart.rightAxis.enabled = false
            lineChart.xAxis.drawGridLinesEnabled = false
            lineChart.rightAxis.drawGridLinesEnabled = false
            lineChart.xAxis.labelPosition = .Bottom
            lineChart.legend.enabled = false
            lineChartData.highlightEnabled = false
            lineChart.leftAxis.axisMinValue = 0
            lineChart.xAxis.labelTextColor = .whiteColor()
            lineChart.leftAxis.labelTextColor = .whiteColor()
            lineChart.infoTextColor = UIColor.whiteColor()
            lineChart.leftAxis.gridColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
            lineChart.leftAxis.axisLineColor = .whiteColor()
            
            lineChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.5)
            lineChart.notifyDataSetChanged()
            lineChart.descriptionText = ""
            
            lineChartDataSet1.circleRadius = 4.0
            lineChartDataSet1.circleColors = [UIColor(red: 247/255, green: 67/255, blue: 76/255, alpha: 1)]
            lineChartDataSet1.setColor(UIColor(red: 247/255, green: 67/255, blue: 76/255, alpha: 1))
            lineChartDataSet1.valueTextColor = .whiteColor()
            
//            lineChartDataSet1.fillColor = UIColor(red: 247/255, green: 67/255, blue: 76/255, alpha: 1)
            lineChartDataSet1.mode = .CubicBezier
            lineChartDataSet1.cubicIntensity = 0.2
            lineChartDataSet1.lineWidth = 2.0
            
            let gradientColors1 = [UIColor(red: 247/255, green: 67/255, blue: 76/255, alpha: 1).CGColor, UIColor.clearColor().CGColor]
            let colorLocations:[CGFloat] = [0.9, 0.1]
            let gradient1 = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), gradientColors1, colorLocations)
            let gradientColors2 = [UIColor(red: 1, green: 1, blue: 0, alpha: 1).CGColor, UIColor.clearColor().CGColor]
            let gradient2 = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), gradientColors2, colorLocations)
            lineChartDataSet1.drawFilledEnabled = true
            
            lineChartDataSet1.fillAlpha = 0.6
            lineChartDataSet1.fill = ChartFill.fillWithLinearGradient(gradient1!, angle: 90.0)
            
            lineChartDataSet2.circleRadius = 4.0
            lineChartDataSet2.circleColors = [.yellowColor()]
            lineChartDataSet2.setColor(.yellowColor())
            lineChartDataSet2.valueTextColor = .whiteColor()
            lineChartDataSet2.drawFilledEnabled = true
//            lineChartDataSet2.fillColor = .yellowColor()
            lineChartDataSet2.mode = .CubicBezier
            lineChartDataSet2.cubicIntensity = 0.2
            lineChartDataSet2.lineWidth = 2.0
            
            lineChartDataSet2.drawFilledEnabled = true
            lineChartDataSet2.fillAlpha = 0.6
            lineChartDataSet2.fill = ChartFill.fillWithLinearGradient(gradient2!, angle: 90.0)
            
            if segmentedView.selectedSegmentIndex == 0 {
                lineChart.xAxis.setLabelsToSkip(0)
            } else {
                lineChart.xAxis.resetLabelsToSkip()
                lineChartDataSet1.valueTextColor = .clearColor()
                lineChartDataSet2.valueTextColor = .clearColor()
                lineChartDataSet1.drawCirclesEnabled = false
                lineChartDataSet2.drawCirclesEnabled = false
            }
            
        }
    }
    
    func setPieChart(userMiles: [Double], oppMiles: [Double]) {
        
        for i in 0..<userMiles.count {
            let dataEntry = ChartDataEntry(value: oppMiles[i], xIndex: i)
            dataEntries1.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries1, label: "Units Sold")
        let pieChartData = PieChartData(xVals: userMiles, dataSet: pieChartDataSet)
        pieChart.data = pieChartData
        
        var colors: [UIColor] = []
        
        for _ in 0..<userMiles.count {
            
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
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


