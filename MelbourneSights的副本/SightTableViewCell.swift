//
//  SightTableViewCell.swift
//  FIT5140-Assign1
//
//  Created by 张昊宇 on 2/9/19.
//  Copyright © 2019 Haoyu Zhang. All rights reserved.
//

import UIKit

class SightTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageLabel: UIImageView!
    @IBOutlet weak var imageLabel: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
