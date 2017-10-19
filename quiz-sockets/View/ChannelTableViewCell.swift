//
//  ChannelTableViewCell.swift
//  quiz-sockets
//
//  Created by Morten Saabye Kristensen on 10/10/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {

    @IBOutlet weak var ChannelLabel: UILabel!
    @IBOutlet weak var moderatorNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
