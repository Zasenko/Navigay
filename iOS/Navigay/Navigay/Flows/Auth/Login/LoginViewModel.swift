//
//  LoginViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 05.12.23.
//

import SwiftUI
import Combine

final class LoginViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var email = ""
    @Published var password = ""
    @Published var allViewsDisabled = false
    
    @Published var buttonState: ButtonStates = .normal
    @Published var isButtonValid = false
    
    @Published var showForgetPasswordView = false
    
    // MARK: - Private Properties
        
    // MARK: - Inits
    
    init(email: String? = nil) {
        
        if let email {
            self.email = email
        }
        
        isAuthFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: &$isButtonValid)
    }
}

private extension LoginViewModel {
    
    var isUserEmailValidPublisher: AnyPublisher<Bool, Never> {
        $email
            .map { email in
                let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
                return emailPredicate.evaluate(with: email)
            }
            .eraseToAnyPublisher()
    }
    
    var isPasswordValidPublisher: AnyPublisher<Bool, Never> {
        $password
            .map { password in
                return password.count >= 8 && (NSPredicate(format: "SELF MATCHES %@", ".*[0-9]+.*").evaluate(with: password)) && (NSPredicate(format:"SELF MATCHES %@", ".*[a-z]+.*").evaluate(with: password))
            }
            .eraseToAnyPublisher()
    }
    
    var isAuthFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isUserEmailValidPublisher, isPasswordValidPublisher)
            .map { isEmailValid, isPasswordValid in
                return isEmailValid && isPasswordValid
            }
            .eraseToAnyPublisher()
    }
}
