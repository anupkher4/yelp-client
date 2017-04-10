//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    @IBOutlet weak var businessTableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    var mapButton: UIBarButtonItem!
    var listButton: UIBarButtonItem!
    
    var businesses: [Business]!
    
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    
    var currentSearchText = "Thai"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation Bar setup
        let yelpRed = UIColor(red: 196/255.0, green: 18/255.0, blue: 0, alpha: 1.0)
        navigationController?.navigationBar.barTintColor = yelpRed
        
        let searchBar = UISearchBar()
        searchBar.placeholder = "Restaurants"
        searchBar.tintColor = UIColor.white
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        let filterButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterClicked(sender:)))
        filterButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = filterButton
        
        mapButton = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(mapClicked(sender:)))
        listButton = UIBarButtonItem(title: "List", style: .plain, target: self, action: #selector(listClicked(sender:)))
        
        mapButton.tintColor = UIColor.white
        listButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = mapButton
        
        // Table View setup
        businessTableView.delegate = self
        businessTableView.dataSource = self
        businessTableView.rowHeight = UITableViewAutomaticDimension
        businessTableView.estimatedRowHeight = 120
        
        let frame = CGRect(x: 0, y: businessTableView.contentSize.height, width: businessTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        businessTableView.addSubview(loadingMoreView!)
        
        var insets = businessTableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        businessTableView.contentInset = insets
        
        // Map View
        mapView.delegate = self
        mapView.isHidden = true
        let centerLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
        goToLocation(location: centerLocation)
        
        Business.searchWithTerm(term: currentSearchText, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.businessTableView.reloadData()
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
            
            }
        )
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadMapWithData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let businesses = self.businesses {
            return businesses.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessTableViewCell
        
        cell.business = businesses[indexPath.row]
        
        return cell
    }
    
    // MARK: - Button targets
    
    func filterClicked(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "businessToFilter", sender: sender)
    }
    
    func mapClicked(sender: UIBarButtonItem) {
        navigationItem.rightBarButtonItem = listButton
        mapView.isHidden = false
        businessTableView.isHidden = true
        loadMapWithData()
    }
    
    func listClicked(sender: UIBarButtonItem) {
        navigationItem.rightBarButtonItem = mapButton
        mapView.isHidden = true
        businessTableView.isHidden = false
    }
    
    // MARK: - Map View methods
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
    
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D, withTitle title: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    func loadMapWithData() {
        if self.businesses != nil {
            for business in businesses {
                let centerLocation = CLLocation(latitude: business.coordinate.lat!, longitude: business.coordinate.long!)
                addAnnotationAtCoordinate(coordinate: centerLocation.coordinate, withTitle: business.name!)
            }
        }
    }
    
    // MARK: - Segue method override
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "businessToDetail" {
            let destination = segue.destination as! BusinessDetailViewController
            let indexPath = businessTableView.indexPath(for: sender as! BusinessTableViewCell)
            destination.currentBusiness = businesses[indexPath!.row]
        }
        
        if segue.identifier == "businessToFilter" {
            let destinationNav = segue.destination as! UINavigationController
            let destination = destinationNav.topViewController as! SearchFiltersViewController
            destination.delegate = self
        }
    }
    
}

extension BusinessesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        currentSearchText = searchBar.text!
        
        Business.searchWithTerm(term: currentSearchText) {
            (businesses: [Business]?, error: Error?) in
            self.businesses = businesses
            self.businessTableView.reloadData()
            self.loadMapWithData()
        }
        
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
}

extension BusinessesViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !isMoreDataLoading {
            let scrollViewContentHeight = businessTableView.contentSize.height
            let scrollViewContentThreshold = scrollViewContentHeight - businessTableView.bounds.size.height
            
            if scrollView.contentOffset.y > scrollViewContentThreshold && businessTableView.isDragging {
                isMoreDataLoading = true
                loadingMoreView!.startAnimating()
                loadMoreData()
            }
        }
        
    }
    
    func loadMoreData() {
        
        Business.searchWithTerm(term: currentSearchText, offset: businesses.count) {
            (businesses: [Business]?, error: Error?) in
            self.loadingMoreView!.stopAnimating()
            self.isMoreDataLoading = false
            self.businesses.append(contentsOf: businesses as [Business]!)
            self.businessTableView.reloadData()
            self.loadMapWithData()
        }
        
    }
    
}

extension BusinessesViewController: SearchFiltersViewControllerDelegate {
    
    func searchFiltersViewController(filtersViewController: SearchFiltersViewController, didUpdateSearchFilters filters: [String : Any]) {
        currentSearchText = "Restaurants"
        
        var deals: Bool?
        if filters["Deal"] != nil {
            deals = filters["Deal"] as! Bool
        }
        
        var sort: Int?
        if filters["Sort"] != nil {
            sort = filters["Sort"] as! Int
        }
        
        var distance: Int?
        if filters["Distance"] != nil {
            distance = Int(filters["Distance"] as! Double)
        }
        
        var selectedCategories: [String]?
        if filters["Category"] != nil {
            selectedCategories = filters["Category"] as! [String]
        }
        
        Business.searchWithTerm(term: currentSearchText, sort: YelpSortMode(rawValue: sort!), categories: selectedCategories, deals: deals, radius: distance, offset: nil) {
            (businesses: [Business]?, error: Error?) in
            self.businesses = businesses
            self.businessTableView.reloadData()
            self.loadMapWithData()
        }
    }
    
}
