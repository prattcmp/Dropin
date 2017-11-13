//
//  FriendViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 9/20/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import SnapKit
import SwiftSpinner

class FriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, MGSwipeTableCellDelegate {
    var friendView: FriendView!
    var settingsViewController: SettingsViewController!

    var friends = [User]()
    var loading = true
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.friends = currentUser.friends
        if currentUser.friends.count > 0 {
            self.loading = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_  animated: Bool) {
        super.viewDidAppear(animated)
        if currentUser.friends.count > 0 {
            self.loading = false
            self.friends = currentUser.friends
            
            self.friendView.friendTable.reloadData()
        }

        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                currentUser.refreshFriends { (_ isSuccess: Bool) in
                    DispatchQueue.main.async {
                        self.loading = false
                        self.friends = currentUser.friends
                        
                        self.friendView.friendTable.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false

        friendView = FriendView()
        friendView.friendTable.delegate = self
        friendView.friendTable.dataSource = self
        
        // Show the table
        self.view.addSubview(friendView)
        
        friendView.settingsButton?.addTarget(self, action: #selector(showSettings), for: .touchUpInside)
    }
    
    // Disables tableview bouncing at the top
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == friendView.friendTable {
            let a = scrollView.contentOffset
            if a.y <= 0 {
                scrollView.contentOffset = CGPoint.zero
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading {
            return 2
        }
        
        // Adding 1 because of the "Add Friend" cell
        return friends.count + 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return friendView.addFriendCell
        }
        if loading {
            let cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "loading-cell")
            cell.textLabel!.text = "Loading..."
            
            return cell
        }
        
        let cell: MGSwipeTableCell = MGSwipeTableCell(style: .subtitle, reuseIdentifier: "cell")
        cell.delegate = self
        
        // Adding 1 because of the "Add Friend" cell
        cell.textLabel!.text = self.friends[(indexPath.row - 1)].name
        cell.detailTextLabel!.text = "@" + self.friends[(indexPath.row - 1)].username
        cell.detailTextLabel!.alpha = 0.5
        
        cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: .red)]
        cell.rightSwipeSettings.transition = .border
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let alert = UIAlertController(title: "Add a friend",
                                          message: "Enter their username and press \"Add\"",
                                          preferredStyle: .alert)
            
            let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
                if (alert.textFields?[0].text) != nil {
                    self.addFriend(username: (alert.textFields?[0].text)!)
                } else {
                    // user did not fill field
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            
            alert.addTextField { (textField) in
                textField.placeholder = "@dropin123"
            }
            
            alert.addAction(addAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        
        return true
    }
    
    // Remove friend
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        
        self.removeFriend(indexPath: self.friendView.friendTable.indexPath(for: cell)!)
        
        return true
    }
    
    func addFriend(username: String) {
        SwiftSpinner.show("Adding friend...").addTapHandler({
            SwiftSpinner.hide()
        }, subtitle: "tap to hide")

        currentUser?.addFriend(username: username) { (_ isSuccess: Bool, _ message: String, _ friend: User) in
            if (!isSuccess) {
                let alertController = UIAlertController(title: "Uh oh", message: message != "" ? message : "Something went wrong. Try again later.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                SwiftSpinner.hide()
                return
            }
            
            DispatchQueue.main.async {
                self.friends.append(friend)
                
                self.friendView.friendTable.beginUpdates()
                self.friendView.friendTable.insertRows(at: [IndexPath(row: self.friends.count, section: 0)], with: .automatic)
                self.friendView.friendTable.endUpdates()
                
                SwiftSpinner.hide()
            }
        }
    }
    
    func removeFriend(indexPath: IndexPath) {
        SwiftSpinner.show("Removing friend...").addTapHandler({
            SwiftSpinner.hide()
        }, subtitle: "tap to hide")
        
        let id = self.friends[indexPath.row - 1].id as Int
        
        currentUser?.removeFriend(id: id) { (_ isSuccess: Bool, _ message: String) in
            if (!isSuccess) {
                let alertController = UIAlertController(title: "Uh oh", message: message != "" ? message : "Something went wrong. Try again later.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                print(message)
                SwiftSpinner.hide()
                return
            }
            
            DispatchQueue.main.async {
                self.friends.remove(at: (indexPath.row - 1))
                self.friendView.friendTable.deleteRows(at: [indexPath], with: .automatic)
                SwiftSpinner.hide()
            }
        }
    }
    
    func showSettings() {
        navController.pushViewController(SettingsViewController(), animated: true)
    }
}
