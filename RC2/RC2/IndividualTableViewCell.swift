//
//  IndividualTableViewCell.swift
//  RC2
//
//  Created by Ryan Plitt on 9/23/16.
//  Copyright © 2016 Chris Yoo. All rights reserved.
//

import UIKit

class IndividualTableViewCell: UITableViewCell {

    @IBOutlet weak var rankNumberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCellWithFriendsArray(friend: Friend){
        nameLabel.text = "\(friend.friendFirstName) \(friend.friendLastName)"
        milesLabel.text = "\(friend.friendMiles) miles"
        stepsLabel.text = "\(friend.friendSteps) steps"
    }

}
