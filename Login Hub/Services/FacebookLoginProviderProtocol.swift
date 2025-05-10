//
//  FacebookLoginProvider.swift
//  Login Hub
//
//  Created by Sabir Alizada on 02.05.25.
//

import Foundation
import FBSDKLoginKit
import Combine
import UIKit
import FirebaseAuth
import FacebookLogin

final class FacebookLoginProvider: NSObject, SocialLoginProviderProtocol {
    // Publishes a SocialUserProfile on successful login or an Error on failure
    let loginPublisher = PassthroughSubject<SocialUserProfile, Error>()
    private let loginManager = LoginManager()
    
    func login() {
        // Obtains the current root view controller for presenting login UI
        guard let rootViewController = FacebookLoginProvider.getRootViewController() else {
            loginPublisher.send(completion: .failure(NSError(domain: "NoRootVC", code: 0)))
            return
        }
        // Initiates Facebook login flow with required permissions
        loginManager.logIn(
            permissions: ["public_profile", "email"], from: rootViewController) { [weak self] result, error in
                if let error {
                    self?.loginPublisher.send(completion: .failure(error))
                    return
                }
                guard let result, !result.isCancelled else {
                    self?.loginPublisher.send(completion: .failure(NSError(domain: "Cancelled", code: 0)))
                    return
                }
                guard let accessToken = AccessToken.current else {
                    self?.loginPublisher.send(completion: .failure(NSError(domain: "NoAccessToken", code: 0)))
                    return
                }
                // Sign in to Firebase and fetch
                self?.handleFirebaseLogin(accessToken: accessToken)
                self?.fetchProfile()
            }
    }
    
    func logout() {
        loginManager.logOut()
    }
    
    // Requests user profile from Facebook Graph API
    private func fetchProfile() {
        GraphRequest(
            graphPath: "me",
            parameters: ["fields": "id, name, email, picture.type(large)"]).start {
                [weak self] _,
                result,
                error in
                // Handles graph request error
                if let error {
                    self?.loginPublisher.send(completion: .failure(error))
                    return
                }
                // Parses Graph API response to build SocialUserProfile
                if let dict = result as? [String: Any],
                   let id = dict["id"] as? String,
                   let name = dict["name"] as? String,
                   let email = dict["email"] as? String,
                   let picture = (dict["picture"] as? [String: Any])?["data"] as? [String: Any],
                   let pictureUrl = picture["url"] as? String {
                    let profile = SocialUserProfile(
                        id: id,
                        name: name,
                        email: email,
                        avatarURL: pictureUrl,
                        provider: .facebook
                    )
                    self?.loginPublisher.send(profile)
                } else {
                    self?.loginPublisher.send(completion: .failure(NSError(domain: "ProfileParse", code: 0)))
                }
            }
    }
    
    // Retrieves the current key window's root view controller
    private static func getRootViewController() -> UIViewController? {
        // Filters connected scenes for the active window scene
        let activeScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        // Returns the root view controller of the key window
        return activeScene?
            .windows
            .first { $0.isKeyWindow }?
            .rootViewController
    }
    
    private func handleFirebaseLogin(accessToken: FBSDKLoginKit.AccessToken) {
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("Firebase Facebook sign-in error: \(error.localizedDescription)")
                return
            }
            print("Firebase Facebook sign-in success: \(authResult?.user.uid ?? "")")
        }
    }
}
