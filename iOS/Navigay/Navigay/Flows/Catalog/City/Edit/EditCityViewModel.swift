//
//  EditCityViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 15.11.23.
//

import SwiftUI

final class EditCityViewModel: ObservableObject {
    
    //MARK: - Properties
    let id: Int
    @Published var nameOrigin: String = ""
    @Published var nameEn: String = ""
    @Published var photo: AdminPhoto? = nil
    @Published var photos: [AdminPhoto] = []
    @Published var about: String = ""
    @Published var latitude: Double = 0
    @Published var longitude: Double = 0
    @Published var redirectCity: Int = 0
    @Published var isActive: Bool = false
    @Published var isChecked: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var isLoadingPhoto: Bool = false
    @Published var isLoadingLibraryPhoto: Bool = false
    
    @Published var showMap: Bool = false
    
    var fetched: Bool = false
    
    //MARK: - Private Properties
    
    private let user: AppUser
    private let city: City?
    
    private var countryId: Int = 0
    private var regionId: Int = 0
    
    private let errorManager: ErrorManagerProtocol
    private let networkManager: EditCityNetworkManagerProtocol
        
    // MARK: - Inits
    
    init(id: Int, city: City?, user: AppUser, errorManager: ErrorManagerProtocol, networkManager: EditCityNetworkManagerProtocol) {
        debugPrint("init EditCityViewModel city id: \(id)")
        self.errorManager = errorManager
        self.networkManager = networkManager
        self.id = id
        self.user = user
        self.city = city
    }
}

extension EditCityViewModel {
    
    //MARK: - Functions
    
    func fetchCity() {
        Task {
            guard !fetched else { return }
            do {
                let decodedCity = try await networkManager.fetchCity(id: id, user: user)
                await MainActor.run {
                    self.countryId = decodedCity.countryId
                    self.regionId = decodedCity.regionId
                    self.nameOrigin = decodedCity.nameOrigin ?? ""
                    self.nameEn = decodedCity.nameEn ?? ""
                    self.about = decodedCity.about ?? ""
                    self.longitude = decodedCity.longitude ?? 0
                    self.latitude = decodedCity.latitude ?? 0
                    self.isActive = decodedCity.isActive
                    self.isChecked = decodedCity.isChecked
                    self.photo = AdminPhoto(id: UUID().uuidString, image: nil, url: decodedCity.photo)
                    if let photos = decodedCity.photos {
                        let adminPhotos = photos.compactMap( { AdminPhoto(id: $0.id, image: nil, url: $0.url)})
                        self.photos = adminPhotos
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
        }
    }
    
    func updateInfo() {
        isLoading = true
        Task {
            do {
                try await networkManager.updateCity(id: id, name: nameEn, about: about.isEmpty ? nil : about, longitude: longitude == 0 ? nil : longitude, latitude: latitude == 0 ? nil : latitude, redirectCity: redirectCity == 0 ? nil : redirectCity, isActive: isActive, isChecked: isChecked, user: user)
                await MainActor.run {
                   
                    //todo update city
                    
                }
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: errorManager.updateMessage, img: nil, color: nil))
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
        
    func updateImage(uiImage: UIImage) {
        isLoadingPhoto = true
        Task {
            let scaledImage = uiImage.cropImage(width: 600, height: 750)
            let scaledImageSmall = uiImage.cropImage(width: 150, height: 150)
            let message = "Something went wrong. The photo didn't load. Please try again later."
            do {
                let newUrl = try await networkManager.updateCityPhoto(cityId: id, uiImage: scaledImage, uiImageSmall: scaledImageSmall, user: user)
                await MainActor.run {
                    photo = AdminPhoto(id: UUID().uuidString, image: Image(uiImage: uiImage), url: newUrl.posterUrl)
                    
                    //todo update city
                }
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: message, img: AppImages.iconPhoto, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: message, img: AppImages.iconPhoto, color: nil))
            }
            await MainActor.run {
                self.isLoadingPhoto = false
            }
        }
    }
    
    func updateLibraryPhoto(photoId: String, uiImage: UIImage) {
        isLoadingLibraryPhoto = true
        Task {
            let scaledImage = uiImage.cropImage(width: 600, height: 750)
            let message = "Something went wrong. The photo didn't load. Please try again later."
            do {
                let url = try await networkManager.updateCityLibraryPhoto(cityId: id, photoId: photoId, uiImage: scaledImage, from: user)
                if let index = photos.firstIndex(where: { $0.id == photoId }) {
                    photos[index].updateImage(image: Image(uiImage: uiImage))
                } else {
                    guard let photo = AdminPhoto(id: photoId, image: Image(uiImage: uiImage), url: url) else {
                        return
                    }
                    photos.append(photo)
                }
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: message, img: AppImages.iconPhoto, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: message, img: AppImages.iconPhoto, color: nil))
            }
            await MainActor.run {
                self.isLoadingLibraryPhoto = false
            }
        }
    }
    
    func deleteLibraryPhoto(photoId: String) {
        isLoadingLibraryPhoto = true
        Task {
            let message = "Something went wrong. The photo didn't delete. Please try again later."
            do {
                try await networkManager.deleteCityLibraryPhoto(cityId: id, photoId: photoId, from: user)
                await MainActor.run {
                    if let index = photos.firstIndex(where: { $0.id == photoId }) {
                        photos.remove(at: index)
                    }
                }
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: message, img: AppImages.iconTrashSlash, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: message, img: AppImages.iconTrashSlash, color: nil))
            }
            await MainActor.run {
                self.isLoadingLibraryPhoto = false
            }
        }
    }
}
