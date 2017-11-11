//
//  MapView.swift
//  Dropin
//
//  Created by Christopher Pratt on 9/11/17.
//  Copyright © 2017 Christopher Pratt. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import SnapKit

class MapView: UIView {
    var map: MKMapView!

    var swipeZone: UIView!
    
    var centerImage: UIImage!
    var centerButton: UIButton!
    
    var toDropsImage: UIImage!
    var toDropsButton: UIButton!
    var toFriendsImage: UIImage!
    var toFriendsButton: UIButton!

    init() {
        super.init(frame: UIScreen.main.bounds)
        
        map = MKMapView()
        map.frame = super.frame
        map.mapType = MKMapType.hybrid
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.center = self.center
        self.addSubview(map)
        
        swipeZone = UIView()
        swipeZone.frame = super.frame
        self.addSubview(swipeZone)

        centerImage = UIImage(named: "crosshair")
        centerButton = UIButton(type: .custom)
        centerButton.setImage(centerImage, for: .normal)
        self.addSubview(centerButton)
        
        toDropsImage = UIImage(named: "nav-drop")
        toDropsButton = UIButton(type: .custom)
        toDropsButton.setImage(toDropsImage, for: .normal)
        swipeZone.addSubview(toDropsButton)
        
        toFriendsImage = UIImage(named: "nav-friends")
        toFriendsButton = UIButton(type: .custom)
        toFriendsButton.setImage(toFriendsImage, for: .normal)
        swipeZone.addSubview(toFriendsButton)
        
        if let superview = self.superview {
            self.snp.makeConstraints { (make) in
                make.top.equalTo(superview.snp.top)
                make.left.equalTo(superview.snp.left)
                make.right.equalTo(superview.snp.right)
                make.bottom.equalTo(superview.snp.bottom)
            }
        }
        centerButton.snp.makeConstraints { (make) in
            make.top.equalTo(super.snp.top).offset(20)
            make.left.equalTo(super.snp.left).offset(10)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        swipeZone.snp.makeConstraints { (make) in
            make.top.equalTo(toDropsButton.snp.top).offset(-30)
            make.bottom.equalTo(super.snp.bottom)
            make.left.equalTo(super.snp.left)
            make.right.equalTo(super.snp.right)
        }
        toDropsButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(super.snp.bottom).offset(-20)
            make.width.equalTo(23)
            make.height.equalTo(27)
            make.left.equalTo(super.snp.left).offset(25)
        }
        toFriendsButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(toDropsButton.snp.centerY)
            make.width.equalTo(40)
            make.height.equalTo(30)
            make.right.equalTo(super.snp.right).offset(-25)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

