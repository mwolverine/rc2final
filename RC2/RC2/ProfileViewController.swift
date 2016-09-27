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
    
    @IBAction func update(sender: AnyObject) {
        callPullUserData()
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userMilesLabel: UILabel!
    @IBOutlet weak var userStepsLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var barChart: BarChartView!
    
    var dataEntries: [BarChartDataEntry] = []
    var miles: [Double] {
        var miles: [Double] = []
        var milesArray = FacebookController.sharedController.sessions.flatMap({$0.miles})
        for mile in milesArray {
            miles.append(Double(mile)!)
        }
        let last7 = Array(miles.suffix(7))
        return last7
    }
    var dates: [String] {
        var finalDates: [String] = []
        var dates = FacebookController.sharedController.sessions.flatMap({$0.formattedDate})
        for date in dates {
            let newDate = String(date.characters.suffix(5))
            finalDates.append(newDate)
        }
        let last7 = Array(finalDates.suffix(7))
        return last7
    }
    
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
        self.profileImageView.clipsToBounds = true
        barChart.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        FacebookController.sharedController.pullUserData()
        callPullUserData()
        self.setChart(dates,values: miles)
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        barChart.noDataText = "Data has not been provided for charts."
        barChart.xAxis.labelPosition = .Bottom
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Miles Traveled")
        let chartData = BarChartData(xVals:dates, dataSet: chartDataSet)
        barChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.5)
        barChart.data = chartData
        barChart.descriptionText = ""
        
        chartDataSet.colors = [UIColor(red: 25/255, green: 25/255, blue: 205/255, alpha: 1)]
        chartDataSet.highlightEnabled = false
        barChart.drawGridBackgroundEnabled = false
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        //  print("\(entry.value) in \(days[entry.xIndex])")
    }
    
    func callPullUserData() {
        user = FacebookController.sharedController.userData
        print(user?.userEmail)
        print(user?.userEmail)
        if let user = user {
            firstNameLabel.text = " \(user.userFirstName) \( user.userLastName)"
            emailLabel.text = user.userEmail
            //lastNameLabel.text = user?.userLastName
            userMilesLabel.text = "Total Miles Walked: \(user.userMiles)"
            userStepsLabel.text = "Total Steps Taken: \(user.userSteps)"
            //genderLabel.text = user?.userGender
            
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


