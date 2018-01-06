//
//  SettingsView.swift
//  Dropin
//
//  Created by Christopher Pratt on 9/20/17.
//  Copyright © 2017 Christopher Pratt. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import SnapKit

class SettingsView: UIView {
    var settingsTable: UITableView!
    
    var userLocationCell: UITableViewCell!
    var userLocationSwitch: UISwitch!
    var logoutCell: UITableViewCell!
    
    var headerView: UIView!
    var backImage: UIImage!
    var backButton: UIButton!
    
    init() {
        super.init(frame: usableScreen.getFrame())
        
        settingsTable = UITableView()
        settingsTable.frame = super.frame
        settingsTable.separatorInset = .zero
        self.addSubview(settingsTable)
        
        userLocationCell = UITableViewCell()
        userLocationSwitch = UISwitch()
        userLocationCell.accessoryView = userLocationSwitch
        userLocationCell.textLabel!.text = "Auto Location Sharing"
        
        logoutCell = UITableViewCell()
        logoutCell.accessoryType = .disclosureIndicator
        logoutCell.textLabel!.text = "Logout"
        
        headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: headerHeight)
        headerView.backgroundColor = DropinColor.blue
        self.addSubview(headerView)
        
        backImage = UIImage(named: "back-arrow-white")
        backButton = UIButton(type: .custom)
        backButton.setImage(backImage, for: .normal)
        backButton.frame = CGRect(x: 0, y: 0, width: 200, height: 60)
        backButton.titleLabel!.font = UIFont(name: backButton.titleLabel!.font.fontName + "-bold", size: 18)
        backButton.titleLabel!.sizeToFit()
        headerView.addSubview(backButton)
        
        if let superview = self.superview {
            self.snp.makeConstraints { (make) in
                make.top.equalTo(superview.snp.top)
                make.left.equalTo(superview.snp.left)
                make.right.equalTo(superview.snp.right)
                make.bottom.equalTo(superview.snp.bottom)
            }
        }
        settingsTable.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.equalTo(super.snp.left)
            make.right.equalTo(super.snp.right)
            make.bottom.equalTo(super.snp.bottom)
        }
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(super.snp.top)
            make.left.equalTo(super.snp.left)
            make.right.equalTo(super.snp.right)
            make.height.equalTo(headerHeight)
        }
        backButton.snp.makeConstraints { (make) in
            make.size.lessThanOrEqualTo(CGSize(width: 200, height: 60))
            make.bottom.equalTo(headerView.snp.bottom).offset(-7)
            make.left.equalTo(headerView.snp.left).offset(10)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

