//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var businessTableView: UITableView!
    
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
        
        let filterButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: nil)
        filterButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = filterButton
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension BusinessesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        currentSearchText = searchBar.text!
        
        Business.searchWithTerm(term: currentSearchText) {
            (businesses: [Business]?, error: Error?) in
            self.businesses = businesses
            self.businessTableView.reloadData()
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
        }
        
    }
    
}
