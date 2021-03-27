//
//  paletteCell.swift
//  LogoPalette
//
//  Created by Abdelrahman  Tealab on 2021-03-26.
//

import UIKit

class paletteCell: UITableViewCell {

    @IBOutlet weak var cellLogo: UIImageView!
    @IBOutlet weak var cellColor1: UILabel!
    @IBOutlet weak var cellColor2: UILabel!
    @IBOutlet weak var cellColor3: UILabel!
    @IBOutlet weak var cellColor4: UILabel!
    @IBOutlet weak var cellColor5: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
