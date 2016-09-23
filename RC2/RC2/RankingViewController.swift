//
//  RankingViewController.swift
//  RC2
//
//  Created by Ryan Plitt on 9/23/16.
//  Copyright © 2016 Chris Yoo. All rights reserved.
//

import UIKit

class RankingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var rankedFriends: [Friend] = FacebookController.sharedController.friendDataArray.sort { (friend1, friend2) -> Bool in
        return friend1.friendMiles > friend2.friendMiles
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rankedFriends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("publicCell") as? IndividualTableViewCell else {return UITableViewCell()}
        
        let friend = self.rankedFriends[indexPath.row]
        cell.updateCellWithFriendsArray(friend)
        cell.rankNumberLabel.text = "\(indexPath.row)"
        
        
        return cell
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
