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
import FirebaseAuth

final class GoogleLoginProvider: NSObject, SocialLoginProviderProtocol {
    // Publishes a SocialUserProfile on successful login or an Error on failure
    let loginPublisher = PassthroughSubject<SocialUserProfile, Error>()
    
    func login() {
        // First try to restore previous sign-in
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            if let user {
                self?.handleGoogleSignIn(user: user)
            } else {
                self?.performNewSignIn()
            }
        }
    }
    
    private func performNewSignIn() {
        // Obtains the current root view controller for presenting sign-in UI
        guard let rootViewController = GoogleLoginProvider.getRootViewController() else {
            loginPublisher.send(completion: .failure(NSError(domain: "NoRootVC", code: 0)))
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] signInResult, error in
            if let error {
                self?.loginPublisher.send(completion: .failure(error))
                return
            }
            // Ensures a valid sign-in result exists
            guard let signInResult = signInResult else {
                self?.loginPublisher.send(completion: .failure(NSError(domain: "NoSignInResult", code: 0)))
                return
            }
            // Handle the sign-in
            self?.handleGoogleSignIn(user: signInResult.user)
        }
    }
    
    private func handleGoogleSignIn(user: GIDGoogleUser) {
        guard let idToken = user.idToken?.tokenString else {
            loginPublisher.send(completion: .failure(NSError(domain: "NoGoogleTokens", code: 0)))
            return
        }
        let accessToken = user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        // Sign in to Firebase
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            if let error = error {
                self?.loginPublisher.send(completion: .failure(error))
                return
            }
            
            guard let authResult = authResult else {
                self?.loginPublisher.send(completion: .failure(NSError(domain: "NoAuthResult", code: 0)))
                return
            }
            
            let profile = SocialUserProfile(
                id: authResult.user.uid,
                name: user.profile?.name ?? authResult.user.displayName ?? "User",
                email: user.profile?.email ?? authResult.user.email ?? "",
                avatarURL: user.profile?.imageURL(withDimension: 200)?.absoluteString ?? authResult.user.photoURL?.absoluteString,
                provider: .google
            )
            self?.loginPublisher.send(profile)
            self?.loginPublisher.send(completion: .finished)
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
    
    func logout() {
        GIDSignIn.sharedInstance.signOut()
        
        // Also signs out from Firebase if the user was signed in with Google
        if let user = Auth.auth().currentUser,
           user.providerData.contains(where: { $0.providerID == GoogleAuthProviderID }) {
            try? Auth.auth().signOut()
        }
    }
}
