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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        settingsView = SettingsView()
        settingsView.settingsTable.delegate = self
        settingsView.settingsTable.dataSource = self
        
        settingsView.backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        // Show the table
        self.view.addSubview(settingsView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return settingsView.logoutCell
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
    
    func goBack() {
        navController.popViewController(animated: true)
    }
}
