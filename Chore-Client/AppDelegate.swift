//
//  AppDelegate.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/6/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
         IQKeyboardManager.sharedManager().enable = true
        
        // check notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (permitionGranted, error) in
            
            // generate notification if condition meet
            Notification.generateNotification()
        }
        
        
        IQKeyboardManager.sharedManager().enable = true
        
        
//        let cancel = UNNotificationAction(identifier: "return", title: "Return", options: [.foreground])
//        let completed = UNNotificationAction(identifier: "completed", title: "Completed", options: [.foreground])
//        let choreNotification = UNNotificationCategory(identifier: "choreNotification", actions: [cancel,completed], intentIdentifiers: [], options: [])
//        UNUserNotificationCenter.current().setNotificationCategories([choreNotification])

        // Override point for customization after application launch.
        let userLoginStatus = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        if(userLoginStatus)
        {
            
            let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let rootController = mainStoryBoard.instantiateViewController(withIdentifier: "MainTab") 
            
            // Because self.window is an optional you should check it's value first and assign your rootViewController
            if let window = self.window {
                window.rootViewController = rootController
            }
            
            window?.makeKeyAndVisible()
            
            
        }
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

extension AppDelegate: UNUserNotificationCenterDelegate{
//
//     func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                         didReceive response: UNNotificationResponse,
//                                         withCompletionHandler completionHandler: @escaping () -> Void){
//
//        if response.actionIdentifier == "completed"{
//            Network.instance
//        }
//    }
}
