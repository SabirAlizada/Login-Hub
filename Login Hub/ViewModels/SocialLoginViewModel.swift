//
//  SocialLoginViewModel.swift
//  Login Hub
//
//  Created by Sabir Alizada on 02.05.25.
//

import Foundation
import Combine
import FirebaseAuth
import GoogleSignIn
import FacebookCore
import FacebookLogin

//Handles social login logic and state.
final class SocialLoginViewModel: ObservableObject {
    @Published var userProfile: SocialUserProfile?
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false
    @Published var savedCredentials: (email: String, password: String)? {
        didSet {
            if let credentials = savedCredentials {
                saveCredentialsToKeychain(email: credentials.email, password: credentials.password)
            } else {
                removeCredentialsFromKeychain()
            }
        }
    }

    private var cancellables = Set<AnyCancellable>()
    private let providers: [SocialProvider: SocialLoginProviderProtocol]
    private let firebaseAuthService: FirebaseAuthService
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private let keychainService = "com.sabir.Login-Hub"
    private let keychainAccount = "userCredentials"

    // Initializes the ViewModel with a dictionary of providers.
    init(providers: [SocialProvider: SocialLoginProviderProtocol]) {
        self.providers = providers
        self.firebaseAuthService = FirebaseAuthService()
        setupBindings()
        setupAuthStateListener()
    }
    
    deinit {
        // Removes the auth state listener when the view model is deallocated
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }

    // Sets up Combine bindings for all providers' login publishers.
    private func setupBindings() {
        // Setup social login providers
        for provider in providers.values {
            provider.loginPublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.isLoggedIn = false
                    }
                }, receiveValue: { [weak self] profile in
                    // Only updates state if not already logged in
                    if self?.isLoggedIn == false {
                        self?.userProfile = profile
                        self?.isLoggedIn = true
                    }
                })
                .store(in: &cancellables)
        }
        
        // Setup Firebase auth service
        firebaseAuthService.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoggedIn = false
                }
            }, receiveValue: { [weak self] profile in
                // Only updates state if not already logged in
                if self?.isLoggedIn == false {
                    self?.userProfile = profile
                    self?.isLoggedIn = profile != nil
                }
            })
            .store(in: &cancellables)
    }

    // MARK: - Authentication State Management
    private func setupAuthStateListener() {
        // Removes existing listener if any
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
        
        // Adds new listener
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user {
                    let profile = SocialUserProfile(
                        id: user.uid,
                        name: user.displayName ?? "User",
                        email: user.email ?? "",
                        avatarURL: user.photoURL?.absoluteString,
                        provider: self?.determineProvider(from: user) ?? .custom
                    )
                    self?.userProfile = profile
                    self?.isLoggedIn = true
                } else {
                    // User is signed out
                    self?.userProfile = nil
                    self?.isLoggedIn = false
                }
            }
        }
    }
    
    private func determineProvider(from user: User) -> SocialProvider {
        // Checks provider data to determine the sign-in method
        for provider in user.providerData {
            switch provider.providerID {
            case GoogleAuthProviderID:
                return .google
            case FacebookAuthProviderID:
                return .facebook
            case "apple.com":
                return .apple
            default:
                continue
            }
        }
        return .custom
    }

    // MARK: - Social Login
    /// Initiates login with the specified provider.
    func login(with provider: SocialProvider) {
        providers[provider]?.login()
    }
    
    // MARK: - Email/Password Authentication
    /// Signs up a new user with email and password
    func signUp(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        phoneNumber: String,
        birthDate: Date
    ) {
        firebaseAuthService
            .signUp(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName,
                phoneNumber: phoneNumber,
                birthDate: birthDate
            )
    }
    
    /// Signs in a user with email and password
    func signIn(email: String, password: String) {
        firebaseAuthService.signIn(email: email, password: password)
    }
    
    /// Sends a password reset email
    func resetPassword(email: String) {
        firebaseAuthService.resetPassword(email: email)
    }

    // MARK: - Remember Me Functionality
    /// Saves credentials to Keychain if remember me is enabled
    private func saveCredentialsToKeychain(email: String, password: String) {
        let credentials = "\(email):\(password)".data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: credentials
        ]
        
        // First try to delete any existing credentials
        SecItemDelete(query as CFDictionary)
        
        // Then add the new credentials
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error saving credentials to Keychain: \(status)")
        }
    }
    
    /// Removes credentials from Keychain
    private func removeCredentialsFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    /// Retrieves saved credentials from Keychain
    func loadSavedCredentials() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let credentials = String(data: data, encoding: .utf8) {
            let components = credentials.split(separator: ":")
            if components.count == 2 {
                savedCredentials = (String(components[0]), String(components[1]))
            }
        }
    }

    // MARK: - Logout
    /// Logs out the user from all providers and clears user state.
    func logout() {
        // First, sign out from Firebase
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out from Firebase: \(error.localizedDescription)")
        }
        
        // Then sign out from all social providers
        for provider in providers.values {
            provider.logout()
        }
        
        // Clears states
        GIDSignIn.sharedInstance.signOut()
        LoginManager().logOut()
        
        UserDefaults.standard.removeObject(forKey: "appleUserID")
        UserDefaults.standard.removeObject(forKey: "appleUserEmail")
        UserDefaults.standard.removeObject(forKey: "appleUserName")
        
        // Resets view model state
        DispatchQueue.main.async { [weak self] in
            self?.userProfile = nil
            self?.isLoggedIn = false
            self?.errorMessage = nil
            // Don't clear saved credentials on logout if remember me is enabled
        }
    }
}
