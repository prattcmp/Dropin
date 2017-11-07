//
//  FriendViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 9/20/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import RealmSwift

class FriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, MGSwipeTableCellDelegate {
    var friendView: FriendView!
    var settingsViewController: SettingsViewController!

    var friends = [User]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_  animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                currentUser.refreshFriends { (_ isSuccess: Bool) in
                    self.friends = currentUser.friends
                    self.friendView.friendTable.reloadData()
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return friendView.headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return friendView.headerHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Adding 1 because of the "Add Friend" cell
        return friends.count + 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return friendView.addFriendCell
        }
        
        let cell: MGSwipeTableCell = MGSwipeTableCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
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
    
    func showSettings() {
        navController.pushViewController(SettingsViewController(), animated: true)
    }
}
