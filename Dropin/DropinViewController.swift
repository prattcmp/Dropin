//
//  DropinViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 9/22/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit

class DropinViewController: UIViewController, UIPageViewControllerDataSource, UIScrollViewDelegate {
    var pages = [UIViewController]()
    
    var pageViewController: UIPageViewController!
    
    var myDropsViewController: MyDropsViewController!
    var mapViewController: MapViewController!
    var friendViewController: FriendViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        navController.isNavigationBarHidden = true
        
        myDropsViewController = MyDropsViewController()
        mapViewController = MapViewController()
        friendViewController = FriendViewController()
        
        self.pages.append(myDropsViewController)
        self.pages.append(mapViewController)
        self.pages.append(friendViewController)

        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController.dataSource = self
        self.resetPageController(sender: self)
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
    
    func showDropsPage() {
        let index = self.pages.index(of: myDropsViewController)!
        self.pageViewController.setViewControllers([self.pages[index]], direction: .reverse, animated: true, completion: nil)
    }
    
    func showFriendsPage() {
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
