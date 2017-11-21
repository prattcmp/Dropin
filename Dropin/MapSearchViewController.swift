//
//  MapSearchViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 11/20/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit
import MapKit

protocol MapSearchViewControllerDelegate
{
    func searchCompleted(coordinates: CLLocationCoordinate2D)
}

class MapSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKLocalSearchCompleterDelegate {
    var delegate: MapSearchViewControllerDelegate?
    
    var mapSearchView: MapSearchView!
    var searchTable: UITableView!
    var searchTextField: UITextField!
    
    var searchCompleter: MKLocalSearchCompleter!
    var searchAddresses = [MKLocalSearchCompletion]()
    
    var currentCoordinates: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        mapSearchView = MapSearchView()
        
        searchTable = mapSearchView.searchTable
        searchTable.delegate = self
        searchTable.dataSource = self
        
        searchTextField = mapSearchView.searchTextField
        searchTextField.becomeFirstResponder()
        
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter.delegate = self
        searchCompleter.region = MKCoordinateRegionMakeWithDistance(self.currentCoordinates, 10_000, 10_000)
        
        // Show the table
        self.view.addSubview(mapSearchView)
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        mapSearchView.backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        searchCompleter.queryFragment = textField.text ?? ""
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchAddresses = completer.results
        searchTable.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchAddresses.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        if searchAddresses.count == 0 {
            cell.textLabel!.text = "Type an address to search..."
            return cell
        }
        
        let searchAddress = self.searchAddresses[(indexPath.row)]
        
        cell.textLabel!.text = searchAddress.title
        cell.detailTextLabel!.text = searchAddress.subtitle
        cell.detailTextLabel!.alpha = 0.5
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchAddress = self.searchAddresses[indexPath.row]
        let searchRequest = MKLocalSearchRequest(completion: searchAddress)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { (response, error) in
            navController.popViewController(animated: true)
            
            if let response = response {
                self.delegate?.searchCompleted(coordinates: response.mapItems[0].placemark.coordinate)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @objc func goBack() {
        navController.popViewController(animated: true)
    }
    
}
