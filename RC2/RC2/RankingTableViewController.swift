//
//  RankingTableViewController.swift
//  RC2
//
//  Created by Chris Yoo on 9/26/16.
//  Copyright © 2016 Chris Yoo. All rights reserved.
//

import UIKit
import Charts

class RankingTableViewController: UITableViewController {
    
    var rankedFriends: [Friend] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(red: 20/255.0, green: 57/255.0, blue: 80/255.0, alpha: 1.0)
        FacebookController.sharedController.pullFriendsMilesData {
            self.rankedFriends = FacebookController.sharedController.friendDataArray.sort { (friend1, friend2) -> Bool in
                return friend1.friendMiles > friend2.friendMiles
                
            }
            self.tableView.reloadData()

        }
        //        FacebookController.sharedController.queryFriendMiles()
        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor(red: 20/255.0, green: 57/255.0, blue: 80/255.0, alpha: 1.0)
        //        tableView.separatorColor = UIColor.yellowColor()
        
    }
    //
    // MARK: - Table view data source
    
    @IBAction func updateButton(sender: AnyObject) {
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.rankedFriends.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor(red: 250/255.0, green: 58/255.0, blue: 0/255.0, alpha: 0.6)
        
        //        let rankedDetailFriend = rankedFriends[indexPath.row]
        //        let friendUID = rankedDetailFriend.friendUID
        //
        //        FacebookController.sharedController.queryFriendMiles(friendUID, completion: {
        //            self.performSegueWithIdentifier("id", sender: self)
        //
        //            })
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("publicCell", forIndexPath: indexPath) as? IndividualTableViewCell
        
        let friend = self.rankedFriends[indexPath.row]
        let indexPathNumber = indexPath.row + 1
        cell?.rankNumberLabel.text = String(indexPathNumber)
        cell?.nameLabel.text = "\(friend.friendFirstName) \(friend.friendLastName)"
        cell?.milesLabel.text = "\(friend.friendMiles) mi"
        cell?.stepsLabel.text = "Steps: \(friend.friendSteps)"
        
        tableView.separatorColor = UIColor(colorLiteralRed: 250/255.0, green: 58/255.0, blue: 0/255.0, alpha: 0.6)
        
        return cell ?? UITableViewCell()
    }
    
    
    
    //    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //        let rankedDetailFriend = rankedFriends[indexPath.row]
    //        let friendUID = rankedDetailFriend.friendUID
    //
    //        FacebookController.sharedController.queryFriendMiles(friendUID, completion: {
    //            self.performSegueWithIdentifier("id", self) {
    //                //                    if let detailViewController = segue.destinationViewController as? CompareViewController, indexPath = tableView.indexPathForSelectedRow {
    //                let rankedDetailFriend = self.rankedFriends[indexPath.row]
    //                detailViewController.friend = rankedDetailFriend
    //            }
    //
    //
    //        })
    //    }
    //    /*
    
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
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "comparingChartsView" {
            if let detailViewController = segue.destinationViewController as? CompareViewController, indexPath = tableView.indexPathForSelectedRow {
                let rankedDetailFriend = rankedFriends[indexPath.row]
                detailViewController.friend = rankedDetailFriend
                let friendUID = rankedDetailFriend.friendUID
                FacebookController.sharedController.queryFriendMiles(friendUID, completion: {
                })
            }
        }
    }
    
    
}
