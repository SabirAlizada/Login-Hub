//
//  GoogleLoginProviderTests.swift
//  Login Hub
//
//  Created by Sabir Alizada on 07.05.25.
//

import XCTest
import Combine
@testable import Login_Hub
import GoogleSignIn
import Foundation

/// Abstraction over the GoogleSignIn provider for easy mocking in tests.
protocol GoogleLoginProviderProtocol {
  /// Starts Google Sign‑In, publishing either a SocialUserProfile or an Error.
  func signIn() -> AnyPublisher<SocialUserProfile, Error>
}

// MARK: – Conformance for your real provider
extension GoogleLoginProvider: GoogleLoginProviderProtocol {
  func signIn() -> AnyPublisher<SocialUserProfile, Error> {
    // Expose your existing PassthroughSubject or publisher
    return loginPublisher.eraseToAnyPublisher()
  }
}

/// A fake SocialLoginProvider to drive test scenarios.
private class FakeGoogleProvider: SocialLoginProvider {
    // Publisher for login results
    var loginPublisher = PassthroughSubject<SocialUserProfile, Error>()
    var result: Result<SocialUserProfile, Error>!

    func login() {
        switch result {
        case .success(let profile):
            loginPublisher.send(profile)
            loginPublisher.send(completion: .finished)
        case .failure(let error):
            loginPublisher.send(completion: .failure(error))
        case .none:
            break
        }
    }

    func logout() {
        // No-op for tests
    }
}

final class GoogleLoginProviderTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func testSignInSuccessPublishesProfile() {
        // Arrange
        let expected = SocialUserProfile(
            id: "123",
            name: "Test User",
            email: "test@example.com",
            avatarURL: "https://example.com/avatar.png",
            provider: .google
        )
        let fake = FakeGoogleProvider()
        fake.result = .success(expected)
        let vm = SocialLoginViewModel(providers: [.google: fake])

        let exp = expectation(description: "Publishes user profile")
        var received: SocialUserProfile?

        vm.$userProfile
          .dropFirst()
          .sink { profile in
              received = profile
              exp.fulfill()
          }
          .store(in: &cancellables)

        // Act
        vm.login(with: .google)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(received?.email, expected.email)
    }

    func testSignInFailurePublishesError() {
        // Arrange
        enum TestError: Error { case dummy }
        let fake = FakeGoogleProvider()
        fake.result = .failure(TestError.dummy)
        let vm = SocialLoginViewModel(providers: [.google: fake])

        let exp = expectation(description: "Publishes error")
        var receivedError: String?

        vm.$errorMessage
          .dropFirst()
          .sink { err in
              receivedError = err
              exp.fulfill()
          }
          .store(in: &cancellables)

        // Act
        vm.login(with: .google)

        waitForExpectations(timeout: 1)
        XCTAssertNotNil(receivedError)
    }
}
