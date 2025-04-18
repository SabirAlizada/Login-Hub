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
    
    private var maxBirthDate: Date {
        // Subtract 16 years from the current date
        Calendar.current.date(byAdding: .year, value: -16, to: Date()) ?? Date()
    }
    
    var body: some View {
        let canSubmit = !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !password.isEmpty && !phoneNumber.isEmpty
        
        VStack(spacing: 20) {
            HStack {
                InputField(text: $firstName, placeholder: "First name")
                InputField(text: $lastName, placeholder: "Last name")
            }
            
            InputField(
                text: $email,
                placeholder: "Email",
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .none)
            
            PasswordField(password: $password, showPassword: $showPassword)
            
            InputField(
                text: $phoneNumber,
                placeholder: "Phone number",
                keyboardType: .numberPad)
            
            DatePickerField(
                title: "Birth Date",
                selection: $birthDate,
                maximumDate: maxBirthDate)
            
            InputField(text: $studentID, placeholder: "Student ID (if applicable)")
            
            Button {
            } label: {
                Text("Sign up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 48)
                    .background(canSubmit ? Color.blue : Color.gray)                    .cornerRadius(10)
            }
            .disabled(!canSubmit)
            .opacity(canSubmit ? 1 : 0.5)
            .frame(maxWidth: .infinity, minHeight: 48)
            .shadow(radius: 2)
            .padding()
        }
        .padding()
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
    }
}
