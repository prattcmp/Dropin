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
    
    var addFriendCell: UITableViewCell!

    var headerView: UIView!
    var headerLabel: UILabel!
    var settingsImage: UIImage!
    var settingsButton: UIButton!
    
    let rowHeight: CGFloat = 50.0
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        
        friendTable = UITableView(frame: super.frame, style: .plain)
        friendTable.separatorInset = .zero
        friendTable.separatorStyle = .singleLine
        friendTable.rowHeight = rowHeight
        self.addSubview(friendTable)
        
        addFriendCell = UITableViewCell()
        addFriendCell.accessoryType = .disclosureIndicator
        addFriendCell.textLabel!.text = "Add Friend"
        
        headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 55)
        headerView.backgroundColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        
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
        
        self.addSubview(headerView)
        
        if let superview = self.superview {
            self.snp.makeConstraints { (make) in
                make.top.equalTo(superview.snp.top)
                make.left.equalTo(superview.snp.left)
                make.right.equalTo(superview.snp.right)
                make.bottom.equalTo(superview.snp.bottom)
            }
        }
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(super.snp.top)
            make.left.equalTo(super.snp.left)
            make.right.equalTo(super.snp.right)
            make.height.equalTo(55)
        }
        friendTable.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.equalTo(super.snp.left)
            make.right.equalTo(super.snp.right)
            make.bottom.equalTo(super.snp.bottom)
        }
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

