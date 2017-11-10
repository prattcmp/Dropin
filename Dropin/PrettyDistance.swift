//
//  PrettyDistance.swift
//  Dropin
//
//  Created by Christopher Pratt on 11/9/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import Foundation
import MapKit

extension CLLocationDistance {
    func toPrettyDistance() -> String {
        let distanceInMeters = Measurement(value: self, unit: UnitLength.meters)
        
        let distanceInMiles = distanceInMeters.converted(to: UnitLength.miles)
        
        if distanceInMiles.value > 0.5 {
            if distanceInMiles.value == 1.0 {
                return (String(format:"%.0f", distanceInMiles.value) + " mile")
            } else if distanceInMiles.value < 10 {
                return (String(format:"%.1f", distanceInMiles.value) + " miles")
            } else {
                return (String(format:"%.0f", distanceInMiles.value) + " miles")
            }
        } else {
            let distanceInFeet = distanceInMiles.converted(to: UnitLength.feet)
            
            if distanceInFeet.value == 1.0 {
                return (String(format:"%.0f", distanceInFeet.value) + " foot")
            } else {
                return (String(format:"%.0f", distanceInFeet.value) + " feet")
            }
        }
    }
}
