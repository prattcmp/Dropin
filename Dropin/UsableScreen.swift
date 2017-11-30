//
//  UsableScreen.swift
//  Dropin
//
//  Created by Christopher Pratt on 11/30/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import Foundation
import UIKit

class usableScreen {
    static func getFrame() -> CGRect {
        return UIApplication.shared.keyWindow?.frame ?? UIScreen.main.bounds
    }
}
