//
//  AuthValidator.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 01.07.24.
//

import Foundation

final class AuthValidator {}

extension AuthValidator {

    func validateEmail(_ value: String) async -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}").evaluate(with: value)
    }
    
    func validatePassword(_ value: String) async -> (isCountValid: Bool, containsNumber: Bool, containsLetter: Bool) {
        let isCountValid = value.count >= 8 && value.count <= 16
        let containsNumber = NSPredicate(format: "SELF MATCHES %@", ".*[0-9]+.*").evaluate(with: value)
        let containsLetter = NSPredicate(format: "SELF MATCHES %@", ".*[a-zA-Z]+.*").evaluate(with: value)
        return (isCountValid, containsNumber, containsLetter)
    }
}
