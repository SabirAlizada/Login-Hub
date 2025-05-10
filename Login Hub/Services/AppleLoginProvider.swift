import Foundation
import AuthenticationServices
import Combine
import UIKit
import Security
import FirebaseAuth

/*
 Purpose: Provides Sign in with Apple functionality conforming to SocialLoginProviderProtocol,
 handling credential state, login, logout, and delegate callbacks.
 */

final class AppleLoginProvider: NSObject, SocialLoginProviderProtocol {
    // MARK: - Properties
    private var currentNonce: String?
    
    // Creates an OAuth credential for Firebase from Apple ID credential.
    private func makeFirebaseCredential(from appleCredential: ASAuthorizationAppleIDCredential) -> AuthCredential? {
        guard let identityToken = appleCredential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8),
              let nonce = currentNonce else {
            return nil
        }
        return OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: tokenString,
            rawNonce: nonce
        )
    }
    
    // Publishes a SocialUserProfile on successful Apple Sign-In or an Error on failure
    let loginPublisher = PassthroughSubject<SocialUserProfile, Error>()
    private var currentAuthorizationController: ASAuthorizationController?
    
    // MARK: - Initialization
    override init() {
        super.init()
        // Checks for existing credentials on initialization
        checkExistingCredentials()
    }
    
    // MARK: - Private Methods
    private func checkExistingCredentials() {
        // Verifies existing Apple ID credential state on initialization
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
    
    // MARK: - Public API
    func login() {
        // Creates Apple ID authorization request with desired scopes
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let nonce = AppleSignInNonce.randomNonceString()
        currentNonce = nonce
        request.nonce = AppleSignInNonce.sha256(nonce)
        
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

// MARK: - Apple sign in authorization controller delegate
extension AppleLoginProvider: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // Received Apple ID credential; extract user info
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userId = appleIDCredential.user
            let email = appleIDCredential.email ?? ""
            let fullName = appleIDCredential.fullName
            
            // Builds display name from name components, fallsback to email if empty
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
            
            if let credential = makeFirebaseCredential(from: appleIDCredential) {
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("Firebase Apple sign-in error: \(error.localizedDescription)")
                    } else {
                        print("Firebase Apple sign-in success: \(authResult?.user.uid ?? "")")
                    }
                }
            }
            
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
        // Handles specific Apple Sign In errors
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

// MARK: - Apple sign in authorization controller presentation context providing
extension AppleLoginProvider: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return getRootViewController().view.window ?? ASPresentationAnchor()
    }
}

// MARK: - Presentation Context
private extension AppleLoginProvider {
    func getRootViewController() -> UIViewController {
        // Determines the active UIWindowScene to provide presentation anchor
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootVC = window.rootViewController else {
            // Fallback: creates a temporary window if no key window is available
            let window = UIWindow(frame: UIScreen.main.bounds)
            let viewController = UIViewController()
            window.rootViewController = viewController
            window.makeKeyAndVisible()
            return viewController
        }
        return rootVC
    }
}
