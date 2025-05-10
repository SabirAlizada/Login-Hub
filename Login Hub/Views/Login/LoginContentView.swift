//
//  LoginContentView.swift
//  Login Hub
//
//  Created by Sabir Alizada on 24.03.25.
//
/*
 Purpose: Composes the login UI with email/password inputs, remember-me toggle,
 login button, and social login options, handling focus and navigation.
*/

import SwiftUI
import GoogleSignIn
import FirebaseAuth
import _AuthenticationServices_SwiftUI

struct LoginContentView: View {
    // MARK: - ViewModel & State Properties
    @ObservedObject var viewModel: SocialLoginViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var showPassword = false
    @State private var navigateToDashboard = false
    @State private var path = NavigationPath()
    
    @FocusState private var focusField: Field?
    
    // MARK: - Navigation & Focus Enums
    private enum Field {
        case email, password
    }
    
    private enum LoginNavigation: Hashable {
        case dashboard
    }
    
    // MARK: - Computed Properties
    // Whether the form is valid to enable the Log In button
    private var canSubmit: Bool {
        InputValidator.isValidEmail(email) && !password.isEmpty
    }
    
    // MARK: - Input Fields
    private var loginFields: some View {
        Group {
            InputField(
                text: $email,
                placeholder: "Email",
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .none,
                submitLabel: .next
            )
            .focused($focusField, equals: .email)
            .background(Color(uiColor: .systemBackground))
            .foregroundStyle(Color(uiColor: .label))
            
            PasswordTextField(
                password: $password,
                showPassword: $showPassword,
                placeholder: "Password",
                returnKeyType: .done,
                onReturn: { focusField = nil }
            )
            .focused($focusField, equals: .password)
            .background(Color(uiColor: .systemBackground))
            .foregroundStyle(Color(uiColor: .label))
            .onChange(of: showPassword) { _, _ in
                focusField = .password
            }
        }
    }
    
    // MARK: - Helpers Section
    private var forgotPasswordSection: some View {
        HStack {
            Toggle("Remember me", isOn: $rememberMe)
                .toggleStyle(CheckboxToggleStyle())
                .foregroundStyle(.gray)
                .onChange(of: rememberMe) { _, isEnabled in
                    if isEnabled {
                        viewModel.savedCredentials = (email, password)
                    } else {
                        viewModel.savedCredentials = nil
                    }
                }
            Spacer()
            Button {
                // TODO: Implement forgot password action
            } label: {
                Text("Forgot password?")
                    .foregroundStyle(.blue)
                    .font(.subheadline)
            }
        }
    }
    
    // MARK: - Action Section
    private var loginButtonSection: some View {
        Button {
            if rememberMe {
                viewModel.savedCredentials = (email, password)
            }
            viewModel.signIn(email: email, password: password)
        } label: {
            Text("Log In")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 48)
                .background(canSubmit ? Color.blue : Color.gray)
                .cornerRadius(10)
        }
        .disabled(!canSubmit)
        .opacity(canSubmit ? 1 : 0.5)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
    
    // MARK: - Social Login Section
    private var socialLoginSection: some View {
        VStack {
            DividerWithLabel(label: "or log in with")
            HStack(spacing: 20) {
                SocialButtonView(iconName: "facebookLogo") {
                    viewModel.login(with: .facebook)
                }
                SocialButtonView(iconName: "googleLogo") {
                    viewModel.login(with: .google)
                }
                SocialButtonView(iconName: "appleLogo") {
                    viewModel.login(with: .apple)
                }
            }
            .padding(.vertical, 8)
            .padding(.bottom, 35)
        }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 30) {
                loginFields
                forgotPasswordSection
                loginButtonSection
                socialLoginSection
                Spacer()
            }
            .padding(.horizontal, 16)
            // Handles return key to move focus or dismiss keyboard
            .onSubmit {
                switch focusField {
                    case .email:
                        focusField = .password
                    case .password:
                        focusField = nil
                    case .none:
                        break
                }
            }
            // Navigates to dashboard when login succeeds
            .onChange(of: viewModel.userProfile) { _, profile in
                if profile != nil && path.isEmpty {
                    path.append(LoginNavigation.dashboard)
                }
            }
            .navigationDestination(for: LoginNavigation.self) { destination in
                switch destination {
                    case .dashboard:
                        if let profile = viewModel.userProfile {
                            DashboardView(userProfile: profile)
                        }
                }
            }
            .onAppear {
                // Loads saved credentials when view appears
                viewModel.loadSavedCredentials()
                if let savedCredentials = viewModel.savedCredentials {
                    email = savedCredentials.email
                    password = savedCredentials.password
                    rememberMe = true
                }
            }
        }
        .frame(maxHeight: 500)
    }
}

struct DividerWithLabel: View {
    var label: String
    var body: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.gray)
                .opacity(0.3)
            
            Spacer()
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal, 8)
            
            Spacer()
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.gray)
                .opacity(0.3)
        }
    }
}

struct SocialButtonView: View {
    let iconName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Color.white
                    .cornerRadius(22)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 3)
                
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
            .frame(width: 60, height: 60)
        }
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                Image(
                    systemName: configuration.isOn
                    ? "checkmark.square.fill" : "square"
                )
                .foregroundStyle(configuration.isOn ? .blue : .secondary)
                configuration.label
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
