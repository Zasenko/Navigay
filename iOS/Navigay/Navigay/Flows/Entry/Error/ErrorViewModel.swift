//
//  ErrorViewModel.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import SwiftUI

final class ErrorViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var errors: [ErrorModel] = []
    var errorManager: ErrorManagerProtocol
    
    // MARK: - Inits
    
    init(errorManager: ErrorManagerProtocol) {
        self.errorManager = errorManager
        observeErrors()
    }
}

// MARK: - Private Functions

extension ErrorViewModel {
    
    private func observeErrors() {
        errorManager.getError = { [weak self] error in
            guard let self = self else {return}
            DispatchQueue.main.async {
                withAnimation {
                    self.errors.append(error)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    self.errors.removeAll(where: { $0.id == error.id })
                }
            }
        }
    }
}
