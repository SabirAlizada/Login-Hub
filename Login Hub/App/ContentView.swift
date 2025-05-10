//
//  ContentView.swift
//  Login Hub
//
//  Created by Sabir Alizada on 22.03.25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: SocialLoginViewModel
    @State private var isCheckingAuth = true
    @State private var isTransitioning = false
    
    var body: some View {
        Group {
            if isCheckingAuth {
                SplashView()
                    .onAppear {
                        // Small delay to ensure smooth transition
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                isCheckingAuth = false
                            }
                        }
                    }
            } else if isTransitioning {
                SplashView()
                    .onAppear {
                        // Small delay for transition animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                isTransitioning = false
                            }
                        }
                    }
            } else if viewModel.isLoggedIn, let profile = viewModel.userProfile {
                NavigationStack {
                    DashboardView(userProfile: profile)
                }
            } else {
                LoginView(viewModel: viewModel)
                    .onChange(of: viewModel.isLoggedIn) { _, isLoggedIn in
                        if isLoggedIn {
                            isTransitioning = true
                        }
                    }
            }
        }
    }
}
