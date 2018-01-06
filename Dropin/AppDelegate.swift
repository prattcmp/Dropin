//
//  AppDelegate.swift
//  Dropin
//
//  Created by Christopher Pratt on 8/13/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import UserNotifications
import AWSMobileClient
import AWSPinpoint
import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var launchScreen: String! = ""
    var pinpoint: AWSPinpoint?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions) // Facebook SDK
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let launchStoryboard : UIStoryboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        let launchViewController : UIViewController = launchStoryboard.instantiateViewController(withIdentifier: "Loading") as UIViewController
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = launchViewController
        self.window?.makeKeyAndVisible()
        
        incrementReviewLaunches()
        launchByAuthStatus(launchScreen)
        
        pinpoint = AWSPinpoint(configuration:
                AWSPinpointConfiguration.defaultPinpointConfiguration(launchOptions: launchOptions))

        return AWSMobileClient.sharedInstance().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
    }

    /* Start Facebook SDK stuff */
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return SDKApplicationDelegate.shared.application(application, open: url, options: options)
    }
    /* End Facebook SDK stuff */
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken token: Data) {
        
        let tokenString = token.reduce("", {$0 + String(format: "%02X", $1)})
        
        UserDefaults.standard.set(tokenString, forKey: "device_push_token")
        PushToken.add(token: tokenString, done: {_,_ in })
        
        pinpoint!.notificationManager.interceptDidRegisterForRemoteNotifications(
            withDeviceToken: token)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent: UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions)->()) {
        
        withCompletionHandler([.alert, .sound, .badge])
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler:
        @escaping (UIBackgroundFetchResult) -> Void) {
        
        pinpoint!.notificationManager.interceptDidReceiveRemoteNotification(
            userInfo, fetchCompletionHandler: completionHandler)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        inUseManager.stopUpdatingLocation()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }
        
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        AppEventsLogger.activate(application) // Facebook SDK log app open
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        inUseManager.stopUpdatingLocation()
    }


}

