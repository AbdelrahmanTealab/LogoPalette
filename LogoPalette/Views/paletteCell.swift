//
//  paletteCell.swift
//  LogoPalette
//
//  Created by Abdelrahman  Tealab on 2021-03-26.
//

import UIKit

class paletteCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cellPaletteStackView: UIStackView!
    
    @IBOutlet weak var cellLogo: UIImageView!
    @IBOutlet weak var cellColor1: UILabel!
    @IBOutlet weak var cellColor2: UILabel!
    @IBOutlet weak var cellColor3: UILabel!
    @IBOutlet weak var cellColor4: UILabel!
    @IBOutlet weak var cellColor5: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = cellView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        let verticalConstraint = cellView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        let widthConstraint = cellView.widthAnchor.constraint(equalToConstant: 100)
        let heightConstraint = cellView.heightAnchor.constraint(equalToConstant: 120)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        

        cellPaletteStackView.layer.cornerRadius = 12
        cellPaletteStackView.clipsToBounds = true
        
        cellView.layer.masksToBounds = false
        cellView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cellView.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        cellView.layer.shadowOpacity = 1
        cellView.layer.shadowRadius = 3
        cellView.layer.cornerRadius = 12

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
