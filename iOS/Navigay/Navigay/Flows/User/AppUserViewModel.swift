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
                guard let sessionKey = user.sessionKey else { return }
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
                let result = await userNetworkManager.updateUserBio(id: user.id, bio: bio, key: sessionKey)
                await MainActor.run {
                    if result {
                        user.bio = bio
                    } else {
                        
                    }
                }
            }
        }
        
        func updatePhoto(image: UIImage, for user: AppUser) {
            self.isLoadingPhoto = true
            Task {
                guard let sessionKey = user.sessionKey else { return }
                let scaledImage = image.cropImage(width: 300, height: 300)
                //let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
                do {
                    let decodedResult = try await userNetworkManager.updateUserPhoto(id: user.id, uiImage: scaledImage, key: sessionKey)
                    guard decodedResult.result, let url = decodedResult.url else {
                   //     errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                        
                        print(decodedResult.error?.message ?? "")
                        throw NetworkErrors.apiErrorTest
                    }
                    await MainActor.run {
                        self.isLoadingPhoto = false
                        user.photo = url
                        userImage = Image(uiImage: scaledImage)
                    }
                } catch {
                    debugPrint("ERROR - updatePhoto: ", error)
                   // errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
                    await MainActor.run {
                        self.isLoadingPhoto = false
                      //  self.photo = previousImage
                    }
                }
            }
        }
        
        func deletePhoto(for user: AppUser) {
            self.isLoadingPhoto = true
            Task {
                guard let sessionKey = user.sessionKey else { return }
                //let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
                do {
                    try await userNetworkManager.deleteUserPhoto(id: user.id, key: sessionKey)
                    await MainActor.run {
                        self.isLoadingPhoto = false
                        user.photo = nil
                        userImage = nil
                    }
                } catch {
                    debugPrint("ERROR - deletePhoto: ", error)
                   // errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
                    await MainActor.run {
                        self.isLoadingPhoto = false
                      //  self.photo = previousImage
                    }
                }
            }
        }
    }
}
