//
//  SignupContentView.swift
//  Login Hub
//
//  Created by Sabir Alizada on 24.03.25.
//
/*
 Purpose: Manages user input for sign-up, handling focus, validation, and form submission.
 */

import SwiftUI

// MARK: - ViewModel & State Properties
struct SignupContentView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword = false
    @State private var phoneNumber: String = ""
    @State private var birthDate: Date = Date()
    @State private var studentID: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isEmailEmpty = true
    let viewModel: SocialLoginViewModel
    
    // MARK: - Focus Enums
    enum Field: Hashable {
        case firstName, lastName, email, password, phone, studentId
    }
    
    @FocusState private var focusedField: Field?
    
    private var maxBirthDate: Date {
        // Subtract 16 years from the current date
        Calendar.current.date(byAdding: .year, value: -16, to: Date()) ?? Date()
    }
    
    // MARK: - Computed Properties
    /// Whether all required fields are valid to enable the Sign Up button
    private var canSubmit: Bool {
        InputValidator.isValidName(firstName)
        && InputValidator.isValidName(lastName)
        && InputValidator.isValidEmail(email)
        && InputValidator.isValidPassword(password)
        && InputValidator.isValidPhoneNumber(phoneNumber)
    }
    
    // MARK: - Name Fields
    private var nameFields: some View {
        HStack(spacing: 20) {
            InputField(text: $firstName, placeholder: "First name")
                .focused($focusedField, equals: .firstName)
            InputField(text: $lastName, placeholder: "Last name")
                .focused($focusedField, equals: .lastName)
        }
    }
    
    // MARK: - Email Field
    private var emailField: some View {
        InputField(
            text: $email,
            placeholder: "Email",
            keyboardType: .emailAddress,
            textContentType: .none,
            autocapitalization: .none,
        )
        .focused($focusedField, equals: .email)
    }
    
    // MARK: - Password Field
    private var passwordField: some View {
        PasswordTextField(
            password: $password,
            showPassword: $showPassword,
            placeholder: "Password (min 8 characters)",
            onReturn: { focusedField = .phone }
        )
        .focused($focusedField, equals: .password)
        .textContentType(.password)
    }
    
    // MARK: - Phone Field
    private var phoneField: some View {
        InputField(
            text: $phoneNumber,
            placeholder: "Phone number",
            keyboardType: .numberPad
        )
        .focused($focusedField, equals: .phone)
    }
    
    // MARK: - Birth Date Field
    private var birthDateField: some View {
        DatePickerField(
            title: "Birth Date",
            selection: $birthDate,
            maximumDate: maxBirthDate
        )
    }
    
    // MARK: - Student ID Field
    private var studentIDField: some View {
        InputField(
            text: $studentID,
            placeholder: "Student ID (if applicable)",
            keyboardType: .phonePad,
            submitLabel: .return
        )
        .focused($focusedField, equals: .studentId)
    }
    
    // MARK: - Action Section
    private var signUpButtonSection: some View {
        Button {
            viewModel.signUp(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName,
                phoneNumber: phoneNumber,
                birthDate: birthDate
            )
        } label: {
            Text("Sign up")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: 48)
                .background(canSubmit ? Color.blue : Color.gray)
                .cornerRadius(10)
        }
        .disabled(!canSubmit)
        .opacity(canSubmit ? 1 : 0.5)
        .shadow(radius: 2)
        .padding(.bottom, 20)
        .onChange(of: viewModel.userProfile) { _, profile in
            if profile != nil {
                alertMessage = "Registration successful! Please log in with your credentials."
                showAlert = true
            }
        }
        .onChange(of: viewModel.errorMessage) { _, error in
            if let error = error {
                alertMessage = error
                showAlert = true
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            nameFields
            emailField
            passwordField
            phoneField
            birthDateField
            studentIDField
            signUpButtonSection
        }
        .padding(.horizontal, 16)
        .onSubmit {
            switch focusedField {
                case .firstName:
                    focusedField = .lastName
                case .lastName:
                    focusedField = .email
                case .email:
                    focusedField = .password
                case .password:
                    focusedField = .phone
                case .phone:
                    focusedField = .studentId
                case .studentId:
                    focusedField = nil
                case .none:
                    break
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Sign Up"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct DatePickerField: View {
    var title: String
    @Binding var selection: Date
    var maximumDate: Date
    
    var body: some View {
        DatePicker(
            title,
            selection: $selection,
            in: ...maximumDate,
            displayedComponents: .date
        )
        .datePickerStyle(.compact)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
        .background(Color(.secondarySystemBackground))
    }
}
