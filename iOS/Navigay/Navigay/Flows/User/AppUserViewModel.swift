//
//  AppUserViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 30.01.24.
//

import SwiftUI
import SwiftData

extension AppUserView {
    
    @Observable
    class AppUserViewModel {
        
        var userImage: Image? = nil
        var isLoadingPhoto: Bool = false
        
        var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
        
        var showEditNameView: Bool = false
        var showEditBioView: Bool = false
        
        var showLoginView: Bool = false
        var showRegistrationView: Bool = false
        
        var modelContext: ModelContext
        let eventNetworkManager: EventNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let userNetworkManager: UserNetworkManagerProtocol
        
        let errorManager: ErrorManagerProtocol
        
        init(modelContext: ModelContext, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol, userNetworkManager: UserNetworkManagerProtocol) {
            self.modelContext = modelContext
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.userNetworkManager = userNetworkManager
            self.errorManager = errorManager
        }
        
        func logoutButtonTapped() {
            
        }
        
        func deleteAccountButtonTapped() {
            
        }
        
        func updateUserName() {
            
        }
        
        func updateUserBio() {
            
        }
        
        func changePassword() {
            
        }
    }
}
