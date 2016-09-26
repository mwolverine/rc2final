//
//  RankingTableViewController.swift
//  RC2
//
//  Created by Chris Yoo on 9/26/16.
//  Copyright © 2016 Chris Yoo. All rights reserved.
//

import UIKit

class RankingTableViewController: UITableViewController {
    
    var rankedFriends: [Friend] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        print(rankedFriends.count)
        self.rankedFriends = FacebookController.sharedController.friendDataArray.sort { (friend1, friend2) -> Bool in
            return friend1.friendMiles > friend2.friendMiles
        }
    }
    
    // MARK: - Table view data source
    
    @IBAction func updateButton(sender: AnyObject) {
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.rankedFriends.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("publicCell", forIndexPath: indexPath) as? IndividualTableViewCell
        
        let friend = self.rankedFriends[indexPath.row]
        cell?.nameLabel.text = "\(friend.friendFirstName) \(friend.friendLastName)"
        cell?.milesLabel.text = "\(friend.friendMiles) miles"
        cell?.stepsLabel.text = "\(friend.friendSteps) steps"
        
        return cell ?? UITableViewCell()
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
