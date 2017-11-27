//
//  PointCountView.swift
//  Dropin
//
//  Created by Christopher Pratt on 11/27/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class PointCountView: UIView {
    var starImageView: UIImageView!
    var starImage: UIImage!
    
    var pointLabel: UILabel!
    
    var size: CGFloat! = 14
    
    init() {
        super.init(frame: CGRect.zero)
        
        starImage = UIImage(named: "gold-star")!
        starImageView = UIImageView(image: starImage)
        self.addSubview(starImageView)
        
        pointLabel = UILabel()
        pointLabel.font = UIFont(name: pointLabel.font.fontName, size: size)
        self.addSubview(pointLabel)
        
        starImageView.snp.makeConstraints { (make) in
            make.right.equalTo(super.snp.right).offset(-25)
            make.centerY.equalTo(pointLabel.snp.centerY)
            make.width.equalTo(size)
            make.height.equalTo(size)
        }
        pointLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(starImageView.snp.trailing).offset(5)
            make.centerY.equalTo(super.snp.centerY)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func setPoints(_ points: Int) {
        pointLabel.text = String(points)
    }
    
    func setSize(_ size: CGFloat) {
        self.size = size
    }
}
