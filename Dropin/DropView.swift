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
    
    var toMapsButton: UIButton!
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
        detailZone.backgroundColor = .white
        self.addSubview(detailZone)
        
        nameLabel = UILabel()
        nameLabel.font = UIFont(name: nameLabel.font.fontName + "-bold", size: 14)
        nameLabel.sizeToFit()
        detailZone.addSubview(nameLabel)

        backImage = UIImage(named: "back-arrow-white")
        backButton = UIButton(type: .custom)
        backButton.setImage(backImage, for: .normal)
        backButton.frame = CGRect(x: 0, y: 0, width: 50, height: 60)
        self.addSubview(backButton)
        
        timeLabel = UILabel()
        timeLabel.font = UIFont(name: timeLabel.font.fontName, size: 12)
        timeLabel.alpha = 0.5
        nameLabel.sizeToFit()
        detailZone.addSubview(timeLabel)
        
        textLabel = UILabel()
        textLabel.font = UIFont(name: textLabel.font.fontName, size: 14)
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        detailZone.addSubview(textLabel)
        
        toMapsButton = UIButton(type: .system)
        toMapsButton.setTitle("Get Directions", for: .normal)
        toMapsButton.setTitleColor(.black, for: .normal)
        toMapsButton.titleLabel!.font =  UIFont(name: toMapsButton.titleLabel!.font.fontName, size: 14)
        toMapsButton.titleLabel!.alpha = 0.5
        toMapsButton.backgroundColor = .clear
        toMapsButton.layer.cornerRadius = 5
        toMapsButton.layer.borderWidth = 1
        toMapsButton.layer.borderColor = UIColor.lightGray.cgColor
        detailZone.addSubview(toMapsButton)
        
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
            make.bottom.equalTo(super.snp.bottom)
            make.left.equalTo(super.snp.left)
            make.right.equalTo(super.snp.right)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(detailZone.snp.top).offset(5)
            make.left.equalTo(super.snp.left).offset(7)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.topMargin.equalTo(nameLabel.snp.topMargin)
            make.right.equalTo(super.snp.right).offset(-7)
        }
        textLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.left.equalTo(super.snp.left).offset(7)
            make.right.equalTo(super.snp.right).offset(-7)
        }
        toMapsButton.snp.makeConstraints { (make) in
            make.top.equalTo(textLabel.snp.bottom).offset(15)
            make.left.equalTo(super.snp.left).offset(7)
            make.width.equalTo(super.snp.width).multipliedBy(0.33)
            make.bottom.equalTo(super.snp.bottom).offset(-10)
        }
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
