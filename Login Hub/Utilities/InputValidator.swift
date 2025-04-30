//
//  InputValidator.swift
//  Login Hub
//
//  Created by Sabir Alizada on 18.04.25.
//

import Foundation

struct InputValidator {
    static func isValidName(_ name: String) -> Bool {
        let nameRegex = "^(?!.* {2})[A-Za-zÀ-ÿ\\s'-]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return predicate.evaluate(with: name)
    }
    
    static func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^\\d{10,15}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return predicate.evaluate(with: phone)
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^(?!.*\\s)[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 8 && !password.contains(" ")
    }
}
