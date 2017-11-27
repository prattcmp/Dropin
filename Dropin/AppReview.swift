//
//  AppReview.swift
//  Dropin
//
//  Created by Christopher Pratt on 11/27/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import StoreKit

let minLaunchesForReview = 3

func incrementLaunches() {
    var launches = UserDefaults().value(forKey: "launchesSinceReviewPopup") as? Int ?? 0
    
    launches += 1
    
    UserDefaults().setValuesForKeys(["launchesSinceReviewPopup": launches as Any])
    UserDefaults().synchronize()
}

func showReview() {
    let launches = UserDefaults().value(forKey: "launchesSinceReviewPopup") as? Int ?? 0
    
    if (launches > minLaunchesForReview) {
        UserDefaults().setValuesForKeys(["launchesSinceReviewPopup": 0])
        UserDefaults().synchronize()
        
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
}


