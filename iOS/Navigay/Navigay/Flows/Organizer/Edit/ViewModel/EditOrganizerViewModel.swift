//
//  EditOrganizerViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.09.24.
//

import SwiftUI

final class EditOrganizerViewModel: ObservableObject {
    
    // MARK: - Properties

    let id: Int
    
    @Published var isLoading: Bool = false
    @Published var fetched: Bool = false
    
    var name: String = ""
    var isoCountryCode: String = ""
    var about: String = ""
    var otherInfo: String = ""
    var phone: String = ""
    var email: String = ""
    var www: String = ""
    var facebook: String = ""
    var instagram: String = ""
 //   var isOwned: Bool = false
    var isActive: Bool = false
    var isChecked: Bool = false
    var adminNotes: String = ""
    @Published var avatar: AdminPhoto?
    @Published var mainPhoto: AdminPhoto?
    @Published var photos: [AdminPhoto] = []
    
    var countryOrigin: String? = nil
    var countryEnglish: String? = nil
    var regionOrigin: String? = nil
    var regionEnglish: String? = nil
    var cityOrigin: String? = nil
    var cityEnglish: String? = nil
        
    // images
    @Published var avatarLoading: Bool = false
    @Published var mainPhotoLoading: Bool = false
    @Published var libraryPhotoLoading: Bool = false
    
    @Published var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
    
    @Published var showDeleteSheet: Bool = false
    
    let organizer: Organizer?
    let user: AppUser
    
    let networkManager: EditOrganizerNetworkManagerProtocol
    let errorManager: ErrorManagerProtocol
    
    // MARK: - Inits
    
    init(id: Int, organizer: Organizer?, user: AppUser, networkManager: EditOrganizerNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
        self.networkManager = networkManager
        self.errorManager = errorManager
        self.user = user
        self.id = id
        self.organizer = organizer
    }
}

extension EditOrganizerViewModel {
    
    // MARK: - Functions
    
    func delete() {
    }
    
    func fetch() {
        guard !fetched else { return }
        isLoading = true
        Task {
            do {
                let decodedPlace = try await networkManager.fetch(organizerId: id, for: user)
                await MainActor.run {
                    self.name = decodedPlace.name
                    self.otherInfo = decodedPlace.otherInfo ?? ""
                    self.about = decodedPlace.about ?? ""
                    self.phone = decodedPlace.phone ?? ""
                    self.www = decodedPlace.www ?? ""
                    self.facebook = decodedPlace.facebook ?? ""
                    self.instagram = decodedPlace.instagram ?? ""
                    self.avatar = AdminPhoto(id: UUID().uuidString, image: nil, url: decodedPlace.avatar)
                    self.mainPhoto = AdminPhoto(id: UUID().uuidString, image: nil, url: decodedPlace.mainPhoto)
                    self.email = decodedPlace.email ?? ""
                    if user.status == .admin || user.status == .moderator {
                        self.adminNotes = decodedPlace.adminNotes ?? ""
                        self.isChecked = decodedPlace.isChecked
                        self.isActive = decodedPlace.isActive
                    }
                    if let photos = decodedPlace.photos, !photos.isEmpty {
                        let adminPhotos = photos.compactMap( { AdminPhoto(id: $0.id, image: nil, url: $0.url)})
                        self.photos = adminPhotos
                    } else {
                        self.photos = []
                    }
                    self.fetched = true
                }
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: errorManager.errorMessage, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: errorManager.errorMessage, img: nil, color: nil))
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    func updateActivity(isActive: Bool, isChecked: Bool, adminNotes: String) async -> Bool {
        do {
            try await networkManager.updateActivity(organizerId: id, isActive: isActive, isChecked: isChecked, adminNotes: adminNotes.isEmpty ? nil : adminNotes, user: user)
            await MainActor.run {
                self.isActive = isActive
                self.isChecked = isChecked
                self.adminNotes = adminNotes
            }
            return true
        } catch NetworkErrors.noConnection {
            errorManager.showNetworkNoConnected()
        } catch NetworkErrors.apiError(let apiError) {
            errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
        } catch {
            errorManager.showError(model: ErrorModel(error: error, message: errorManager.updateMessage, img: nil, color: nil))
        }
        return false
    }
    
    func updateAdditionalInformation(email: String?, phone: String?, www: String?, facebook: String?, instagram: String?, otherInfo: String?) async -> Bool {
            do {
                try await networkManager.updateAdditionalInformation(organizerId: id, email: email, phone: phone, www: www, facebook: facebook, instagram: instagram, otherInfo: otherInfo, for: user)
                await MainActor.run {
                    self.phone = phone ?? ""
                    self.www = www ?? ""
                    self.facebook = facebook ?? ""
                    self.instagram = instagram ?? ""
                    self.otherInfo = otherInfo ?? ""
                    self.email = email ?? ""
                    organizer?.phone = phone
                    organizer?.www = www
                    organizer?.facebook = facebook
                    organizer?.instagram = instagram
                    organizer?.otherInfo = otherInfo
                }
                return true
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: errorManager.updateMessage, img: nil, color: nil))
            }
            return false
    }
    
    func updateTitle(name: String) async -> Bool {
            do {
                try await networkManager.updateTitle(organizerId: id, name: name, for: user)
                await MainActor.run {
                    self.name = name
                    organizer?.name = name
                }
                return true
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: errorManager.updateMessage, img: nil, color: nil))
            }
            return false
    }
    
    func updateAbout(about: String) async -> Bool {
            do {
                try await networkManager.updateAbout(organizerId: id, about: about.isEmpty ? nil : about, for: user)
                await MainActor.run {
                    self.about = about
                    organizer?.about = about
                }
                return true
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: errorManager.updateMessage, img: nil, color: nil))
            }
            return false
    }
    
    func deleteLibraryPhoto(photoId: String) {
        libraryPhotoLoading = true
        Task {
            let message = "Something went wrong. The photo didn't delete. Please try again later."
            do {
                try await networkManager.deleteLibraryPhoto(organizerId: id, photoId: photoId, from: user)
                await MainActor.run {
                    if let photoIndex = photos.firstIndex(where: { $0.id == photoId }) {
                        photos.remove(at: photoIndex)
                    }
                }
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: message, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: message, img: AppImages.iconPhoto, color: nil))
            }
            await MainActor.run {
                self.libraryPhotoLoading = false
            }
        }
    }
    
    func updateAvatar(uiImage: UIImage) {
        avatarLoading = true
        Task {
            let message = "Something went wrong. The photo didn't load. Please try again later."
            let scaledImage = uiImage.cropImage(width: 150, height: 150)
            do {
                let url = try await networkManager.updateAvatar(organizerId: id, uiImage: scaledImage, from: user)
                await MainActor.run {
                    if avatar != nil {
                        avatar?.updateImage(image: Image(uiImage: uiImage))
                    } else {
                        avatar = AdminPhoto(id: UUID().uuidString, image: Image(uiImage: uiImage), url: url)
                    }
                    organizer?.avatarUrl = url
                    organizer?.avatar = Image(uiImage: uiImage)
                }
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: message, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: message, img: AppImages.iconPhoto, color: nil))
            }
            await MainActor.run {
                avatarLoading = false
            }
        }
    }
    
    func updateMainPhoto(uiImage: UIImage) {
    mainPhotoLoading = true
    Task {
        let message = "Something went wrong. The photo didn't load. Please try again later."
        let scaledImage = uiImage.cropImage(width: 600, height: 750)
        do {
            let url = try await networkManager.updateMainPhoto(organizerId: id, uiImage: scaledImage, from: user)
            await MainActor.run {
                if mainPhoto != nil {
                    mainPhoto?.updateImage(image: Image(uiImage: uiImage))
                } else {
                    mainPhoto = AdminPhoto(id: UUID().uuidString, image: Image(uiImage: uiImage), url: url)
                }
                organizer?.mainPhotoUrl = url
                organizer?.mainPhoto = Image(uiImage: uiImage)
            }
        } catch NetworkErrors.noConnection {
            errorManager.showNetworkNoConnected()
        } catch NetworkErrors.apiError(let apiError) {
            errorManager.showApiError(apiError: apiError, or: message, img: nil, color: nil)
        } catch {
            errorManager.showError(model: ErrorModel(error: error, message: message, img: AppImages.iconPhoto, color: nil))
        }
        await MainActor.run {
            self.mainPhotoLoading = false
        }
    }
}
    
    func updateLibraryPhoto(uiImage: UIImage, photoId: String) {
        libraryPhotoLoading = true
        Task {
            let scaledImage = uiImage.cropImage(width: 600, height: 750)
            let message = "Something went wrong. The photo didn't load. Please try again later."
            do {
                let url = try await networkManager.updateLibraryPhoto(organizerId: id, photoId: photoId, uiImage: scaledImage, from: user)
                await MainActor.run {
                    if let photoIndex = photos.firstIndex(where: { $0.id == photoId }) {
                        photos[photoIndex].updateImage(image: Image(uiImage: uiImage))
                    } else {
                        guard let photo = AdminPhoto(id: photoId, image: Image(uiImage: uiImage), url: url) else { return }
                        photos.append(photo)
                    }
                }
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: message, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: message, img: AppImages.iconPhoto, color: nil))
            }
            await MainActor.run {
                self.libraryPhotoLoading = false
            }
        }
    }
}
