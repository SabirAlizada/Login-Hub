import Foundation
import AuthenticationServices
import Combine
import Security

final class AppleLoginProvider: NSObject, SocialLoginProvider {
    let loginPublisher = PassthroughSubject<SocialUserProfile, Error>()
    private var currentAuthorizationController: ASAuthorizationController?
    
    override init() {
        super.init()
        // Check for existing credentials on initialization
        checkExistingCredentials()
    }
    
    private func checkExistingCredentials() {
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: UserDefaults.standard.string(forKey: "appleUserID") ?? "") { [weak self] state, error in
            switch state {
            case .authorized:
                // User is still authorized, we can proceed with existing credentials
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
                // Clear stored credentials
                UserDefaults.standard.removeObject(forKey: "appleUserID")
                UserDefaults.standard.removeObject(forKey: "appleUserEmail")
                UserDefaults.standard.removeObject(forKey: "appleUserName")
            default:
                break
            }
        }
    }
    
    func login() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        currentAuthorizationController = authorizationController
        
        // Perform the request on the main thread
        DispatchQueue.main.async {
            authorizationController.performRequests()
        }
    }
    
    func logout() {
        // Clear stored credentials
        UserDefaults.standard.removeObject(forKey: "appleUserID")
        UserDefaults.standard.removeObject(forKey: "appleUserEmail")
        UserDefaults.standard.removeObject(forKey: "appleUserName")
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleLoginProvider: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userId = appleIDCredential.user
            let email = appleIDCredential.email ?? ""
            let fullName = appleIDCredential.fullName
            
            // Create a name string from the components
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
            
            // If name is empty, use email as fallback
            if name.isEmpty {
                name = email
            }
            
            // Store credentials
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
            
            // Send profile on main thread
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
        
        // Send error on main thread
        DispatchQueue.main.async { [weak self] in
            self?.loginPublisher.send(completion: .failure(finalError))
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleLoginProvider: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            // If no window is found, create a new window
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = UIViewController()
            window.makeKeyAndVisible()
            return window
        }
        return window
    }
} 