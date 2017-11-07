//
//  FriendView.swift
//  Dropin
//
//  Created by Christopher Pratt on 9/20/17.
//  Copyright © 2017 Christopher Pratt. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class FriendView: UIView {
    var friendTable: UITableView!
    
    var headerCell: UITableViewCell!
    var addFriendCell: UITableViewCell!
    
    var headerView: UIView!
    var headerLabel: UILabel!
    let headerHeight: CGFloat = 60.0
    let rowHeight: CGFloat = 50.0
    
    var settingsImage: UIImage!
    var settingsButton: UIButton!
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        
        friendTable = UITableView(frame: super.frame, style: .grouped)
        friendTable.separatorInset = .zero
        friendTable.sectionHeaderHeight = headerHeight
        friendTable.separatorStyle = .singleLine
        friendTable.rowHeight = rowHeight
        self.addSubview(friendTable)
        
        addFriendCell = UITableViewCell()
        addFriendCell.accessoryType = .disclosureIndicator
        addFriendCell.textLabel!.text = "Add Friend"
        
        headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: headerHeight)
        headerView.backgroundColor = UIColor(red: 24/255, green: 190/255, blue: 255/255, alpha: 1)
        
        headerLabel = UILabel()
        headerLabel.textColor = UIColor.white
        headerLabel.font = UIFont(name: "Adobe Gothic Std", size: headerLabel.font.pointSize)
        headerLabel.text = "@" + getUsername()
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        settingsImage = UIImage(named: "gear")
        settingsButton = UIButton(type: .custom)
        settingsButton.setImage(settingsImage, for: .normal)
        headerView.addSubview(settingsButton)
        
        headerLabel.snp.makeConstraints { (make) in
            make.left.equalTo(headerView.snp.left).offset(7)
            make.bottom.equalTo(headerView.snp.bottom).offset(-7)
        }
        settingsButton.snp.makeConstraints { (make) in
            make.size.lessThanOrEqualTo(CGSize(width: 20, height: 20))
            make.centerY.equalTo(headerLabel.snp.centerY)
            make.right.equalTo(headerView.snp.right).offset(-10)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

