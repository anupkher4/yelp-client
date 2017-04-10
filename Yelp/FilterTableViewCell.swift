//
//  FilterTableViewCell.swift
//  Yelp
//
//  Created by Anup Kher on 4/9/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FilterTableViewCellDelegate {
    @objc optional func filterTableViewCell(tableViewCell: FilterTableViewCell, didChangeValue value: Bool)
}

class FilterTableViewCell: UITableViewCell {
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterSwitch: UISwitch!

    var delegate: FilterTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        filterSwitch.addTarget(self, action: #selector(switchValueChanged(sender:)), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func switchValueChanged(sender: UISwitch) {
        delegate?.filterTableViewCell?(tableViewCell: self, didChangeValue: sender.isOn)
    }
}
