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
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, name: String, type: String) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.canShowCallout = false
        self.image = UIImage(named: type)!.alpha(0.9)
        
        self.name = name
        
        nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.textColor = UIColor.white
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont(name: nameLabel.font.fontName + "-bold", size: 14)
        nameLabel.sizeToFit()
        nameLabel.center.x = 0.5 * self.frame.size.width
        nameLabel.frame.origin.y = self.frame.size.height
        
        self.addSubview(nameLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
