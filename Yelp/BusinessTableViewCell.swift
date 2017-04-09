//
//  BusinessTableViewCell.swift
//  Yelp
//
//  Created by Anup Kher on 4/6/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessTableViewCell: UITableViewCell {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var ratingsImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!

    var business: Business! {
        didSet {
            if let posterUrl = business.imageURL {
                posterImageView.setImageWith(posterUrl)
            }
            posterImageView.layer.cornerRadius = posterImageView.frame.size.width / 20
            posterImageView.clipsToBounds = true
            ratingsImageView.setImageWith(business.ratingImageURL!)
            nameLabel.text = business.name
            distanceLabel.text = business.distance
            reviewsLabel.text = "\(business.reviewCount!) reviews"
            addressLabel.text = business.address
            //categoriesLabel.text = business.categories != nil ? business.categories : ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
