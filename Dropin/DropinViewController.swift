//
//  DropinViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 9/22/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit
import MapKit
import PMAlertController

class DropinViewController: UIViewController, UIPageViewControllerDataSource, UIScrollViewDelegate, CLLocationManagerDelegate {
    var pages = [UIViewController]()
    
    var pageViewController: UIPageViewController!
    
    var myDropsViewController: MyDropsViewController!
    var mapViewController: MapViewController!
    var friendViewController: FriendViewController!
    
    var launchScreen: String!
    
    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    
    init(_ launchScreen: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.launchScreen = launchScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        navController.isNavigationBarHidden = true
        
        significantUpdateManager.delegate = self
        significantUpdateManager.allowsBackgroundLocationUpdates = true
        UserLocation.getEnabled() { (isSuccess, message, enabled) in
            if (isSuccess) {
                if enabled {
                    significantUpdateManager.startMonitoringSignificantLocationChanges()
                } else {
                    significantUpdateManager.stopMonitoringSignificantLocationChanges()
                }
            }
        }
        
        inUseManager.allowsBackgroundLocationUpdates = false
        inUseManager.desiredAccuracy = kCLLocationAccuracyBest
        inUseManager.startUpdatingLocation()
        
        mapViewController = MapViewController()
        myDropsViewController = MyDropsViewController(mapViewController: mapViewController)
        friendViewController = FriendViewController()
        
        self.pages.append(myDropsViewController)
        self.pages.append(mapViewController)
        self.pages.append(friendViewController)

        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController.dataSource = self
        self.setStartingPageController()
        self.addChildViewController(self.pageViewController)

        self.view.addSubview(self.pageViewController.view)

        self.pageViewController.didMove(toParentViewController: self)
        self.automaticallyAdjustsScrollViewInsets = false
        
        mapViewController.mapView?.toDropsButton?.addTarget(self, action: #selector(showDropsPage), for: .touchUpInside)
        mapViewController.mapView?.toFriendsButton?.addTarget(self, action: #selector(showFriendsPage), for: .touchUpInside)
        
        newUserHelpers()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        scrollView.bounces = (scrollView.contentOffset.y > 100);
    }
    
    func newUserHelpers() {
        let locationSharingWalkthroughDisplayed = UserDefaults().value(forKey: "locationSharingWalkthroughDisplayed") as? Bool ?? false
        let playAroundDisplayed = UserDefaults().value(forKey: "playAroundDisplayed") as? Bool ?? false
        
        if locationSharingWalkthroughDisplayed == false {
            let storyboard: UIStoryboard = UIStoryboard(name: "NewUserWalkthrough", bundle: nil)
            let walkthroughController = storyboard.instantiateViewController(withIdentifier: "LocationSharing1")
            navController.pushViewController(walkthroughController, animated: false)
            
            UserDefaults().setValuesForKeys(["locationSharingWalkthroughDisplayed": true as Any])
        } else if currentUser.friends.count == 0 {
            let alertVC = PMAlertController(title: "Add friends", description: "To start sending drops, you have to add some friends.", image: nil, style: .walkthrough)
            
            alertVC.addAction(PMAlertAction(title: "Okay", style: .default, action: { () in
                self.showFriendsPage()
            }))
            
            self.present(alertVC, animated: true, completion: nil)
        } else if playAroundDisplayed == false {
            let alertVC = PMAlertController(title: "Play around", description: "Press some buttons and play around. Don't worry, you won't break anything (hopefully 🙄)!", image: nil, style: .walkthrough)
            
            alertVC.addAction(PMAlertAction(title: "Okay", style: .default, action: nil))
            
            self.present(alertVC, animated: true, completion: nil)
            UserDefaults().setValuesForKeys(["playAroundDisplayed": true as Any])
        }
    }
    
    func setStartingPageController() {
        if self.launchScreen == "friends" {
            self.showFriendsPage()
        } else if self.launchScreen == "drops" {
            self.showDropsPage()
        } else {
            self.resetPageController(sender: self)
        }
    }
    
    @objc func showDropsPage() {
        let index = self.pages.index(of: myDropsViewController)!
        self.pageViewController.setViewControllers([self.pages[index]], direction: .reverse, animated: true, completion: nil)
    }
    
    @objc func showFriendsPage() {
        let index = self.pages.index(of: friendViewController)!
        self.pageViewController.setViewControllers([self.pages[index]], direction: .forward, animated: true, completion: nil)
    }
    
    func resetPageController(sender: AnyObject) {
        let index = self.pages.index(of: mapViewController)!
        self.pageViewController.setViewControllers([self.pages[index]], direction: .forward, animated: true, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = self.pages.index(of: viewController)!
        
        if (index == 0 || index == NSNotFound) {
            return nil
        }

        return self.pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.pages.index(of: viewController)!
        
        if (index == NSNotFound) {
            return nil
        }
        if (index == (self.pages.count - 1)) {
            return nil
        }

        return self.pages[index + 1]
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        var lastLocation = locations.last!
        
        inUseManager.startUpdatingLocation()
        if inUseManager.location != nil {
            lastLocation = inUseManager.location!
        }
        inUseManager.stopUpdatingLocation()
        
        // Get the background identifier if the app is in background mode
        if UIApplication.shared.applicationState == .background {
            backgroundUpdateTask = UIApplication.shared.beginBackgroundTask { [weak self] in
                if let strongSelf = self {
                    UIApplication.shared.endBackgroundTask(strongSelf.backgroundUpdateTask)
                    strongSelf.backgroundUpdateTask = UIBackgroundTaskInvalid
                }
            }
        }
        
        // Call the api to update the location to your server
        UserLocation.update(coordinates: lastLocation.coordinate) { (_ isSuccess: Bool, _ message: String)
            in
            
            //API completion block invalidate the identifier if it is not invalid already.
            if self.backgroundUpdateTask != nil && self.backgroundUpdateTask != UIBackgroundTaskInvalid {
                UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
                self.backgroundUpdateTask = UIBackgroundTaskInvalid
            }
        }
    }
}
