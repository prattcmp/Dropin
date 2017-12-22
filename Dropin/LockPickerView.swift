//
//  LockPickerView.swift
//  Dropin
//
//  Created by Christopher Pratt on 12/21/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import Foundation

//
//  MapSearchView.swift
//
//
//  Created by Christopher Pratt on 11/20/17.
//

import Foundation
import UIKit
import SnapKit

class LockPickerView: UIView {
    var pickerView: UIPickerView!
    
    var backImage: UIImage!
    var backButton: UIButton!
    
    init() {
        super.init(frame: usableScreen.getFrame())

        self.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        pickerView = UIPickerView()
        self.addSubview(pickerView)
        
        backImage = UIImage(named: "back-arrow-white")
        backButton = UIButton(type: .custom)
        backButton.setImage(backImage, for: .normal)
        backButton.frame = CGRect(x: 0, y: 0, width: 50, height: 60)
        self.addSubview(backButton)
        
        backButton.snp.makeConstraints { (make) in
            make.size.lessThanOrEqualTo(CGSize(width: 50, height: 60))
            make.top.equalTo(super.snp.top).offset(35)
            make.left.equalTo(super.snp.left).offset(10)
        }
        
        if let superview = self.superview {
            self.snp.makeConstraints { (make) in
                make.top.equalTo(superview.snp.top)
                make.left.equalTo(superview.snp.left)
                make.right.equalTo(superview.snp.right)
                make.bottom.equalTo(superview.snp.bottom)
            }
        }
        pickerView.snp.makeConstraints { (make) in
            make.centerY.equalTo(super.snp.centerY)
            make.left.equalTo(super.snp.left)
            make.right.equalTo(super.snp.right)
            make.height.equalTo(super.snp.height).multipliedBy(0.25)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
