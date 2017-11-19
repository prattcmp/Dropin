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
    
    var getDirectionsImage: UIImage!
    var getDirectionsButton: UIButton!
    
    var textLabel: UILabel!
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        
        map = MKMapView()
        map.frame = super.frame
        map.mapType = MKMapType.hybrid
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.center = self.center
        self.addSubview(map)
        
        detailZone = UIView()
        detailZone.frame = super.frame
        detailZone.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        self.addSubview(detailZone)
        
        backImage = UIImage(named: "back-arrow-white")
        backButton = UIButton(type: .custom)
        backButton.setImage(backImage, for: .normal)
        backButton.frame = CGRect(x: 0, y: 0, width: 200, height: 60)
        backButton.titleLabel!.font = UIFont(name: backButton.titleLabel!.font.fontName + "-bold", size: 18)
        backButton.titleLabel!.sizeToFit()
        backButton.titleLabel!.isUserInteractionEnabled = false
        backButton.titleLabel!.isExclusiveTouch = false
        backButton.titleLabel!.layer.shadowColor = UIColor.black.cgColor
        backButton.titleLabel!.layer.shadowRadius = 2.0
        backButton.titleLabel!.layer.shadowOpacity = 0.3
        backButton.titleLabel!.layer.shadowOffset = CGSize(width: 0, height: 1)
        backButton.titleLabel!.layer.masksToBounds = false
        self.addSubview(backButton)

        timeLabel = UILabel()
        timeLabel.font = UIFont(name: timeLabel.font.fontName, size: 14)
        timeLabel.textColor = .white
        timeLabel.layer.shadowColor = UIColor.black.cgColor
        timeLabel.layer.shadowRadius = 2.0
        timeLabel.layer.shadowOpacity = 0.3
        timeLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        timeLabel.layer.masksToBounds = false
        self.addSubview(timeLabel)
        
        textLabel = UILabel()
        textLabel.font = UIFont(name: textLabel.font.fontName, size: 16)
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        detailZone.addSubview(textLabel)
        
        getDirectionsImage = UIImage(named: "get-directions-button")
        getDirectionsButton = UIButton(type: .custom)
        getDirectionsButton.setImage(getDirectionsImage, for: .normal)
        /*
        getDirectionsButton.setTitle("Get Directions", for: .normal)
        getDirectionsButton.setTitleColor(.black, for: .normal)
        getDirectionsButton.titleLabel!.font =  UIFont(name: getDirectionsButton.titleLabel!.font.fontName, size: 14)
        getDirectionsButton.titleLabel!.alpha = 0.5
        getDirectionsButton.backgroundColor = .clear
        getDirectionsButton.layer.cornerRadius = 5
        getDirectionsButton.layer.borderWidth = 1
        getDirectionsButton.layer.borderColor = UIColor.lightGray.cgColor
        */
        self.addSubview(getDirectionsButton)
        
        if let superview = self.superview {
            self.snp.makeConstraints { (make) in
                make.top.equalTo(superview.snp.top)
                make.left.equalTo(superview.snp.left)
                make.right.equalTo(superview.snp.right)
                make.bottom.equalTo(superview.snp.bottom)
            }
        }
        backButton.snp.makeConstraints { (make) in
            make.size.lessThanOrEqualTo(CGSize(width: 200, height: 60))
            make.top.equalTo(super.snp.top).offset(25)
            make.left.equalTo(super.snp.left).offset(10)
        }
        map.snp.makeConstraints { (make) in
            make.top.equalTo(super.snp.top)
            make.left.equalTo(super.snp.left)
            make.right.equalTo(super.snp.right)
            make.bottom.equalTo(super.snp.bottom)
        }
        detailZone.snp.makeConstraints { (make) in
            make.bottom.equalTo(super.snp.bottom)
            make.left.equalTo(super.snp.left)
            make.right.equalTo(super.snp.right)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(backButton.snp.centerY)
            make.right.equalTo(super.snp.right).offset(-7)
        }
        textLabel.snp.makeConstraints { (make) in
            make.top.equalTo(detailZone.snp.top).offset(10)
            make.left.greaterThanOrEqualTo(super.snp.left).offset(7)
            make.right.lessThanOrEqualTo(super.snp.right).offset(-7)
            make.centerX.equalTo(super.snp.centerX)
            make.bottom.equalTo(detailZone.snp.bottom).offset(-10)
        }
        getDirectionsButton.snp.makeConstraints { (make) in
            make.size.lessThanOrEqualTo(CGSize(width: 40, height: 40))
            make.right.equalTo(super.snp.right).offset(-7)
            make.top.equalTo(timeLabel.snp.bottom).offset(10)
        }
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
