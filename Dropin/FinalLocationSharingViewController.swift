//
//  FinalLocationSharingViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 1/6/18.
//  Copyright © 2018 Dropin. All rights reserved.
//

import UIKit
import UserNotifications

class FinalLocationSharingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func doubleTapPerformed(_ sender: UITapGestureRecognizer) {
        navController.popToRootViewController(animated: true)
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }
}
