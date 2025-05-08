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

final class FacebookLoginProvider: NSObject, SocialLoginProviderProtocol {
    // Publishes a SocialUserProfile on successful login or an Error on failure
    let loginPublisher = PassthroughSubject<SocialUserProfile, Error>()
    private let loginManager = LoginManager()
    
    func login() {
        // Obtain the current root view controller for presenting login UI
        guard let rootViewController = FacebookLoginProvider.getRootViewController() else {
            loginPublisher.send(completion: .failure(NSError(domain: "NoRootVC", code: 0)))
            return
        }
        // Initiate Facebook login flow with required permissions
        loginManager.logIn(
            permissions: ["public_profile", "email"], from: rootViewController) { [weak self] result, error in
                // Handle login error
                if let error {
                    self?.loginPublisher.send(completion: .failure(error))
                    return
                }
                // Handle user cancellation
                guard let result, !result.isCancelled else {
                    self?.loginPublisher.send(completion: .failure(NSError(domain: "Cancelled", code: 0)))
                    return
                }
                // Proceed to fetch user profile
                self?.fetchProfile()
            }
    }
    
    func logout() {
        loginManager.logOut()
    }
    
    // Request user profile from Facebook Graph API
    private func fetchProfile() {
        GraphRequest(
            graphPath: "me",
            parameters: ["fields": "id, name, email, picture.type(large)"]).start {
                [weak self] _,
                result,
                error in
                // Handle graph request error
                if let error {
                    self?.loginPublisher.send(completion: .failure(error))
                    return
                }
                // Parse Graph API response to build SocialUserProfile
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
}
