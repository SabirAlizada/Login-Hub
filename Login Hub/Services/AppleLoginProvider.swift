import Foundation
import AuthenticationServices
import Combine
import UIKit
import Security

/*
 Purpose: Provides Sign in with Apple functionality conforming to SocialLoginProviderProtocol,
 handling credential state, login, logout, and delegate callbacks.
 */

final class AppleLoginProvider: NSObject, SocialLoginProviderProtocol {
    // Publishes a SocialUserProfile on successful Apple Sign-In or an Error on failure
    let loginPublisher = PassthroughSubject<SocialUserProfile, Error>()
    private var currentAuthorizationController: ASAuthorizationController?
    
    override init() {
        super.init()
        // Check for existing credentials on initialization
        checkExistingCredentials()
    }
    
    private func checkExistingCredentials() {
        // Verify existing Apple ID credential state on initialization
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(
            forUserID: UserDefaults.standard.string(forKey: "appleUserID") ?? "") { [weak self] state, error in
                switch state {
                    case .authorized:
                        // Credential revoked or not found: clear stored Apple ID info
                        // User still authorized: rebuild profile from stored credentials
                        if let userID = UserDefaults.standard.string(forKey: "appleUserID"),
                           let email = UserDefaults.standard.string(forKey: "appleUserEmail"),
                           let name = UserDefaults.standard.string(forKey: "appleUserName") {
                            let profile = SocialUserProfile(
                                id: userID,
                                name: name,
                                email: email,
                                avatarURL: nil,
                                provider: .apple
                            )
                            DispatchQueue.main.async {
                                self?.loginPublisher.send(profile)
                                self?.loginPublisher.send(completion: .finished)
                            }
                        }
                    case .revoked, .notFound:
                        // Credential revoked or not found: clear stored Apple ID info
                        UserDefaults.standard.removeObject(forKey: "appleUserID")
                        UserDefaults.standard.removeObject(forKey: "appleUserEmail")
                        UserDefaults.standard.removeObject(forKey: "appleUserName")
                    default:
                        break
                }
            }
    }
    
    func login() {
        // Create Apple ID authorization request with desired scopes
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        currentAuthorizationController = authorizationController
        
        DispatchQueue.main.async {
            authorizationController.performRequests()
        }
    }
    
    // Clears stored Apple ID credentials on logout
    func logout() {
        UserDefaults.standard.removeObject(forKey: "appleUserID")
        UserDefaults.standard.removeObject(forKey: "appleUserEmail")
        UserDefaults.standard.removeObject(forKey: "appleUserName")
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleLoginProvider: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // Received Apple ID credential; extract user info
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userId = appleIDCredential.user
            let email = appleIDCredential.email ?? ""
            let fullName = appleIDCredential.fullName
            
            // Build display name from name components, fallback to email if empty
            var name = ""
            if let givenName = fullName?.givenName {
                name += givenName
            }
            if let familyName = fullName?.familyName {
                if !name.isEmpty {
                    name += " "
                }
                name += familyName
            }
            
            // If name is empty, uses email as fallback
            if name.isEmpty {
                name = email
            }
            
            // Persist Apple user ID, email, and name for session restoration
            UserDefaults.standard.set(userId, forKey: "appleUserID")
            UserDefaults.standard.set(email, forKey: "appleUserEmail")
            UserDefaults.standard.set(name, forKey: "appleUserName")
            
            let profile = SocialUserProfile(
                id: userId,
                name: name,
                email: email,
                avatarURL: nil,
                provider: .apple
            )
            
            // Sends successful login profile via publisher
            DispatchQueue.main.async { [weak self] in
                self?.loginPublisher.send(profile)
                self?.loginPublisher.send(completion: .finished)
            }
        } else {
            let error = NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get Apple ID credential"])
            DispatchQueue.main.async { [weak self] in
                self?.loginPublisher.send(completion: .failure(error))
            }
        }
    }
    
    // Handles and map Apple Sign-In errors to user-friendly NSError
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle specific Apple Sign In errors
        let nsError = error as NSError
        var finalError = error
        
        switch nsError.code {
            case ASAuthorizationError.canceled.rawValue:
                finalError = NSError(domain: "AppleSignIn", code: nsError.code, userInfo: [NSLocalizedDescriptionKey: "Sign in was canceled"])
            case ASAuthorizationError.invalidResponse.rawValue:
                finalError = NSError(domain: "AppleSignIn", code: nsError.code, userInfo: [NSLocalizedDescriptionKey: "Invalid response from Apple"])
            case ASAuthorizationError.notHandled.rawValue:
                finalError = NSError(domain: "AppleSignIn", code: nsError.code, userInfo: [NSLocalizedDescriptionKey: "Sign in request was not handled"])
            case ASAuthorizationError.unknown.rawValue:
                finalError = NSError(domain: "AppleSignIn", code: nsError.code, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
            default:
                break
        }
        
        // Sends error on main thread
        DispatchQueue.main.async { [weak self] in
            self?.loginPublisher.send(completion: .failure(finalError))
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleLoginProvider: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Determines the active UIWindowScene to provide presentation anchor
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            // Fallback: creates a temporary window if no key window is available
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = UIViewController()
            window.makeKeyAndVisible()
            return window
        }
        return window
    }
}
