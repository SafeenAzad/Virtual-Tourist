//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Safeen Azad on 9/9/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let stack = CoreDataStack(modelName: "Model")!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    
    
    
}

