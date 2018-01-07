//
//  UserWalkthroughViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 1/6/18.
//  Copyright © 2018 Dropin. All rights reserved.
//

import UIKit

class LocationSharingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func startSharingButtonPressed(_ sender: UIButton) {
        significantUpdateManager.requestAlwaysAuthorization()
        
        UserLocation.setEnabled(true) { (isSuccess, message) in
            if (!isSuccess) {
                let alertController = UIAlertController(title: "Uh oh", message: message != "" ? message : "Something went wrong. Please try again in Settings.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
            
            let storyboard: UIStoryboard = UIStoryboard(name: "NewUserWalkthrough", bundle: nil)
            
            let nextViewController = storyboard.instantiateViewController(withIdentifier: "LocationSharing3")
            navController.pushViewController(nextViewController, animated: true)
        }
    }
}
