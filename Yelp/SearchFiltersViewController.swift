//
//  SearchFiltersViewController.swift
//  Yelp
//
//  Created by Anup Kher on 4/9/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SearchFiltersViewControllerDelegate {
    @objc optional func searchFiltersViewController(filtersViewController: SearchFiltersViewController, didUpdateSearchFilters filters: [String : Any])
}

class SearchFiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FilterTableViewCellDelegate {
    @IBOutlet weak var filtersTableView: UITableView!
    
    var delegate: SearchFiltersViewControllerDelegate?
    
    var showDeals: Bool = false
    let sortModes = ["Best Match", "Distance", "Highest Rated"]
    var selectedSortIndex: IndexPath?
    let distances = [0, 0.3, 1, 5, 20]
    var selectedDistanceIndex: IndexPath?
    let categories: [[String : String]] = Categories.getAllCategories()
    var switchStates = [Int : Bool]()
    var searchFilters: [String : Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation Bar setup
        let yelpRed = UIColor(red: 196/255.0, green: 18/255.0, blue: 0, alpha: 1.0)
        navigationController?.navigationBar.barTintColor = yelpRed
        
        let saveButton = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(saveClicked(sender:)))
        saveButton.tintColor = UIColor.white
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClicked(sender:)))
        cancelButton.tintColor = UIColor.white
        let filterLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        filterLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        filterLabel.textColor = UIColor.white
        filterLabel.text = "Filter"
        
        navigationItem.titleView = filterLabel
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
        
        filtersTableView.delegate = self
        filtersTableView.dataSource = self
        filtersTableView.allowsMultipleSelection = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelClicked(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveClicked(sender: UIBarButtonItem) {
        searchFilters.updateValue(showDeals, forKey: "Deal")
        
        if let sortIndex = selectedSortIndex?.row {
            searchFilters.updateValue(sortIndex, forKey: "Sort")
        }
        
        if let distanceIndex = selectedDistanceIndex?.row {
            let distance = distances[distanceIndex]
            let distanceInMeters = distance * 1609.34
            searchFilters.updateValue(distanceInMeters, forKey: "Distance")
        }
        
        var selectedCategories = [String]()
        for (index, value) in switchStates {
            if value {
                if let category = categories[index]["code"] {
                    selectedCategories.append(category)
                }
            }
        }
        searchFilters.updateValue(selectedCategories, forKey: "Category")
        
        delegate?.searchFiltersViewController?(filtersViewController: self, didUpdateSearchFilters: searchFilters)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            if selectedSortIndex != nil {
                let uncheckCell = tableView.cellForRow(at: selectedSortIndex!)
                uncheckCell?.accessoryType = .none
            }
            let checkCell = tableView.cellForRow(at: indexPath)
            checkCell?.accessoryType = .checkmark
            selectedSortIndex = indexPath
        } else if indexPath.section == 2 {
            if selectedDistanceIndex != nil {
                let uncheckCell = tableView.cellForRow(at: selectedDistanceIndex!)
                uncheckCell?.accessoryType = .none
            }
            let checkCell = tableView.cellForRow(at: indexPath)
            checkCell?.accessoryType = .checkmark
            selectedDistanceIndex = indexPath
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
        case 1:
            return "Sort"
        case 2:
            return "Distance"
        case 3:
            return "Category"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return sortModes.count
        case 2:
            return distances.count
        case 3:
            return 5
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! FilterTableViewCell
            cell.filterLabel.text = "Offering a deal"
            cell.filterSwitch.isOn = showDeals ?? false
            return cell
        case 1:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = sortModes[indexPath.row]
            if indexPath.row == selectedSortIndex?.row {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        case 2:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            let distance = distances[indexPath.row]
            if distance == 0 {
                cell.textLabel?.text = "Auto"
            } else {
                cell.textLabel?.text = "\(distance) miles"
            }
            if indexPath.row == selectedDistanceIndex?.row {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! FilterTableViewCell
            
            cell.delegate = self
            cell.filterLabel.text = categories[indexPath.row]["name"]
            cell.filterSwitch.isOn = switchStates[indexPath.row] ?? false
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func filterTableViewCell(tableViewCell: FilterTableViewCell, didChangeValue value: Bool) {
        let indexPath = filtersTableView.indexPath(for: tableViewCell)
        if let section = indexPath?.section {
            switch section {
            case 0:
                showDeals = value
            case 3:
                if let index = indexPath?.row {
                    switchStates.updateValue(value, forKey: index)
                }
            default:
                print("default case for filterTableViewCell didChangeValue")
            }
        }
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
