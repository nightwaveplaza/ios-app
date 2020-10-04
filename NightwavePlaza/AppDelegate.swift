//
//  AppDelegate.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 24.05.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import UIKit
@_exported import BugfenderSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupBugfender()
        return true
    }
    
    func setupBugfender() {
        Bugfender.activateLogger("KgiPWeqeDfiUtzY5H9JN9fUyUoCRWNmT")
        Bugfender.enableCrashReporting()
    }


}

