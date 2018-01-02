//
//  AppReview.swift
//  Dropin
//
//  Created by Christopher Pratt on 11/27/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import StoreKit

let minLaunchesForReview = 3

func incrementReviewLaunches() {
    var totalLaunches = UserDefaults().value(forKey: "totalLaunches") as? Int ?? 0
    var reviewLaunches = UserDefaults().value(forKey: "launchesSinceReviewPopup") as? Int ?? 0
    
    totalLaunches += 1
    reviewLaunches += 1

    UserDefaults().setValuesForKeys(["launchesSinceReviewPopup": reviewLaunches as Any, "totalLaunches": totalLaunches as Any])
    UserDefaults().synchronize()
}

func showReviewPopup() {
    let launches = UserDefaults().value(forKey: "launchesSinceReviewPopup") as? Int ?? 0
    
    if (launches > minLaunchesForReview) {
        UserDefaults().setValuesForKeys(["launchesSinceReviewPopup": 0])
        UserDefaults().synchronize()
        
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
}


