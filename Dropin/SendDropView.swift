//
//  SendDropView.swift
//  Dropin
//
//  Created by Christopher Pratt on 10/12/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class SendDropView: UIView {
    var friendTable: UITableView!
    
    var headerCell: UITableViewCell!
    var addFriendCell: UITableViewCell!
    
    var headerView: UIView!
    let rowHeight: CGFloat = 50.0
    
    var backImage: UIImage!
    var backButton: UIButton!
    
    var sendImage: UIImage!
    var sendButton: UIButton!
    
    var dropButtonTopConstraint: Constraint? = nil
    var dropButtonBottomConstraint: Constraint? = nil
    
    init() {
        super.init(frame: usableScreen.getFrame())
        
        friendTable = UITableView(frame: super.frame, style: .grouped)
        friendTable.separatorInset = .zero
        friendTable.sectionHeaderHeight = headerHeight
        friendTable.separatorStyle = .singleLine
        friendTable.rowHeight = rowHeight
        self.addSubview(friendTable)

        headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: headerHeight)
        headerView.backgroundColor = DropinColor.blue
        
        backImage = UIImage(named: "back-arrow-white")
        backButton = UIButton(type: .custom)
        backButton.setImage(backImage, for: .normal)
        backButton.frame = CGRect(x: 0, y: 0, width: 200, height: 60)
        backButton.titleLabel!.font = UIFont(name: backButton.titleLabel!.font.fontName + "-bold", size: 18)
        backButton.titleLabel!.sizeToFit()
        headerView.addSubview(backButton)
        
        sendImage = UIImage(named: "send-button-background")
        sendButton = UIButton(type: .custom)
        sendButton.setBackgroundImage(sendImage, for: .normal)
        sendButton.setTitle("send", for: .normal)
        sendButton.titleLabel?.font = UIFont(name: "Adobe Gothic Std", size: 32.0)
        sendButton.layer.borderWidth = 0.0
        self.addSubview(sendButton)
        
        if let superview = self.superview {
            self.snp.makeConstraints { (make) in
                make.top.equalTo(superview.snp.top)
                make.left.equalTo(superview.snp.left)
                make.right.equalTo(superview.snp.right)
                make.bottom.equalTo(superview.snp.bottom)
            }
        }
        friendTable.snp.makeConstraints { (make) in
            make.top.equalTo(super.snp.top)
            make.left.equalTo(super.snp.left)
            make.right.equalTo(super.snp.right)
            make.bottom.equalTo(sendButton.snp.top)
        }
        backButton.snp.makeConstraints { (make) in
            make.size.lessThanOrEqualTo(CGSize(width: 200, height: 60))
            make.bottom.equalTo(headerView.snp.bottom).offset(-7)
            make.left.equalTo(headerView.snp.left).offset(10)
        }
        sendButton.snp.makeConstraints { (make) in
            make.left.equalTo(super.snp.left)
            make.right.equalTo(super.snp.right)
            make.centerX.equalTo(super.snp.centerX)
            if UIDevice.current.iPhoneX {
                make.height.greaterThanOrEqualTo(75)
            }
            self.dropButtonTopConstraint = make.top.equalTo(super.snp.bottom).constraint
            self.dropButtonBottomConstraint = make.bottom.equalTo(super.snp.bottom).constraint
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func showSendButton() {
        self.dropButtonTopConstraint?.deactivate()
        self.dropButtonBottomConstraint?.activate()
    }
    
    func hideSendButton() {
        dropButtonTopConstraint?.activate()
        dropButtonBottomConstraint?.deactivate()
    }
}

