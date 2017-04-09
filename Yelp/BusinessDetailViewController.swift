//
//  BusinessDetailViewController.swift
//  Yelp
//
//  Created by Anup Kher on 4/9/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class BusinessDetailViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var businessDetailView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapLocationLabel: UILabel!

    var currentBusiness: Business!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = UIColor.white
        
        mapView.delegate = self
        
        if let posterUrl = currentBusiness.imageURL {
            posterImageView.setImageWith(posterUrl)
        }
        nameLabel.text = currentBusiness.name
        ratingImageView.setImageWith(currentBusiness.ratingImageURL!)
        reviewsLabel.text = "\(currentBusiness.reviewCount!) reviews"
        distanceLabel.text = currentBusiness.distance
        addressLabel.text = currentBusiness.address
        categoriesLabel.text = currentBusiness.categories
        
        let centerLocation = CLLocation(latitude: currentBusiness.coordinate.lat!, longitude: currentBusiness.coordinate.long!)
        goToLocation(location: centerLocation)
        addAnnotationAtCoordinate(coordinate: centerLocation.coordinate)
        mapLocationLabel.text = addressLabel.text
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.02, 0.02)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
    
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = nameLabel.text
        mapView.addAnnotation(annotation)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
