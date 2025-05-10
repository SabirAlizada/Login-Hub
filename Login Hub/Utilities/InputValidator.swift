//
//  InputValidator.swift
//  Login Hub
//
//  Created by Sabir Alizada on 18.04.25.
//

import Foundation

/// Utility for validating common input types with regex and simple rules.
struct InputValidator {
    // MARK: - Regex Patterns
    private static let namePattern  = "^(?!.* {2})[A-Za-zÀ-ÿ\\s'-]{2,}$"
    private static let emailPattern = "^(?!.*\\s)[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    private static let phonePattern = "^\\d{10,15}$"
    
    // MARK: - Name Validation
    /// Validates that the name is at least two characters, allows letters, spaces, hyphens, apostrophes, and no consecutive spaces.
    
    static func isValidName(_ name: String) -> Bool {
        let value = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let predicate = NSPredicate(format: "SELF MATCHES %@", namePattern)
        return predicate.evaluate(with: value)
    }
    
    // MARK: - Phone Number Validation
    /// Validates that the phone number consists of 10 to 15 digits, no spaces or formatting.
    static func isValidPhoneNumber(_ phone: String) -> Bool {
        let value = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let predicate = NSPredicate(format: "SELF MATCHES %@", phonePattern)
        return predicate.evaluate(with: value)
    }
    
    // MARK: - Email Validation
    /// Validates standard email format, disallowing any whitespace.
    static func isValidEmail(_ email: String) -> Bool {
        let value = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        return predicate.evaluate(with: value)
    }
    
    // MARK: - Password Validation
    /// Validates that the password is at least 8 characters and contains no spaces.
    static func isValidPassword(_ password: String) -> Bool {
        let value = password.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.count >= 8 && !value.contains(" ")
    }
}
