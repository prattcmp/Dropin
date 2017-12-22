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
    
    var searchImage: UIImage!
    var searchButton: UIButton!
    
    var lockImage: UIImage!
    var lockButton: UIButton!
    
    var sendDropView: UIImageView!
    var sendDropRing: UIImage!
    
    var sendDropImage: UIImage!
    var sendDropButton: UIButton!
    
    var toDropsImage: UIImage!
    var toDropsButton: UIButton!
    var toFriendsImage: UIImage!
    var toFriendsButton: UIButton!
    
    var textField: UITextView!

    init() {
        super.init(frame: usableScreen.getFrame())
        
        map = MKMapView()
        map.frame = super.frame
        map.mapType = MKMapType.hybrid
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.showsCompass = false
        map.center = self.center
        self.addSubview(map)
        
        centerImage = UIImage(named: "crosshair")
        centerButton = UIButton(type: .custom)
        centerButton.setImage(centerImage, for: .normal)
        self.addSubview(centerButton)
        
        searchImage = UIImage(named: "glass-searcher")
        searchButton = UIButton(type: .custom)
        searchButton.setImage(searchImage, for: .normal)
        self.addSubview(searchButton)
        
        lockImage = UIImage(named: "lock")
        lockButton = UIButton(type: .custom)
        lockButton.setImage(lockImage, for: .normal)
        self.addSubview(lockButton)
        
        sendDropRing = UIImage(named: "send-drop-ring")!
        sendDropView = UIImageView(image: sendDropRing)
        self.addSubview(sendDropView)
        
        swipeZone = UIView()
        swipeZone.frame = super.frame
        self.addSubview(swipeZone)
        
        toDropsImage = UIImage(named: "nav-drop")
        toDropsButton = UIButton(type: .custom)
        toDropsButton.setImage(toDropsImage, for: .normal)
        swipeZone.addSubview(toDropsButton)
        
        sendDropImage = UIImage(named: "send-drop-button")
        sendDropButton = UIButton(type: .custom)
        sendDropButton.setImage(sendDropImage, for: .normal)
        swipeZone.addSubview(sendDropButton)
        
        toFriendsImage = UIImage(named: "nav-friends")
        toFriendsButton = UIButton(type: .custom)
        toFriendsButton.setImage(toFriendsImage, for: .normal)
        swipeZone.addSubview(toFriendsButton)
        
        textField = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        textField.font = .systemFont(ofSize: 16)
        textField.backgroundColor = .white
        textField.autocorrectionType = .no
        textField.keyboardType = .default
        textField.textContainer.lineBreakMode = .byWordWrapping
        textField.textContainerInset = UIEdgeInsetsMake(5,3,5,3);
        textField.isScrollEnabled = false
        textField.returnKeyType = .send
        textField.isHidden = true
        self.addSubview(textField)
        
        if let superview = self.superview {
            self.snp.makeConstraints { (make) in
                make.top.equalTo(superview.snp.top)
                make.left.equalTo(superview.snp.left)
                make.right.equalTo(superview.snp.right)
                make.bottom.equalTo(superview.snp.bottom)
            }
        }
        sendDropView.snp.makeConstraints { (make) in
            make.centerX.equalTo(super.snp.centerX)
            make.centerY.equalTo(super.snp.centerY)
        }
        centerButton.snp.makeConstraints { (make) in
            if UIDevice.current.iPhoneX {
                make.top.equalTo(super.snp.top).offset(35)
            } else {
                make.top.equalTo(super.snp.top).offset(25)
            }
            make.left.equalTo(super.snp.left).offset(10)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        searchButton.snp.makeConstraints { (make) in
            make.top.equalTo(centerButton.snp.top)
            make.leading.equalTo(centerButton.snp.trailing).offset(20)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        lockButton.snp.makeConstraints { (make) in
            make.top.equalTo(centerButton.snp.top)
            make.right.equalTo(super.snp.right).offset(-10)
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
            make.centerY.equalTo(sendDropButton.snp.centerY).offset(15)
            make.width.equalTo(25)
            make.height.equalTo(25)
            make.left.equalTo(super.snp.left).offset(25)
        }
        sendDropButton.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.bottom.equalTo(super.snp.bottom).offset(-30)
            make.centerX.equalTo(super.snp.centerX)
        }
        toFriendsButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(sendDropButton.snp.centerY).offset(15)
            make.width.equalTo(25)
            make.height.equalTo(25)
            make.right.equalTo(super.snp.right).offset(-25)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func showMapIcons() {
        centerButton.isHidden = false
        searchButton.isHidden = false
        lockButton.isHidden = false
        sendDropView.isHidden = false
        sendDropButton.isHidden = false
        toDropsButton.isHidden = false
        toFriendsButton.isHidden = false
    }
    
    func hideMapIcons() {
        centerButton.isHidden = true
        searchButton.isHidden = true
        lockButton.isHidden = true
        sendDropView.isHidden = true
        sendDropButton.isHidden = true
        toDropsButton.isHidden = true
        toFriendsButton.isHidden = true
    }
    
    func shrinkSendDropRing() {
        UIView.animate(withDuration: 0.4, animations: {() -> Void in
            self.sendDropView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        })
    }
    
    func resetSendDropRing() {
        UIView.animate(withDuration: 0.1, animations: {() -> Void in
            self.sendDropView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func growShrinkSendDropRing() {
        UIView.animate(withDuration: 0.1, animations: {() -> Void in
            self.sendDropView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: 0.25, animations: {() -> Void in
                self.sendDropView.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        })
    }
}

