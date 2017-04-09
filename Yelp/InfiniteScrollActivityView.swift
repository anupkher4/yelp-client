//
//  InfiniteScrollActivityView.swift
//  Yelp
//
//  Created by Anup Kher on 4/8/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class InfiniteScrollActivityView: UIView {
    
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight: CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
    }
    
    func setup() {
        activityIndicatorView.activityIndicatorViewStyle = .gray
        activityIndicatorView.backgroundColor = UIColor.black
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        activityIndicatorView.stopAnimating()
        self.isHidden = true
    }
    
    func startAnimating() {
        self.isHidden = false
        activityIndicatorView.startAnimating()
    }
}
