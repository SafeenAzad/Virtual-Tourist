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
    
    func checkIfFirstLaunch(){
        if( UserDefaults.standard.bool(forKey: "HasLaunchedBefore") ){
            print("App has launched before.")
        }else{
            print("This is the first launch ever!")
            UserDefaults.standard.set(true, forKey: "HasLauchedBefore")
            UserDefaults.standard.synchronize()
        }
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        checkIfFirstLaunch()
        return true
    }
    
}

