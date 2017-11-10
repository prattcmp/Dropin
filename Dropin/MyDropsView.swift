//
//  MyDropsView.swift
//  Dropin
//
//  Created by Christopher Pratt on 10/26/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit
import SnapKit

class MyDropsView: UIView {
    var dropTable: UITableView!
    
    var headerCell: UITableViewCell!
    
    var headerView: UIView!
    var headerLabel: UILabel!
    let rowHeight: CGFloat = 40.0
    
    var settingsImage: UIImage!
    var settingsButton: UIButton!
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        
        dropTable = UITableView(frame: super.frame, style: .plain)
        dropTable.separatorInset = .zero
        dropTable.separatorStyle = .singleLine
        dropTable.rowHeight = rowHeight
        self.addSubview(dropTable)
        
        headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 55)
        headerView.backgroundColor = UIColor(red: 24/255, green: 190/255, blue: 255/255, alpha: 1)
        
        headerLabel = UILabel()
        headerLabel.textColor = UIColor.white
        headerLabel.font = UIFont(name: "Adobe Gothic Std", size: headerLabel.font.pointSize)
        headerLabel.text = "Drops"
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        self.addSubview(headerView)
        
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(super.snp.top)
            make.left.equalTo(super.snp.left)
            make.right.equalTo(super.snp.right)
            make.height.equalTo(55)
        }
        dropTable.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.equalTo(super.snp.left)
            make.right.equalTo(super.snp.right)
            make.bottom.equalTo(super.snp.bottom)
        }
        headerLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(headerView.snp.bottom).offset(-7)
            make.left.equalTo(headerView.snp.left).offset(7)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
