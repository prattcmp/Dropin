//
//  DropAnnotationView.swift
//  Dropin
//
//  Created by Christopher Pratt on 1/2/18.
//  Copyright © 2018 Dropin. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class DropAnnotationView: MKAnnotationView
{
    var nameLabel: UILabel!
    var name: String!
    var created_at: Date!
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, name: String, created_at: Date, type: String) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.canShowCallout = false
        self.image = UIImage(named: type)!.alpha(0.9)
        
        self.name = name
        self.created_at = created_at
        
        nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.textColor = UIColor.white
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont(name: nameLabel.font.fontName + "-bold", size: 16)
        nameLabel.layer.shadowColor = UIColor.black.cgColor
        nameLabel.layer.shadowRadius = 2.0
        nameLabel.layer.shadowOpacity = 0.3
        nameLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        nameLabel.layer.masksToBounds = false
        nameLabel.sizeToFit()
        nameLabel.center.x = 0.5 * self.frame.size.width
        nameLabel.frame.origin.y = self.frame.size.height
        
        self.addSubview(nameLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(false, animated: animated)
        
        if(selected)
        {
            UIView.transition(with: nameLabel,
                              duration: 0.1,
                              options: .curveLinear,
                              animations: { [weak self] in
                                if let strongSelf = self {
                                    strongSelf.nameLabel.text = strongSelf.name + " - " + strongSelf.created_at.timeAgoSinceNow()
                                    strongSelf.nameLabel.sizeToFit()
                                    strongSelf.nameLabel.center.x = 0.5 * strongSelf.frame.size.width
                                }
                }, completion: nil)
        }
        else
        {
            UIView.transition(with: nameLabel,
                              duration: 0.1,
                              options: .curveLinear,
                              animations: { [weak self] in
                                if let strongSelf = self {
                                    strongSelf.nameLabel.text = strongSelf.name
                                    strongSelf.nameLabel.sizeToFit()
                                    strongSelf.nameLabel.center.x = 0.5 * strongSelf.frame.size.width
                                }
                }, completion: nil)
        }
    }
}
