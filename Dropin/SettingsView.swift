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
    
    var headerCell: UITableViewCell!
    var logoutCell: UITableViewCell!
    var headerView: UIView!
    var headerLabel: UILabel!
    var backImage: UIImage!
    var backButton: UIButton!
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        
        settingsTable = UITableView()
        settingsTable.frame = super.frame
        settingsTable.separatorInset = .zero
        settingsTable.sectionHeaderHeight = 45
        self.addSubview(settingsTable)
        
        logoutCell = UITableViewCell()
        logoutCell.accessoryType = .disclosureIndicator
        logoutCell.textLabel!.text = "Logout"
        
        headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45)
        headerView.backgroundColor = UIColor(red: 24/255, green: 190/255, blue: 255/255, alpha: 1)
        
        /*
        headerLabel = UILabel()
        headerLabel.textColor = UIColor.white
        headerLabel.font = UIFont(name: "Adobe Gothic Std", size: headerLabel.font.pointSize)
        headerLabel.text = "Settings"
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        */
        
        backImage = UIImage(named: "back-arrow-white")
        backButton = UIButton(type: .custom)
        backButton.setImage(backImage, for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        backButton.frame = CGRect(x: 0, y: 0, width: 50, height: 60)
        headerView.addSubview(backButton)
        
        /*
        headerLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(backButton.snp.centerY)
            make.leading.equalTo(backButton.snp.trailing).offset(7)
        }
        */
        if let superview = self.superview {
            self.snp.makeConstraints { (make) in
                make.top.equalTo(superview.snp.top)
                make.left.equalTo(superview.snp.left)
                make.right.equalTo(superview.snp.right)
                make.bottom.equalTo(superview.snp.bottom)
            }
        }
        backButton.snp.makeConstraints { (make) in
            make.size.lessThanOrEqualTo(CGSize(width: 50, height: 60))
            make.centerY.equalTo(headerView.snp.centerY)
            make.left.equalTo(headerView.snp.left).offset(10)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

