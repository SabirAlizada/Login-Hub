//
//  PasswordTextField.swift
//  Login Hub
//
//  Created by Sabir Alizada on 19.04.25.
//


import UIKit
import SwiftUI

// A Wrapper that supports secure text entry toggling and binds its content to a SwiftUI view.
struct PasswordTextFieldRepresentable: UIViewRepresentable {
    @Binding private var text: String
    private var isSecure: Bool
    private var placeholder: String
    private var returnKeyType: UIReturnKeyType
    private var onReturn: (() -> Void)?
    
    init(
        text: Binding<String>,
        isSecure: Bool,
        placeholder: String,
        returnKeyType: UIReturnKeyType = .next,
        onReturn: (() -> Void)? = nil
    ) {
        self._text = text
        self.isSecure = isSecure
        self.placeholder = placeholder
        self.returnKeyType = returnKeyType
        self.onReturn = onReturn
    }
    
    
    // MARK: - UIViewRepresentable
    // Creates and configures the UITextField instance
    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.delegate = context.coordinator
        field.isSecureTextEntry = isSecure
        field.placeholder = placeholder
        field.backgroundColor = .secondarySystemBackground
        field.enablesReturnKeyAutomatically = true
        field.returnKeyType = returnKeyType
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.autocapitalizationType = .none
        field.smartDashesType = .no
        field.smartQuotesType = .no
        field.smartInsertDeleteType = .no
        field.inputAssistantItem.leadingBarButtonGroups = []
        field.inputAssistantItem.trailingBarButtonGroups = []
        return field
    }
    
    // Updates text and secures entry state when bindings change
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.isSecureTextEntry = isSecure
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
            text.wrappedValue = textField.text ?? ""
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
                PasswordTextFieldRepresentable(
                    text: $password,
                    isSecure: !showPassword,
                    placeholder: placeholder,
                    returnKeyType: returnKeyType,
                    onReturn: onReturn
                )
                .padding(.horizontal)
                .modifier(FieldStyle())
                
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
            .modifier(FieldStyle())
    }
}

//MARK: - FieldStyle ViewModifier for consistent field appearance
private struct FieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 44)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 0.3)
            )
            .shadow(radius: 0.7)
    }
}
