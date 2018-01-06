//
//  AnnotationType.swift
//  Dropin
//
//  Created by Christopher Pratt on 11/6/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import Foundation
import MapKit

class TypedPointAnnotation: MKPointAnnotation {
    var id: Int! = 0
    var type: String! = "drop-green"
    var name: String! = ""
    var created_at: Date! = Date()
}
