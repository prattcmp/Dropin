//
//  DeviceType.swift
//  Dropin
//
//  Created by Christopher Pratt on 12/5/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit

extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
}
