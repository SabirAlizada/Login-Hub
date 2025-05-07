//
//  Login_HubApp.swift
//  Login Hub
//
//  Created by Sabir Alizada on 22.03.25.
//

import SwiftUI
import FacebookLogin
import FirebaseCore
import GoogleSignIn

@main
struct Login_HubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        // Initializes Firebase
        FirebaseApp.configure()
        
        // Configures Google Sign-In
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
    }
    
    @StateObject private var viewModel = SocialLoginViewModel(
        providers: [
            .facebook: FacebookLoginProvider(),
            .google: GoogleLoginProvider()
        ]
    )
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
