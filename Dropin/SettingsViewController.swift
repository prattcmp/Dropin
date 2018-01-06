//
//  SettingsViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 9/25/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var settingsView: SettingsView!
    var parentController: UIViewController!

    var cells = [UITableViewCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        settingsView = SettingsView()
        settingsView.settingsTable.delegate = self
        settingsView.settingsTable.dataSource = self
        
        self.cells.append(settingsView.userLocationCell)
        self.cells.append(settingsView.logoutCell)
        
        settingsView.backButton.setTitle("Settings", for: .normal)
        settingsView.backButton.setTitleColor(.white, for: .normal)
        settingsView.backButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, -5.0)
        settingsView.backButton.sizeToFit()
        settingsView.backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        UserLocation.getEnabled() { (isSuccess, message, enabled) in
            if (isSuccess) {
                self.settingsView.userLocationSwitch.setOn(enabled, animated: false)
            }
        }
    
        settingsView.userLocationSwitch.addTarget(self, action: #selector(userLocationSwitched), for: .valueChanged)

        // Show the table
        self.view.addSubview(settingsView)
    }
    
    @objc func userLocationSwitched(_ sender: AnyObject?) {
        if settingsView.userLocationSwitch.isOn {
            significantUpdateManager.requestAlwaysAuthorization()
            significantUpdateManager.startMonitoringSignificantLocationChanges()
        } else {
            significantUpdateManager.stopMonitoringSignificantLocationChanges()
        }
        
        UserLocation.setEnabled(settingsView.userLocationSwitch.isOn) { (isSuccess, message) in
            if (!isSuccess) {
                let alertController = UIAlertController(title: "Uh oh", message: message != "" ? message : "Something went wrong. Try again later.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                self.settingsView.userLocationSwitch.setOn(!self.settingsView.userLocationSwitch.isOn, animated: false)
                return
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < cells.count {
            return cells[indexPath.row]
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let alert = UIAlertController(title: "Are you sure?",
                                          message: "Are you sure you want to logout?",
                                          preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                logout()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            
            alert.addAction(yesAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }
    
    @objc func goBack() {
        navController.popViewController(animated: true)
    }
}
