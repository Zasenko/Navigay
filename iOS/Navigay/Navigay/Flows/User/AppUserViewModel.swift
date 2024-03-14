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
        
        var showTitle: Bool = false
        
        var showEditNameView: Bool = false
        var showEditBioView: Bool = false
        
        var showLoginView: Bool = false
        var showRegistrationView: Bool = false
        var showResetPasswordView: Bool = false
        
        var showDeleteAccountAlert: Bool = false
        
        var modelContext: ModelContext
        let eventNetworkManager: EventNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let userNetworkManager: UserNetworkManagerProtocol
        let placeDataManager: PlaceDataManagerProtocol
        let eventDataManager: EventDataManagerProtocol
        let errorManager: ErrorManagerProtocol
        
        //MARK: - Init
        
        init(modelContext: ModelContext,
             placeNetworkManager: PlaceNetworkManagerProtocol,
             eventNetworkManager: EventNetworkManagerProtocol,
             errorManager: ErrorManagerProtocol,
             userNetworkManager: UserNetworkManagerProtocol,
             placeDataManager: PlaceDataManagerProtocol,
             eventDataManager: EventDataManagerProtocol) {
            self.modelContext = modelContext
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.userNetworkManager = userNetworkManager
            self.errorManager = errorManager
            self.placeDataManager = placeDataManager
            self.eventDataManager = eventDataManager
        }
        
        func deleteAccountButtonTapped(for user: AppUser) {
            modelContext.delete(user)
        }
        
        func updateUserName(name: String, for user: AppUser) {
            Task {
                let errorModel = ErrorModel(massage: "Something went wrong. Your name didn't update. Please try again later.", img: nil, color: .red)
                do {
                    try await userNetworkManager.updateName(for: user, name: name)
                    await MainActor.run {
                        user.name = name
                    }
                } catch NetworkErrors.apiError(let error) {
                    errorManager.showApiErrorOrMessage(apiError: error, or: errorModel)
                } catch {
                    errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
                }
            }
        }
        
        func updateUserBio(bio: String?, for user: AppUser) {
            Task {
                let errorModel = ErrorModel(massage: "Something went wrong. The information didn't update. Please try again later.", img: nil, color: .red)
                do {
                    try await userNetworkManager.updateBio(for: user, bio: bio)
                    await MainActor.run {
                        user.bio = bio
                    }
                } catch NetworkErrors.apiError(let error) {
                    errorManager.showApiErrorOrMessage(apiError: error, or: errorModel)
                } catch {
                    errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
                }
            }
        }
        
        func updatePhoto(image: UIImage, for user: AppUser) {
            self.isLoadingPhoto = true
            Task {
                let scaledImage = image.cropImage(width: 300, height: 300)
                let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't update. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
                do {
                    let url = try await userNetworkManager.updatePhoto(for: user, uiImage: scaledImage)
                    await MainActor.run {
                        user.photo = url
                        userImage = Image(uiImage: scaledImage)
                    }
                } catch NetworkErrors.apiError(let error) {
                    errorManager.showApiErrorOrMessage(apiError: error, or: errorModel)
                } catch {
                    errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
                }
                await MainActor.run {
                    self.isLoadingPhoto = false
                }
            }
        }
        
        func deletePhoto(for user: AppUser) {
            self.isLoadingPhoto = true
            Task {
                let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't delete. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
                do {
                    try await userNetworkManager.deletePhoto(for: user)
                    await MainActor.run {
                        user.photo = nil
                        userImage = nil
                    }
                } catch NetworkErrors.apiError(let error) {
                    errorManager.showApiErrorOrMessage(apiError: error, or: errorModel)
                } catch {
                    errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
                }
                await MainActor.run {
                    self.isLoadingPhoto = false
                }
            }
        }
    }
}
