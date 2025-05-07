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

final class GoogleLoginProvider: NSObject, SocialLoginProvider {
    let loginPublisher = PassthroughSubject<SocialUserProfile, Error>()
    
    func login() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            loginPublisher.send(completion: .failure(NSError(domain: "NoRootVC", code: 0)))
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { [weak self] signInResult, error in
            if let error {
                self?.loginPublisher.send(completion: .failure(error))
                return
            }
            
            guard let signInResult = signInResult else {
                self?.loginPublisher.send(completion: .failure(NSError(domain: "NoSignInResult", code: 0)))
                return
            }
            
            let user = signInResult.user
            let profile = SocialUserProfile(
                id: user.userID ?? UUID().uuidString,
                name: user.profile?.name ?? "",
                email: user.profile?.email ?? "",
                avatarURL: user.profile?.imageURL(withDimension: 200)?.absoluteString,
                provider: .google
            )
            self?.loginPublisher.send(profile)
            self?.loginPublisher.send(completion: .finished)
        }
    }
    
    func logout() {
        GIDSignIn.sharedInstance.signOut()
    }
}
