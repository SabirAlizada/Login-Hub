//
//  SocialUserViewModel.swift
//  Login Hub
//
//  Created by Sabir Alizada on 02.05.25.
//

import Foundation
import Combine

//Handles social login logic and state.
final class SocialLoginViewModel: ObservableObject {
    @Published var userProfile: SocialUserProfile?
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let providers: [SocialProvider: SocialLoginProvider]

    // Initializes the ViewModel with a dictionary of providers.
    init(providers: [SocialProvider: SocialLoginProvider]) {
        self.providers = providers
        setupBindings()
    }

    // Sets up Combine bindings for all providers' login publishers.
    private func setupBindings() {
        for provider in providers.values {
            provider.loginPublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.isLoggedIn = false
                    }
                }, receiveValue: { [weak self] profile in
                    self?.userProfile = profile
                    self?.isLoggedIn = true
                })
                .store(in: &cancellables)
        }
    }

    // Initiates login with the specified provider.
    func login(with provider: SocialProvider) {
        providers[provider]?.login()
    }

    // Logs out the user from all providers and clears user state.
    func logout() {
        for provider in providers.values {
            provider.logout()
        }
        userProfile = nil
        isLoggedIn = false
    }
}
