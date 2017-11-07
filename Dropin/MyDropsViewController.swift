//
//  MyDropsViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 10/26/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import RealmSwift

class MyDropsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, MGSwipeTableCellDelegate {
    var myDropsView: MyDropsView!

    var drops = [Drop]()
    
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
                currentUser.refreshDrops { (_ isSuccess: Bool) in
                    self.drops = currentUser.drops
                    DispatchQueue.main.async {
                        self.myDropsView.dropTable.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        myDropsView = MyDropsView()
        myDropsView.dropTable.delegate = self
        myDropsView.dropTable.dataSource = self
        
        // Show the table
        self.view.addSubview(myDropsView)
        
    }
    
    // Disables tableview bouncing at the top
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == myDropsView.dropTable {
            let a = scrollView.contentOffset
            if a.y <= 0 {
                scrollView.contentOffset = CGPoint.zero
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return myDropsView.headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return myDropsView.headerHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drops.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MGSwipeTableCell = MGSwipeTableCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        cell.delegate = self
        
        cell.textLabel!.text = self.drops[indexPath.row].from?.name
        cell.detailTextLabel!.text = self.drops[indexPath.row].expires_at.timeAgoSinceNow()
        cell.detailTextLabel!.alpha = 0.5
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navController.pushViewController(DropViewController(drop: self.drops[indexPath.row]), animated: true)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
}

