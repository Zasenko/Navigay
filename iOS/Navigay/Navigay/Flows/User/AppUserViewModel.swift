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
        
        //var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
        
        var selectedEvent: Event? = nil
        
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
        let commentsNetworkManager: CommentsNetworkManagerProtocol
        let notificationsManager: NotificationsManagerProtocol
        
        //MARK: - Init
        
        init(modelContext: ModelContext,
             placeNetworkManager: PlaceNetworkManagerProtocol,
             eventNetworkManager: EventNetworkManagerProtocol,
             errorManager: ErrorManagerProtocol,
             userNetworkManager: UserNetworkManagerProtocol,
             placeDataManager: PlaceDataManagerProtocol,
             eventDataManager: EventDataManagerProtocol,
             commentsNetworkManager: CommentsNetworkManagerProtocol,
             notificationsManager: NotificationsManagerProtocol) {
            self.modelContext = modelContext
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.userNetworkManager = userNetworkManager
            self.errorManager = errorManager
            self.placeDataManager = placeDataManager
            self.eventDataManager = eventDataManager
            self.commentsNetworkManager = commentsNetworkManager
            self.notificationsManager = notificationsManager
        }
        
        func deleteAccountButtonTapped(for user: AppUser) {
            modelContext.delete(user)
        }
        
        func updateUserName(name: String, for user: AppUser) {
            Task {
                let message = "Something went wrong. Your name didn't update. Please try again later."
                do {
                    try await userNetworkManager.updateName(for: user, name: name)
                    await MainActor.run {
                        user.name = name
                    }
                } catch NetworkErrors.noConnection {
                    errorManager.showNetworkNoConnected()
                } catch NetworkErrors.apiError(let apiError) {
                    errorManager.showApiError(apiError: apiError, or: message, img: nil, color: nil)
                } catch {
                    errorManager.showError(model: ErrorModel(error: error, message: message))
                }
            }
        }
        
        func updateUserBio(bio: String?, for user: AppUser) {
            Task {
                do {
                    try await userNetworkManager.updateBio(for: user, bio: bio)
                    await MainActor.run {
                        user.bio = bio
                    }
                } catch NetworkErrors.noConnection {
                    errorManager.showNetworkNoConnected()
                } catch NetworkErrors.apiError(let apiError) {
                    errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
                } catch {
                    errorManager.showError(model: ErrorModel(error: error, message: errorManager.updateMessage))
                }
            }
        }
        
        func updatePhoto(image: UIImage, for user: AppUser) {
            self.isLoadingPhoto = true
            Task {
                let scaledImage = image.cropImage(width: 300, height: 300)
                let message = "Something went wrong. The photo didn't update. Please try again later."
                do {
                    let url = try await userNetworkManager.updatePhoto(for: user, uiImage: scaledImage)
                    await MainActor.run {
                        user.photoUrl = url
                        userImage = Image(uiImage: scaledImage)
                    }
                } catch NetworkErrors.noConnection {
                    errorManager.showNetworkNoConnected()
                } catch NetworkErrors.apiError(let apiError) {
                    errorManager.showApiError(apiError: apiError, or: message, img: AppImages.iconPhoto, color: nil)
                } catch {
                    errorManager.showError(model: ErrorModel(error: error, message: message, img: AppImages.iconPhoto))
                }
                await MainActor.run {
                    self.isLoadingPhoto = false
                }
            }
        }
        
        func deletePhoto(for user: AppUser) {
            self.isLoadingPhoto = true
            Task {
                let message = "Something went wrong. The photo didn't update. Please try again later."
                do {
                    try await userNetworkManager.deletePhoto(for: user)
                    await MainActor.run {
                        user.photoUrl = nil
                        userImage = nil
                    }
                } catch NetworkErrors.noConnection {
                    errorManager.showNetworkNoConnected()
                } catch NetworkErrors.apiError(let apiError) {
                    errorManager.showApiError(apiError: apiError, or: message, img: AppImages.iconPhoto, color: nil)
                } catch {
                    errorManager.showError(model: ErrorModel(error: error, message: message, img: AppImages.iconPhoto))
                }
                await MainActor.run {
                    self.isLoadingPhoto = false
                }
            }
        }
    }
}
