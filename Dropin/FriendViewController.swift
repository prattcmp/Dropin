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
import PMAlertController

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
        
        showReviewPopup()
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
        
        // Subtracting 1 because of the "Add Friend" cell
        let friend = self.friends[(indexPath.row - 1)]
        let cell: MGSwipeTableCell = MGSwipeTableCell(style: .subtitle, reuseIdentifier: "friend-cell")
        cell.delegate = self
        
        cell.textLabel!.text = friend.name
        cell.textLabel!.font = UIFont(name: cell.textLabel!.font.fontName, size: 15)
        cell.detailTextLabel!.text = "@" + friend.username
        cell.detailTextLabel!.alpha = 0.5
        
        cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: .red), MGSwipeButton(title: "Block", backgroundColor: .orange)]
        cell.rightSwipeSettings.transition = .border
        
        let pointCountView = PointCountView()
        if let points = friend.points {
            pointCountView.setPoints(points)
            cell.accessoryView = pointCountView
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let alertVC = PMAlertController(title: "Add a friend", description: "Enter their username and press \"Add\"", image: nil, style: .alert)
            
            alertVC.addTextField { (textField) in
                textField?.placeholder = "@username"
                textField?.autocapitalizationType = .none
                textField?.autocorrectionType = .no
            }
            alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: nil))
            alertVC.addAction(PMAlertAction(title: "Add", style: .default, action: { () in
                if let textField = alertVC.textFields.first {
                    let text = textField.text
                    
                    if (text) != nil {
                        self.addFriend(username: (text)!)
                    } else {
                        // user did not fill field
                    }
                }
            }))
            
            self.present(alertVC, animated: true, completion: nil)
            
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
        if index == 0 {
            self.removeFriend(indexPath: self.friendView.friendTable.indexPath(for: cell)!)
        } else if index == 1 {
            self.blockFriend(indexPath: self.friendView.friendTable.indexPath(for: cell)!)
        }
        
        return true
    }
    
    func addFriend(username: String) {
        currentUser?.addFriend(username: username) { (_ isSuccess: Bool, _ message: String, _ friend: User) in
            if (!isSuccess) {
                let alertController = UIAlertController(title: "Uh oh", message: message != "" ? message : "Something went wrong. Try again later.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            DispatchQueue.main.async {
                self.friends.append(friend)
                
                self.friendView.friendTable.beginUpdates()
                self.friendView.friendTable.insertRows(at: [IndexPath(row: self.friends.count, section: 0)], with: .automatic)
                self.friendView.friendTable.endUpdates()
            }
        }
    }
    
    func removeFriend(indexPath: IndexPath) {
        let id = self.friends[indexPath.row - 1].id as Int
        
        currentUser?.removeFriend(id: id) { (_ isSuccess: Bool, _ message: String) in
            if (!isSuccess) {
                let alertController = UIAlertController(title: "Uh oh", message: message != "" ? message : "Something went wrong. Try again later.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)

                return
            }
            
            DispatchQueue.main.async {
                self.friends.remove(at: (indexPath.row - 1))
                self.friendView.friendTable.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func blockFriend(indexPath: IndexPath) {
        let id = self.friends[indexPath.row - 1].id as Int
        
        currentUser?.blockFriend(id: id) { (_ isSuccess: Bool, _ message: String) in
            if (!isSuccess) {
                let alertController = UIAlertController(title: "Uh oh", message: message != "" ? message : "Something went wrong. Try again later.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)

                return
            }
            
            DispatchQueue.main.async {
                // If the user was successfully blocked, then remove them
                self.removeFriend(indexPath: indexPath)
            }
        }
    }
    
    @objc func showSettings() {
        navController.pushViewController(SettingsViewController(), animated: true)
    }
}
