//
//  MapSearchView.swift
//  
//
//  Created by Christopher Pratt on 11/20/17.
//

import Foundation
import UIKit
import SnapKit

class MapSearchView: UIView {
    var searchTable: UITableView!
    
    var headerCell: UITableViewCell!
    var addFriendCell: UITableViewCell!
    
    var headerView: UIView!
    let rowHeight: CGFloat = 50.0
    
    var searchTextField: UITextField!
    
    var backImage: UIImage!
    var backButton: UIButton!
    
    init() {
        super.init(frame: usableScreen.getFrame())
        
        searchTable = UITableView(frame: super.frame, style: .plain)
        searchTable.separatorInset = .zero
        searchTable.separatorStyle = .singleLine
        searchTable.rowHeight = rowHeight
        self.addSubview(searchTable)
        
        headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: headerHeight)
        headerView.backgroundColor = UIColor.gray
        
        searchTextField = UITextField()
        searchTextField.font = UIFont(name: searchTextField.font!.fontName, size: 18)
        searchTextField.backgroundColor = UIColor.clear
        searchTextField.textColor = UIColor.white
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Send to location...",
                                                                   attributes: [NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.8) ])
        headerView.addSubview(searchTextField)
        
        self.addSubview(headerView)
        
        backImage = UIImage(named: "back-arrow-white")
        backButton = UIButton(type: .custom)
        backButton.setImage(backImage, for: .normal)
        backButton.frame = CGRect(x: 0, y: 0, width: 50, height: 60)
        headerView.addSubview(backButton)
        
        if let superview = self.superview {
            self.snp.makeConstraints { (make) in
                make.top.equalTo(superview.snp.top)
                make.left.equalTo(superview.snp.left)
                make.right.equalTo(superview.snp.right)
                make.bottom.equalTo(superview.snp.bottom)
            }
        }
        searchTable.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.equalTo(super.snp.left)
            make.right.equalTo(super.snp.right)
            make.bottom.equalTo(super.snp.bottom)
        }
        searchTextField.snp.makeConstraints { (make) in
            make.top.equalTo(backButton.snp.top).offset(-3)
            make.bottom.equalTo(backButton.snp.bottom).offset(3)
            make.right.equalTo(headerView.snp.right).offset(-3)
            make.leading.equalTo(backButton.snp.trailing).offset(10)
        }
        backButton.snp.makeConstraints { (make) in
            make.size.lessThanOrEqualTo(CGSize(width: 50, height: 60))
            make.bottom.equalTo(headerView.snp.bottom).offset(-7)
            make.left.equalTo(headerView.snp.left)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
