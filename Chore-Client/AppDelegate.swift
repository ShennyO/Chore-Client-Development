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
import KeychainSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var center = UNUserNotificationCenter.current()
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        center.delegate = self
        center.removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        UINavigationBar.appearance().tintColor = UIColor.black
        let offset = UIOffset(horizontal: -300, vertical: 0)
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(offset, for: .default)
//
//        UINavigationBar.appearance().prefersLargeTitles = true
//        UINavigationBar.appearance().largeTitleTextAttributes =
//            [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 35, weight: UIFont.Weight.black)]

        
        IQKeyboardManager.sharedManager().enable = true
//        UIApplication.shared.statusBarStyle = .default
//        let navigationBarAppearance = UINavigationBar.appearance()
        
//        navigationBarAppearance.isTranslucent = false
//        navigationBarAppearance.barTintColor = UIColor(rgb: 0xFFB131)
        
        
//        navigationBarAppearance.tintColor = UIColor.white
        
//        navigationBarAppearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
            //Change status bar color
//            UIApplication.shared.statusBarStyle = .lightContent
        
        // check notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (permitionGranted, error) in
            
            // generate notification if condition meet
            Notification.generateNotification()
        }
        
        
        IQKeyboardManager.sharedManager().enable = true
        

        // Override point for customization after application launch.
        let userLoginStatus = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        if(userLoginStatus)
        {
            let username:String = KeychainSwift().get("username")!
            let token: String = KeychainSwift().get("token")!
            Network.instance.fetch(route: .getUser(username: username), completion: { (data, resp) in

                
            

                DispatchQueue.main.async {
                    if let user = try? JSONDecoder().decode(User.self, from: data){
                        if user.authentication_token != token {
                            
                            let alert = UIAlertController(title: "Log Out", message: "you have been logged out because your account was logged in a different device", preferredStyle: .alert)
                            let done = UIAlertAction(title: "Return", style: .default, handler: { (done) in
                                let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let loginVC = mainStoryBoard.instantiateViewController(withIdentifier: "newLoginVC")
                                self.window?.rootViewController = loginVC
                                self.window?.makeKeyAndVisible()
                            })
                            alert.addAction(done)
                            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
                            
                            alertWindow.rootViewController = UIViewController()
                            alertWindow.windowLevel = UIWindowLevelAlert + 1
                            alertWindow.makeKeyAndVisible()
                            UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
                            alertWindow.rootViewController?.present(alert, animated: true, completion: nil)

                        }
                    }
                    
                }
            })
            
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
    
     func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         didReceive response: UNNotificationResponse,
                                         withCompletionHandler completionHandler: @escaping () -> Void){
      
      center.removeAllDeliveredNotifications()
    }
}
