//
//  GoogleLoginProvider.swift
//  Login Hub
//
//  Created by Sabir Alizada on 02.05.25.
//

import Foundation
import UIKit
import GoogleSignIn
import GoogleSignInSwift
import Combine

final class GoogleLoginProvider: NSObject, SocialLoginProviderProtocol {
    // Publishes a SocialUserProfile on successful login or an Error on failure
    let loginPublisher = PassthroughSubject<SocialUserProfile, Error>()
    
    func login() {
        // Obtain the current root view controller for presenting sign-in UI
        guard let rootViewController = GoogleLoginProvider.getRootViewController() else {
            loginPublisher.send(completion: .failure(NSError(domain: "NoRootVC", code: 0)))
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] signInResult, error in
            // Handle sign-in error
            if let error {
                self?.loginPublisher.send(completion: .failure(error))
                return
            }
            // Ensure a valid sign-in result exists
            guard let signInResult = signInResult else {
                self?.loginPublisher.send(completion: .failure(NSError(domain: "NoSignInResult", code: 0)))
                return
            }
            // Map Google user info to SocialUserProfile
            let user = signInResult.user
            let profile = SocialUserProfile(
                id: user.userID ?? UUID().uuidString,
                name: user.profile?.name ?? "",
                email: user.profile?.email ?? "",
                avatarURL: user.profile?.imageURL(withDimension: 200)?.absoluteString,
                provider: .google
            )
            // Publish successful login profile
            self?.loginPublisher.send(profile)
            self?.loginPublisher.send(completion: .finished)
        }
    }
    
    // Retrieves the current key window's root view controller
    private static func getRootViewController() -> UIViewController? {
        // Filter connected scenes for the active window scene
        let activeScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        // Return the root view controller of the key window
        return activeScene?
            .windows
            .first { $0.isKeyWindow }?
            .rootViewController
    }
    
    func logout() {
        GIDSignIn.sharedInstance.signOut()
    }
}
