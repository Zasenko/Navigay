//
//  EditPlaceViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.01.24.
//

import SwiftUI

final class EditPlaceViewModel: ObservableObject {
    
    // MARK: - Properties

    let id: Int
    
    @Published var isLoading: Bool = false
    @Published var fetched: Bool = false
    
    var name: String = ""
    var type: PlaceType = .other
    var isoCountryCode: String = ""
    var address: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var tags: [Tag] = []
    var timetable: [NewWorkingDay] = []
    var otherInfo: String = ""
    var about: String = ""
    var phone: String = ""
    var email: String = ""
    var www: String = ""
    var facebook: String = ""
    var instagram: String = ""
    var isOwned: Bool = false
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
    
    let place: Place?
    let user: AppUser
    
    let networkManager: EditPlaceNetworkManagerProtocol
    let errorManager: ErrorManagerProtocol
    
    // MARK: - Inits
    
    init(id: Int, place: Place?, user: AppUser, networkManager: EditPlaceNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
        debugPrint("init EditPlaceViewModel place id: \(id)")
        self.networkManager = networkManager
        self.errorManager = errorManager
        self.user = user
        self.id = id
        self.place = place
    }
}

extension EditPlaceViewModel {
    
    // MARK: - Functions
    
    func deletePlace() {
    }
    
    func fetchPlace() {
        guard !fetched else { return }
        isLoading = true
        Task {
            do {
                let decodedPlace = try await networkManager.fetchPlace(id: id, for: user)
                await MainActor.run {
                    self.name = decodedPlace.name
                    self.type = decodedPlace.type
                    self.address = decodedPlace.address
                    self.latitude = decodedPlace.latitude
                    self.longitude = decodedPlace.longitude
                    self.tags = decodedPlace.tags ?? []
                    self.timetable = decodedPlace.timetable?.map( { NewWorkingDay(day: $0.day, opening: $0.opening.dateFromString(format: "HH:mm") ?? .now, closing: $0.closing.dateFromString(format: "HH:mm") ?? .now) } ) ?? []
                    self.otherInfo = decodedPlace.otherInfo ?? ""
                    self.about = decodedPlace.about ?? ""
                    self.phone = decodedPlace.phone ?? ""
                    self.www = decodedPlace.www ?? ""
                    self.facebook = decodedPlace.facebook ?? ""
                    self.instagram = decodedPlace.instagram ?? ""
                    self.avatar = AdminPhoto(id: UUID().uuidString, image: nil, url: decodedPlace.avatar)
                    self.mainPhoto = AdminPhoto(id: UUID().uuidString, image: nil, url: decodedPlace.mainPhoto)
                    self.email = decodedPlace.email ?? ""
                    self.isChecked = decodedPlace.isChecked
                    self.isActive = decodedPlace.isActive
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
            try await networkManager.updateActivity(placeId: id, isActive: isActive, isChecked: isChecked, adminNotes: adminNotes.isEmpty ? nil : adminNotes, user: user)
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
    
    func updateTimetable(timetable: [NewWorkingDay]) async -> Bool {
        do {
            let timetableToSend = timetable.map( { PlaceWorkDay(day: $0.day, opening: $0.opening.format("HH:mm"), closing: $0.closing.format("HH:mm")) } )
            try await networkManager.updateTimetable(placeId: id, timetable: timetableToSend.isEmpty ? nil : timetableToSend, for: user)
            await MainActor.run {
                self.timetable = timetable
                //todo!!!!!! обновить в базе данных
               // place?.timetable =
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
    
    
    func updateAdditionalInformation(email: String?, phone: String?, www: String?, facebook: String?, instagram: String?, otherInfo: String?, tags: [Tag]?) async -> Bool {
            do {
                try await networkManager.updateAdditionalInformation(placeId: id, email: email, phone: phone, www: www, facebook: facebook, instagram: instagram, otherInfo: otherInfo, tags: tags, for: user)
                await MainActor.run {
                    self.phone = phone ?? ""
                    self.www = www ?? ""
                    self.facebook = facebook ?? ""
                    self.instagram = instagram ?? ""
                    self.otherInfo = otherInfo ?? ""
                    self.tags = tags ?? []
                    self.email = email ?? ""
                    place?.phone = phone
                    place?.www = www
                    place?.facebook = facebook
                    place?.instagram = instagram
                    place?.otherInfo = otherInfo
                    place?.tags = tags ?? []
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
    
    func updateTitleAndType(name: String, type: PlaceType) async -> Bool {
            do {
                try await networkManager.updateTitleAndType(id: id, name: name, type: type, for: user)
                await MainActor.run {
                    self.name = name
                    self.type = type
                    place?.name = name
                    place?.type = type
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
                try await networkManager.updateAbout(id: id, about: about.isEmpty ? nil : about, for: user)
                await MainActor.run {
                    self.about = about
                    place?.about = about
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
                try await networkManager.deleteLibraryPhoto (placeId: id, photoId: photoId, from: user)
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
                let url = try await networkManager.updateAvatar(placeId: id, uiImage: scaledImage, from: user)
                await MainActor.run {
                    if avatar != nil {
                        avatar?.updateImage(image: Image(uiImage: uiImage))
                    } else {
                        avatar = AdminPhoto(id: UUID().uuidString, image: Image(uiImage: uiImage), url: url)
                    }
                    place?.avatar = url
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
            let url = try await networkManager.updateMainPhoto(placeId: id, uiImage: scaledImage, from: user)
            await MainActor.run {
                if mainPhoto != nil {
                    mainPhoto?.updateImage(image: Image(uiImage: uiImage))
                } else {
                    mainPhoto = AdminPhoto(id: UUID().uuidString, image: Image(uiImage: uiImage), url: url)
                }
                place?.mainPhoto = url
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
                let url = try await networkManager.updateLibraryPhoto(placeId: id, photoId: photoId, uiImage: scaledImage, from: user)
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
