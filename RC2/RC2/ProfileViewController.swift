//
//  ProfileViewController.swift
//  RC2
//
//  Created by Retika Kumar on 9/26/16.
//  Copyright © 2016 Chris Yoo. All rights reserved.
//

import UIKit
import Charts

class ProfileViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func update(sender: AnyObject) {
        callPullUserData()
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var userMilesLabel: UILabel!
    @IBOutlet weak var userStepsLabel: UILabel!
    @IBOutlet weak var barChart: BarChartView!
    
    var dataEntries: [BarChartDataEntry] = []
    var miles: [Double] {
        var miles: [Double] = []
        let milesArray = FacebookController.sharedController.sessions.flatMap({$0.miles})
        for mile in milesArray {
            miles.append(Double(mile)!)
        }
        let last7 = Array(miles.suffix(returnNumberForSegmentController(segmentedControl.selectedSegmentIndex)))
        return last7
    }
    
    var dates: [String] {
        var finalDates: [String] = []
        let dates = FacebookController.sharedController.sessions.flatMap({$0.formattedDate})
        for date in dates {
            let newDate = String(date.characters.suffix(5))
            finalDates.append(newDate)
        }
        let last7 = Array(finalDates.suffix(returnNumberForSegmentController(segmentedControl.selectedSegmentIndex)))
        return last7
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
    
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.segmentedControl.layer.borderColor = UIColor(red: 247/255, green: 67/255, blue: 76/255, alpha: 1.0).CGColor
        self.segmentedControl.layer.borderWidth = 2
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
        self.profileImageView.clipsToBounds = true
        profileImageView.contentMode = .ScaleAspectFill
        self.profileImageView.layer.borderWidth = 1
        self.profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 247/255, green: 57/255, blue: 80/255, alpha: 1.0)
        barChart.delegate = self
        
        FacebookController.sharedController.pullUserData {
            self.callPullUserData()
//            self.setChart(self.dates,values: self.miles)
            
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        FacebookController.sharedController.pullUserData {
            self.callPullUserData()
            self.setChart(self.dates,values: self.miles)
        }
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        barChart.noDataText = "Data has not been provided for charts."
        barChart.xAxis.labelPosition = .Bottom
        barChart.rightAxis.enabled = false
        self.dataEntries = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Miles Traveled")
        let chartData = BarChartData(xVals:dates, dataSet: chartDataSet)
        barChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.5)
        barChart.data = chartData
        barChart.notifyDataSetChanged()
        barChart.descriptionText = ""
        
        chartDataSet.colors = [UIColor(red: 247/255, green: 67/255, blue: 76/255, alpha: 1)]
        chartDataSet.valueTextColor = .whiteColor()
        chartDataSet.highlightEnabled = false
        chartData.notifyDataChanged()
        chartDataSet.notifyDataSetChanged()
        if segmentedControl.selectedSegmentIndex == 0 {
            barChart.xAxis.setLabelsToSkip(0)
        } else {
            barChart.xAxis.resetLabelsToSkip()
            chartDataSet.valueTextColor = .clearColor()
        }
        barChart.leftAxis.axisMinValue = 0
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.xAxis.labelTextColor = .whiteColor()
        barChart.leftAxis.labelTextColor = .whiteColor()
        barChart.legend.enabled = false
        barChart.infoTextColor = UIColor.whiteColor()
        
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        //  print("\(entry.value) in \(days[entry.xIndex])")
    }
    
    func callPullUserData() {
        user = FacebookController.sharedController.userData
        print(user?.userEmail)
        print(user?.userEmail)
        if let user = user {
            firstNameLabel.text = "Welcome \(user.userFirstName)"
            //lastNameLabel.text = user?.userLastName
            userMilesLabel.text = "Miles: \(user.userMiles)"
            userStepsLabel.text = "Steps: \(user.userSteps)"
            
            let imageURL = user.userPhotoURL
            if let imageURLString: NSURL = NSURL(string: imageURL) {
                let task = NSURLSession.sharedSession().dataTaskWithURL(imageURLString) { (data, response, error) -> Void in
                    
                    if error != nil {
                        print("thers an error in the log")
                    } else {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            let image = UIImage(data: data!)
                            self.profileImageView.image = image
                        }
                    }
                }
                
                task.resume()
                
            }
        }
    }
    
    @IBAction func segmentedControllerValueChanged(sender: UISegmentedControl) {
        self.setChart(dates, values: miles)
        
    }
    
}


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */


//    func setChart(dataPoints: [String], values: [Double]) {
//        barChart.noDataText = "Data has not been provided for charts."
//
//        for i in 0..<dataPoints.count {
//            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
//            dataEntries.append(dataEntry)
//        }
//
//        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Miles Traveled")
//        let chartData = BarChartData(xVals:days, dataSet: chartDataSet)
//        barChart.animate(xAxisDuration: 2.5, yAxisDuration: 3.0)
//        barChart.data = chartData
//        barChart.descriptionText = ""
//
//        chartDataSet.colors = [UIColor(red: 25/255, green: 25/255, blue: 205/255, alpha: 1)]
//    }
//
//    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
//        //  print("\(entry.value) in \(days[entry.xIndex])")
//    }


