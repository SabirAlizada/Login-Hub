//
//  PasswordTextField.swift
//  Login Hub
//
//  Created by Sabir Alizada on 19.04.25.
//

import SwiftUI

struct PasswordTextField: View {
    @Binding var password: String
    @Binding var showPassword: Bool
    var placeholder: String = "Password"
    
    private var isValidPassword: Bool {
        InputValidator.isValidPassword(password)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack {
                if showPassword {
                    TextField(placeholder, text: $password)
                        .textContentType(.password)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                } else {
                    SecureField(placeholder, text: $password)
                        .textContentType(.password) .padding()
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
            .shadow(radius: 0.7)
        }
    }
}
