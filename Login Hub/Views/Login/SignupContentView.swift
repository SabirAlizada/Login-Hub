//
//  SignupContentView.swift
//  Login Hub
//
//  Created by Sabir Alizada on 24.03.25.
//

import SwiftUI

struct SignupContentView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword = false
    @State private var phoneNumber: String = ""
    @State private var birthDate: Date = Date()
    @State private var studentID: String = ""
    let viewModel: SocialLoginViewModel
    
    enum Field: Hashable {
        case firstName, lastName, email, password, phone, studentId
    }
    
    @FocusState private var focusedField: Field?
    
    private var maxBirthDate: Date {
        // Subtract 16 years from the current date
        Calendar.current.date(byAdding: .year, value: -16, to: Date()) ?? Date()
    }
    
    var body: some View {
        let canSubmit = InputValidator.isValidName(firstName)
        && InputValidator.isValidName(lastName)
        && InputValidator.isValidEmail(email)
        && InputValidator.isValidPassword(password)
        && InputValidator.isValidPhoneNumber(phoneNumber)
        
        VStack(spacing: 30) {
            HStack(spacing: 20) {
                InputField(text: $firstName, placeholder: "First name")
                    .focused($focusedField, equals: .firstName)
                InputField(text: $lastName, placeholder: "Last name")
                    .focused($focusedField, equals: .lastName)
            }
            
            InputField(
                text: $email,
                placeholder: "Email",
                keyboardType: .emailAddress,
                autocapitalization: .none)
            .focused($focusedField, equals: .email)
            
            PasswordTextField(
                password: $password,
                showPassword: $showPassword,
                placeholder: "Password (min 8 characters)",
                onReturn: { focusedField = .phone }
            )
            .focused($focusedField, equals: .password)
            
            InputField(
                text: $phoneNumber,
                placeholder: "Phone number",
                keyboardType: .numberPad)
            .focused($focusedField, equals: .phone)
            
            DatePickerField(
                title: "Birth Date",
                selection: $birthDate,
                maximumDate: maxBirthDate)
            
            InputField(text: $studentID,
                       placeholder: "Student ID (if applicable)",
                       keyboardType: .phonePad,
                       submitLabel: .return)
            .focused($focusedField, equals: .studentId)
            
            Button {
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
            .frame(maxWidth: .infinity, minHeight: 48)
            .shadow(radius: 2)
            .padding(.bottom, 20)
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
