//
//  RegistrationViewModel.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import SwiftUI

final class RegistrationViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    @Published var email = ""
    @Published var password = ""
    @Published var isEmailValid = false
    @Published var isPasswordCountValid = false
    @Published var isPasswordNumberValid = false
    @Published var isPasswordLetterValid = false
    var isFormValid: Bool {
        isEmailValid && isPasswordCountValid && isPasswordNumberValid && isPasswordLetterValid
    }
    var allViewsDisabled = false
    var buttonState: ButtonStates = .normal
    
    // MARK: - Private Properties

    private let validator = AuthValidator()

    // MARK: - Init
    
    init(isPresented: Binding<Bool>) {
        _isPresented = isPresented
    }
}

extension RegistrationViewModel {
    
    // MARK: - Functions

    func validateEmail() async {
        let result = await validator.validateEmail(email)
        await MainActor.run {
            self.isEmailValid = result
        }
    }
    
    func validatePassword() async {
        let result = await validator.validatePassword(password)
        await MainActor.run {
            self.isPasswordCountValid = result.isCountValid
            self.isPasswordNumberValid = result.containsNumber
            self.isPasswordLetterValid = result.containsLetter
        }
    }
}
