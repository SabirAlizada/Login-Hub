//
//  FacebookLoginProvider.swift
//  Login Hub
//
//  Created by Sabir Alizada on 02.05.25.
//

import Foundation
import FBSDKLoginKit
import Combine

final class FacebookLoginProvider: NSObject, SocialLoginProvider {
    let loginPublisher = PassthroughSubject<SocialUserProfile, Error>()
    private let loginManager = LoginManager()
    
    func login() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            loginPublisher.send(completion: .failure(NSError(domain: "NoRootVC", code: 0)))
            return
        }
        loginManager.logIn(permissions: ["public_profile", "email"], from: rootVC) { [weak self] result, error in
            if let error {
                self?.loginPublisher.send(completion: .failure(error))
                return
            }
            guard let result, !result.isCancelled else {
                self?.loginPublisher.send(completion: .failure(NSError(domain: "Cancelled", code: 0)))
                return
            }
            self?.fetchProfile()
        }
    }
    
    func logout() {
        loginManager.logOut()
    }
    
    private func fetchProfile() {
        GraphRequest(
            graphPath: "me",
            parameters: ["fields": "id, name, email, picture.type(large)"]).start { [weak self] _, result, error in
                if let error {
                    self?.loginPublisher.send(completion: .failure(error))
                    return
                }
                if let dict = result as? [String: Any],
                   let id = dict["id"] as? String,
                   let name = dict["name"] as? String,
                   let email = dict["email"] as? String,
                   let picture = (dict["picture"] as? [String: Any])?["data"] as? [String: Any],
                   let pictureUrl = picture["url"] as? String {
                    let profile = SocialUserProfile(id: id, name: name, email: email, avatarURL: pictureUrl, provider: .facebook)
                    self?.loginPublisher.send(profile)
                } else {
                    self?.loginPublisher.send(completion: .failure(NSError(domain: "ProfileParse", code: 0)))
                }
            }
    }
}
