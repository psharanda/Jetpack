//
//  AppDelegate.swift
//  Demo
//
//  Created by Pavel Sharanda on 11.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import UIKit

#if swift(>=4.2)
typealias ApplicationLaunchOptionsKey = UIApplication.LaunchOptionsKey
#else
typealias ApplicationLaunchOptionsKey = UIApplicationLaunchOptionsKey
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var w: UIWindow = UIWindow(frame: UIScreen.main.bounds)
    
    let m = ListModel()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [ApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
    
        
        
        let vm = ListViewModel(model: m)
        let vc = ListViewController(viewModel: vm)
        
        w.rootViewController = UINavigationController(rootViewController: vc)
        w.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

