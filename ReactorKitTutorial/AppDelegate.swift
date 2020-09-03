//
//  AppDelegate.swift
//  ReactorKitTutorial
//
//  Created by Jaedoo Ko on 2020/09/03.
//  Copyright © 2020 jko. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        window?.rootViewController = GithubSearchViewController()
        
        return true
    }
}

