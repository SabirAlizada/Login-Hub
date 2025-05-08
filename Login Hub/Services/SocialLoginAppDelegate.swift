//
//  SocialLoginAppDelegate.swift
//  Login Hub
//
//  Created by Sabir Alizada on 02.05.25.
//
//
//  Purpose: Handles lifecycle events and routes social login callbacks (Facebook, Google).
//

import SwiftUI
import FacebookLogin
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize Facebook SDK
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        return true
    }
          
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // Handle Facebook login callback
        let facebookHandled = ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[.sourceApplication] as? String,
            annotation: options[.annotation]
        )
        if facebookHandled {
            return true
        }
        
        // Handle Google Sign-In callback
        let googleHandled = GIDSignIn.sharedInstance.handle(url)
        if googleHandled {
            return true
        }
        
        // URL not handled by any social login provider
        return false
    }
}
