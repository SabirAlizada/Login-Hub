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
import Combine

@main
struct LoginHubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var viewModel: SocialLoginViewModel
    
    init() {
        // Initializes Firebase
        FirebaseApp.configure()
        
        // Configures Google Sign-In
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            // Fallback to empty providers if clientID is unavailable
            _viewModel = StateObject(wrappedValue: SocialLoginViewModel(providers: [:]))
            return
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        // Setup social login providers
        let providers: [SocialProvider: SocialLoginProviderProtocol] = [
            .facebook: FacebookLoginProvider(),
            .google: GoogleLoginProvider(),
            .apple: AppleLoginProvider()
        ]
        // Inject viewModel with providers
        _viewModel = StateObject(wrappedValue: SocialLoginViewModel(providers: providers))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .environmentObject(viewModel)
        }
    }
}
