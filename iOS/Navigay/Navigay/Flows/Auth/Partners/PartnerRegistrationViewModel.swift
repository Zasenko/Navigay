//
//  PartnerRegistrationViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 01.10.24.
//

import SwiftUI

enum PartnerType: Int, Codable, CaseIterable {
    case location = 1
    case organizer = 2
}

final class PartnerRegistrationViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    @Published var email = ""
    @Published var password = ""
    @Published var type: PartnerType = .location
    
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

extension PartnerRegistrationViewModel {
    
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
