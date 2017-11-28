//
//  DropinViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 9/22/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit
import MapKit

class DropinViewController: UIViewController, UIPageViewControllerDataSource, UIScrollViewDelegate, CLLocationManagerDelegate {
    var pages = [UIViewController]()
    
    var pageViewController: UIPageViewController!
    
    var myDropsViewController: MyDropsViewController!
    var mapViewController: MapViewController!
    var friendViewController: FriendViewController!
    
    var locManager: CLLocationManager!
    
    var launchScreen: String!
    
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
        
        self.locManager = CLLocationManager()
        self.locManager.delegate = self
        self.locManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locManager.requestWhenInUseAuthorization()
        self.locManager.startUpdatingLocation()
        
        myDropsViewController = MyDropsViewController()
        mapViewController = MapViewController()
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
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        scrollView.bounces = (scrollView.contentOffset.y > 100);
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
}
