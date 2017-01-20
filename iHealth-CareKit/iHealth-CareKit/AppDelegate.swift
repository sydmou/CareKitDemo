//
//  AppDelegate.swift
//  iHealth-CareKit
//
//  Created by HAO on 2017/1/18.
//  Copyright © 2017年 ihealthlabs. All rights reserved.
//
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    #if swift(>=3.0)
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        window?.tintColor = Colors.red.color
        return true
    }
    
    #else
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: Any]?) -> Bool {
    window?.tintColor = Colors.red.color
    
    return true
    }
    
    #endif
}
