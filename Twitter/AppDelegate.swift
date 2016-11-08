//
//  AppDelegate.swift
//  Twitter
//
//  Created by Zhaolong Zhong on 10/28/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit
import OAuthSwift
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let oauthTokenKey = "oathToken"
    let oauthTokenSecretKey = "oauthTokenSecret"
    let consumerKey = "xmnbz8aV49rka1EsbaLPphqTS"
    let consumerSecret = "IUKtVsuOHAoCspH8teZzcp2MXTYK3DMZO13FX7JRFbU1fvih3I"

    var window: UIWindow?
    
    var realm: Realm!
    
    let realmConfig = Realm.Configuration(
        // Set the new Schema version. This must be greater than the previously used version.
        schemaVersion: 3,
        migrationBlock: { migration, oldSchemaVersion in
            migration.deleteData(forType: Tweet.className())
            migration.deleteData(forType: User.className())
        }
    )
    
    static func getInstance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        Realm.Configuration.defaultConfiguration = realmConfig
        self.realm = try! Realm()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        let welcomeViewController = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
//        let blueGray = UIColor(red: 101/255.0, green: 117/255.0, blue: 128/255.0, alpha: 1.0)
//        let lightBlue = UIColor(red: 42/255.0, green: 163/255.0, blue: 239/255.0, alpha: 1.0)
//        tabBarController.tabBar.tintColor = lightBlue
//        
//        tabBarController.tabBar.barStyle = .default
//        tabBarController.tabBar.barTintColor = UIColor.white
//        
        self.window?.rootViewController = TwitterClient.getInstance() != nil ? mainViewController : welcomeViewController
        self.window?.makeKeyAndVisible()
        
        
        
//        let mainViewController = window!.rootViewController as! MainViewController
//        let menuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
//        mainViewController.menuViewController = menuViewController
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        TwitterClient.handleOpenUrl(url: url)

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

