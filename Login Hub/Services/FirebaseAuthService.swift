import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

/// Service responsible for handling Firebase email/password authentication
final class FirebaseAuthService {
    // MARK: - Properties
    private let auth = Auth.auth()
    
    // MARK: - Publishers
    let authStatePublisher = PassthroughSubject<SocialUserProfile?, Error>()
    
    // MARK: - Sign Up
    
    func signUp(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        phoneNumber: String,
        birthDate: Date
    ) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error {
                self?.authStatePublisher.send(completion: .failure(error))
                print(error.localizedDescription)
                return
            }
            
            guard let user = result?.user else {
                self?.authStatePublisher.send(completion: .failure(NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create user"])))
                return
            }
            
            // Creates user profile
            let profile = SocialUserProfile(
                id: user.uid,
                name: "\(firstName) \(lastName)",
                email: email,
                avatarURL: nil,
                provider: .custom
            )
            
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData([
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "phoneNumber": phoneNumber,
                "birthDate": Timestamp(date: birthDate)
            ]) { error in
                if let error {
                    print("Error saving user data: \(error.localizedDescription)")
                } else {
                    print("User data succesfully saved to Firestone")
                }
            }
            
            // Update user's display name
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = profile.name
            changeRequest.commitChanges { error in
                if let error {
                    print("Error updating profile: \(error.localizedDescription)")
                }
            }
            
            self?.authStatePublisher.send(profile)
            self?.authStatePublisher.send(completion: .finished)
        }
    }
    
    // MARK: - Sign In

    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("Sign in error: \(error.localizedDescription)")
                self?.authStatePublisher.send(completion: .failure(error))
                return
            }
            guard let user = result?.user else {
                self?.authStatePublisher.send(completion: .failure(NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to sign in"])))
                return
            }
            let profile = SocialUserProfile(
                id: user.uid,
                name: user.displayName ?? "User",
                email: user.email ?? "",
                avatarURL: user.photoURL?.absoluteString,
                provider: .custom
            )
            print("Sign in success: \(profile)")
            self?.authStatePublisher.send(profile)
            self?.authStatePublisher.send(completion: .finished)
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        do {
            try auth.signOut()
            authStatePublisher.send(nil)
            authStatePublisher.send(completion: .finished)
        } catch {
            authStatePublisher.send(completion: .failure(error))
        }
    }
    
    // MARK: - Password Reset

    func resetPassword(email: String) {
        auth.sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error {
                self?.authStatePublisher.send(completion: .failure(error))
                return
            }
            self?.authStatePublisher.send(nil)
            self?.authStatePublisher.send(completion: .finished)
        }
    }
} 
