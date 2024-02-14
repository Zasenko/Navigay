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
        
        func updateUserName(name: String, for user: AppUser) {
            Task {
                guard let sessionKey = user.sessionKey else { return }
                let oldName = user.name
                let result = await userNetworkManager.updateUserName(id: user.id, name: name, key: sessionKey)
                await MainActor.run {
                    if result {
                        user.name = name
                    } else {
                        
                    }
                }
            }
        }
        
        func updateUserBio(bio: String?, for user: AppUser) {
            Task {
                guard let sessionKey = user.sessionKey else { return }
                let oldBio = user.bio
                let result = await userNetworkManager.updateUserBio(id: user.id, bio: bio, key: sessionKey)
                await MainActor.run {
                    if result {
                        user.bio = bio
                    } else {
                        
                    }
                }
            }
        }
        
        func changePassword() {
            
        }
    }
}
