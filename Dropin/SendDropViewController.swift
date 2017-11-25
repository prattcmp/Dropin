//
//  SendDropViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 10/12/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit
import MapKit
import MGSwipeTableCell

class SendDropViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, MGSwipeTableCellDelegate {
    var sendDropView: SendDropView!
    
    var friends = [User]()
    var friendsSelected = [User]()
    
    var coordinates: CLLocationCoordinate2D!
    var text: String!
    
    init(currentUser: User, coordinates: CLLocationCoordinate2D, text: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.friends = currentUser.friends
        self.coordinates = coordinates
        self.text = text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                currentUser.refreshFriends { (_ isSuccess: Bool) in
                    DispatchQueue.main.async {
                        self.friends = currentUser.friends
                        
                        self.sendDropView.friendTable.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        sendDropView = SendDropView()
        sendDropView.friendTable.delegate = self
        sendDropView.friendTable.dataSource = self
        
        sendDropView.backButton.setTitle("Send to...", for: .normal)
        sendDropView.backButton.setTitleColor(.white, for: .normal)
        sendDropView.backButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, -5.0)
        sendDropView.backButton.sizeToFit()
        
        // Show the table
        self.view.addSubview(sendDropView)
        
        sendDropView.backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        sendDropView.sendButton.addTarget(self, action: #selector(sendDrop), for: .touchUpInside)
    }
    
    // Disables tableview bouncing at the top
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == sendDropView.friendTable {
            let a = scrollView.contentOffset
            if a.y <= 0 {
                scrollView.contentOffset = CGPoint.zero
            }
        }
    }
    
    @objc func sendDrop() {
        sendDropView.sendButton.isUserInteractionEnabled = false
        
        navController.popViewController(animated: true)
        
        Drop.send(to: friendsSelected, coordinates: self.coordinates, text: self.text) { (_ isSuccess: Bool, _ message: String)
            in
            if (!isSuccess) {
                let alertController = UIAlertController(title: "Uh oh", message: message != "" ? message : "Something went wrong. Try again later.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                return
            }
            
            self.sendDropView.sendButton.isUserInteractionEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sendDropView.headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sendDropView.headerHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        if friends.count == 0 {
            cell.textLabel!.text = "You don't have friends."
            cell.detailTextLabel!.text = "Go get some!"
            cell.detailTextLabel!.alpha = 0.5
            
            return cell
        }
        
        cell.textLabel!.text = self.friends[(indexPath.row)].name
        cell.detailTextLabel!.text = "@" + self.friends[indexPath.row].username
        cell.detailTextLabel!.alpha = 0.5
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let friend = self.friends[indexPath.row]
            
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                self.friendsSelected.remove(at: self.friendsSelected.index(of: friend)!)
            } else {
                cell.accessoryType = .checkmark
                self.friendsSelected.append(friend)
            }
        }
        
        if self.friendsSelected.count > 0 {
            self.sendDropView.showSendButton()
        } else {
            self.sendDropView.hideSendButton()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @objc func goBack() {
        navController.popViewController(animated: true)
    }
}
