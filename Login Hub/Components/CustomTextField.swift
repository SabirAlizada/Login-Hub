//
//  PasswordTextField.swift
//  Login Hub
//
//  Created by Sabir Alizada on 19.04.25.
//


import UIKit
import SwiftUI

// A Wrapper that supports secure text entry toggling and binds its content to a SwiftUI view.
struct PasswordFieldRepresentable: UIViewRepresentable {
    @Binding var text: String
    var isSecure: Bool
    var placeholder: String
    var returnKeyType: UIReturnKeyType = .next
    var onReturn: (() -> Void)?
    
    // MARK: - UIViewRepresentable
    // Creates and configures the UITextField instance
    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.delegate = context.coordinator
        field.isSecureTextEntry = isSecure
        field.placeholder = placeholder
        field.backgroundColor = .secondarySystemBackground
        field.spellCheckingType = .no
        field.smartDashesType = .no
        field.smartQuotesType = .no
        field.enablesReturnKeyAutomatically = true
        field.returnKeyType = returnKeyType
        field.textContentType = .none
        field.autocorrectionType = .no
        field.inputAssistantItem.leadingBarButtonGroups.removeAll()
        field.inputAssistantItem.trailingBarButtonGroups.removeAll()
        field.inputAccessoryView = nil
        return field
    }
    
    // Updates text and secure entry state when bindings change
    func updateUIView(_ uiView: UITextField, context: Context) {
        // Only update text if it's different to avoid cursor reset
        if uiView.text != text {
            uiView.text = text
        }
        
        // Handles secure text entry change
        if uiView.isSecureTextEntry != isSecure {
            // Creates a temporary field to avoid cursor jumping
            let tempField = UITextField()
            tempField.isSecureTextEntry = isSecure
            tempField.text = text
            uiView.text = tempField.text
            uiView.isSecureTextEntry = isSecure
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onReturn: onReturn)
    }
    
    final class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var onReturn: (() -> Void)?
        
        init(text: Binding<String>, onReturn: (() -> Void)?) {
            self.text = text
            self.onReturn = onReturn
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.text.wrappedValue = textField.text ?? ""
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            onReturn?()
            textField.resignFirstResponder()
            return true
        }
    }
}

struct PasswordTextField: View {
    @Binding var password: String
    @Binding var showPassword: Bool
    var placeholder: String = "Password"
    var returnKeyType: UIReturnKeyType = .next
    var onReturn: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack {
                PasswordFieldRepresentable(
                    text: $password,
                    isSecure: !showPassword,
                    placeholder: placeholder,
                    returnKeyType: returnKeyType,
                    onReturn: onReturn
                )
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 0.4)
                )
                .shadow(radius: 0.7)
                .frame(height: 44)
                
                HStack {
                    Spacer()
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 12)
                    }
                }
            }
        }
    }
}

struct InputField: View {
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: UITextAutocapitalizationType = .sentences
    var submitLabel: SubmitLabel = .next
    var onSubmit: (() -> Void)? = nil
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .autocapitalization(autocapitalization)
            .submitLabel(submitLabel)
            .onSubmit {
                onSubmit?()
            }
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
