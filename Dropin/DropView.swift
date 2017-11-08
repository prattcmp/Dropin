//
//  DropView.swift
//  Dropin
//
//  Created by Christopher Pratt on 10/28/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import MapKit
import SnapKit

class DropView: UIView {
    var map: MKMapView!
    
    var detailZone: UIView!
    
    var backImage: UIImage!
    var backButton: UIButton!
    
    var nameLabel: UILabel!
    var timeLabel: UILabel!
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        
        map = MKMapView()
        map.frame = super.frame
        map.mapType = MKMapType.satellite
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.center = self.center
        self.addSubview(map)
        
        detailZone = UIView()
        detailZone.frame = super.frame
        detailZone.backgroundColor = .white
        self.addSubview(detailZone)
        
        nameLabel = UILabel()
        detailZone.addSubview(nameLabel)

        backImage = UIImage(named: "back-arrow-white")
        backButton = UIButton(type: .custom)
        backButton.setImage(backImage, for: .normal)
        backButton.frame = CGRect(x: 0, y: 0, width: 50, height: 60)
        self.addSubview(backButton)
        
        timeLabel = UILabel()
        timeLabel.font = UIFont(name: timeLabel.font.fontName, size: 12)
        detailZone.addSubview(timeLabel)
        
        backButton.snp.makeConstraints { (make) in
            make.size.lessThanOrEqualTo(CGSize(width: 50, height: 60))
            make.top.equalTo(super.snp.top).offset(25)
            make.left.equalTo(super.snp.left).offset(10)
        }
        map.snp.makeConstraints { (make) in
            make.top.equalTo(super.snp.top)
            make.left.equalTo(super.snp.left)
            make.right.equalTo(super.snp.right)
            make.bottom.equalTo(detailZone.snp.top)
        }
        detailZone.snp.makeConstraints { (make) in
            make.height.equalTo(map.snp.height).multipliedBy(0.1)
            make.bottom.equalTo(super.snp.bottom)
            make.left.equalTo(super.snp.left)
            make.right.equalTo(super.snp.right)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(detailZone.snp.top).offset(7)
            make.left.equalTo(super.snp.left).offset(5)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.topMargin.equalTo(nameLabel.snp.topMargin)
            make.right.equalTo(super.snp.right).offset(-5)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
