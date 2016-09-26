//
//  CompareViewController.swift
//  RC2
//
//  Created by Chad Watts on 9/26/16.
//  Copyright © 2016 Chris Yoo. All rights reserved.
//

import UIKit

class CompareViewController: UIViewController {
    
    @IBOutlet weak var personalName: UILabel!
    @IBOutlet weak var personalAge: UILabel!
    @IBOutlet weak var personalDay: UILabel!
    @IBOutlet weak var personalMonth: UILabel!
    @IBOutlet weak var personalYear: UILabel!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendAge: UILabel!
    @IBOutlet weak var friendDay: UILabel!
    @IBOutlet weak var friendMonth: UILabel!
    @IBOutlet weak var friendYear: UILabel!
    @IBOutlet weak var segmentedView: UISegmentedControl!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
