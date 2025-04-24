//
//  LoginContentView.swift
//  Login Hub
//
//  Created by Sabir Alizada on 24.03.25.
//

import SwiftUI

struct LoginContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var showPassword = false
    
    private var isValidEmail: Bool {
        InputValidator.isValidEmail(email)
    }
    
    private var isPasswordValid: Bool {
        InputValidator.isValidPassword(password)
    }
        
    var body: some View {
        let canSubmit = isValidEmail && !password.isEmpty

        VStack(spacing: 30) {
            InputField(
                text: $email,
                placeholder: "Email",
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .none)
            
            PasswordTextField(
                password: $password,
                showPassword: $showPassword,
                placeholder: "Password"
            )
            
            HStack {
                Toggle("Remember me", isOn: $rememberMe)
                    .toggleStyle(CheckboxToggleStyle())
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Button {
                    // TODO: Implement button logic
                } label: {
                    Text("Forgot password?")
                        .foregroundStyle(.blue)
                        .font(.subheadline)
                }
            }
            
            Button {
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
            .frame(maxWidth: .infinity, maxHeight: 48)
            .shadow(radius: 2)
            .padding()
            
            DividerWithLabel(label: "or log in with")
            
            HStack(spacing: 20) {
                SocialButtonView(iconName: "facebookLogo") {}
                SocialButtonView(iconName: "googleLogo") {}
                SocialButtonView(iconName: "appleLogo") {}
            }
            .padding(.vertical, 8)
            .padding(.bottom, 35)
        }
        .padding(.horizontal, 16)
    }
}

struct InputField: View {
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: UITextAutocapitalizationType = .sentences
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .autocapitalization(autocapitalization)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .frame(height: 44)
            .shadow(radius: 0.7)
    }
}

struct DividerWithLabel: View {
    var label: String
    var body: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.secondary)
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
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .background(Color(.systemGray6))  //TODO: change to white
                .cornerRadius(22)
                .shadow(
                    color: .black.opacity(0.1), radius: CGFloat(2), x: 0, y: 3)
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
