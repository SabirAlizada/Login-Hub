//
//  Login_HubTests.swift
//  Login HubTests
//
//  Created by Sabir Alizada on 22.03.25.
//

import Testing
import Combine
import FBSDKLoginKit
@testable import Login_Hub

// MARK: - Mock FacebookLoginProvider
final class MockFacebookLoginProvider: SocialLoginProvider {
    let loginPublisher = PassthroughSubject<SocialUserProfile, Error>()
    
    func login() {
        // Simulate successful login
        let profile = SocialUserProfile(
            id: "123456789",
            name: "Test User",
            email: "test@example.com",
            avatarURL: "https://example.com/avatar.jpg",
            provider: .facebook
        )
        loginPublisher.send(profile)
    }
    
    func logout() {
        // Simulate logout
        loginPublisher.send(completion: .finished)
    }
}

struct Login_HubTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    // MARK: - Facebook Login Tests
    
    @Test func testFacebookLoginSuccess() async throws {
        // Arrange
        let provider = MockFacebookLoginProvider()
        let viewModel = SocialLoginViewModel(providers: [SocialProvider.facebook: provider])
        var receivedProfile: SocialUserProfile?
        var cancellables = Set<AnyCancellable>()
        
        // Act
        viewModel.$userProfile
            .dropFirst()
            .sink { profile in
                receivedProfile = profile
            }
            .store(in: &cancellables)
        
        viewModel.login(with: SocialProvider.facebook)
        
        // Wait for profile to be received
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Assert
        #expect(receivedProfile != nil)
        #expect(receivedProfile?.provider == SocialProvider.facebook)
        #expect(receivedProfile?.id == "123456789")
        #expect(receivedProfile?.name == "Test User")
        #expect(receivedProfile?.email == "test@example.com")
    }
    
    @Test func testFacebookLoginError() async throws {
        // Arrange
        let provider = MockFacebookLoginProvider()
        let viewModel = SocialLoginViewModel(providers: [SocialProvider.facebook: provider])
        var receivedError: String?
        var cancellables = Set<AnyCancellable>()
        
        // Act
        viewModel.$errorMessage
            .dropFirst()
            .sink { error in
                receivedError = error
            }
            .store(in: &cancellables)
        
        // Simulate login error
        provider.loginPublisher.send(completion: .failure(NSError(domain: "TestError", code: 0)))
        
        // Wait for error to be received
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Assert
        #expect(receivedError != nil)
        #expect(receivedError?.isEmpty == false)
    }
    
    @Test func testFacebookLogout() async throws {
        // Arrange
        let provider = MockFacebookLoginProvider()
        let viewModel = SocialLoginViewModel(providers: [SocialProvider.facebook: provider])
        var isLoggedIn = false
        var cancellables = Set<AnyCancellable>()
        
        // Act - Login
        viewModel.$isLoggedIn
            .dropFirst()
            .sink { loggedIn in
                isLoggedIn = loggedIn
            }
            .store(in: &cancellables)
        
        viewModel.login(with: SocialProvider.facebook)
        
        // Wait for login
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Act - Logout
        viewModel.$isLoggedIn
            .dropFirst()
            .sink { loggedIn in
                isLoggedIn = loggedIn
            }
            .store(in: &cancellables)
        
        viewModel.logout()
        
        // Wait for logout
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Assert
        #expect(!isLoggedIn)
        #expect(viewModel.userProfile == nil)
    }
    
    @Test func testFacebookProfileData() async throws {
        // Arrange
        let provider = MockFacebookLoginProvider()
        let viewModel = SocialLoginViewModel(providers: [SocialProvider.facebook: provider])
        var receivedProfile: SocialUserProfile?
        var cancellables = Set<AnyCancellable>()
        
        // Act
        viewModel.$userProfile
            .dropFirst()
            .sink { profile in
                receivedProfile = profile
            }
            .store(in: &cancellables)
        
        viewModel.login(with: SocialProvider.facebook)
        
        // Wait for profile to be received
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Assert
        #expect(receivedProfile != nil)
        #expect(receivedProfile?.provider == SocialProvider.facebook)
        #expect(receivedProfile?.id == "123456789")
        #expect(receivedProfile?.name == "Test User")
        #expect(receivedProfile?.email == "test@example.com")
        #expect(receivedProfile?.avatarURL == "https://example.com/avatar.jpg")
    }
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
}
