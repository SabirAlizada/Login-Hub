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
    
    var body: some View {
        VStack(spacing: 30) {
            InputField(
                text: $email,
                placeholder: "Email",
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .none)
            
            PasswordField(password: $password, showPassword: $showPassword)
            
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
                    .frame(maxWidth: .infinity, maxHeight: 48)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
            .frame(width: .infinity, height: 48)
            .padding()
            
            DividerWithLabel(label: "or log in with")
            
            HStack(spacing: 20) {
                SocialButtonView(iconName: "") {}
                SocialButtonView(iconName: "") {}
                SocialButtonView(iconName: "") {}
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
    }
}

struct PasswordField: View {
    @Binding var password: String
    @Binding var showPassword: Bool
    
    var body: some View {
        ZStack {
            if showPassword {
                TextField("Password", text: $password)
                    .textContentType(.password)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
            } else {
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
            }
            HStack {
                Spacer()
                Button(action: { showPassword.toggle() }) {
                    Image(
                        systemName: showPassword ? "eye.slash.fill" : "eye.fill"
                    )
                    .foregroundColor(.gray)
                    .padding(.trailing, 12)
                }
            }
        }
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
            Image(systemName: iconName)
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
