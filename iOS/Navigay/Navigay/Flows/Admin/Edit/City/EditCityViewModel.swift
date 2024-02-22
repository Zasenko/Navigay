//
//  EditCityViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 15.11.23.
//

import SwiftUI

struct AdminPhoto: Identifiable, Equatable {
    
    let id: String
    var image: Image?
    let url: String?
    
        
    init?(id: String, image: Image?, url: String?) {
        if image == nil && url == nil {
            return nil
        }
        self.id = id
        self.image = image
        self.url = url
    }
    
    mutating func updateImage(image: Image) {
        self.image = image
    }
    
    static func ==(lhs: AdminPhoto, rhs: AdminPhoto) -> Bool {
        return lhs.id == rhs.id
    }
}


final class EditCityViewModel: ObservableObject {
    
    //MARK: - Properties

    @Published var nameOrigin: String = ""
    @Published var nameEn: String = ""
    @Published var photo: AdminPhoto? = nil
    @Published var photos: [AdminPhoto] = []
    @Published var about: String = ""
    @Published var isActive: Bool = false
    @Published var isChecked: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var isLoadingPhoto: Bool = false
    @Published var isLoadingLibraryPhoto: Bool = false
    
    var isFetched: Bool = false
    
    //MARK: - Private Properties
    
    private let id: Int
    private let userId: Int
    
    private var countryId: Int = 0
    private var regionId: Int = 0
    
    private let errorManager: ErrorManagerProtocol
    private let networkManager: AdminNetworkManagerProtocol
    
    private let loadErrorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
    private let deleteErrorModel = ErrorModel(massage: "Something went wrong. The photo didn't delete. Please try again later.", img: Image(systemName: "trash.slash.fill"), color: .red)
        
    // MARK: - Inits
    
    init(id: Int, userId: Int, errorManager: ErrorManagerProtocol, networkManager: AdminNetworkManagerProtocol) {
        debugPrint("init EditCityViewModel city id: \(id)")
        self.errorManager = errorManager
        self.networkManager = networkManager
        self.id = id
        self.userId = userId
    }
}

extension EditCityViewModel {
    
    //MARK: - Functions
    
    func fetchCity() async -> Bool {
        guard !isFetched else {
            return true
        }
        guard let decodedCity = await networkManager.fetchCity(id: id) else {
            return false
        }
        await MainActor.run {
            self.isFetched = true
            self.countryId = decodedCity.countryId
            self.regionId = decodedCity.regionId
            self.nameOrigin = decodedCity.nameOrigin ?? ""
            self.nameEn = decodedCity.nameEn ?? ""
            self.about = decodedCity.about ?? ""
            self.isActive = decodedCity.isActive
            self.isChecked = decodedCity.isChecked
            self.photo = AdminPhoto(id: UUID().uuidString, image: nil, url: decodedCity.photo)
            if let photos = decodedCity.photos, !photos.isEmpty {
                let adminPhotos = photos.compactMap( { AdminPhoto(id: $0.id, image: nil, url: $0.url)})
                self.photos = adminPhotos
            } else {
                self.photos = []
            }
        }
        return true
    }
    
    func updateInfo() async -> Bool {
        await MainActor.run {
            isLoading = true
        }
        
        let city: AdminCity = AdminCity(id: id,
                                        countryId: countryId,
                                        regionId: regionId,
                                        nameOrigin: nameOrigin.isEmpty ? nil : nameOrigin,
                                        nameEn: nameEn.isEmpty ? nil : nameEn,
                                        about: about.isEmpty ? nil : about,
                                        photo: nil,
                                        photos: nil,
                                        isActive: isActive,
                                        isChecked: isChecked,
                                        userId: userId)
        let result = await networkManager.updateCity(city: city)
        await MainActor.run {
            isLoading = false
        }
        if result {
            return true
        } else {
            return false
        }
    }
    
    func loadImage(uiImage: UIImage) {
        isLoadingPhoto = true
        let previousImage = photo
        photo = AdminPhoto(id: UUID().uuidString, image: Image(uiImage: uiImage), url: nil)
        updateImage(uiImage: uiImage, previousImage: previousImage)
    }
    
    func loadLibraryPhoto(photoId: String, uiImage: UIImage) {
        isLoadingLibraryPhoto = true
        var previousImage: Image? = nil
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            previousImage = photos[index].image
            photos[index].updateImage(image: Image(uiImage: uiImage))
        } else {
            guard let photo = AdminPhoto(id: photoId, image: Image(uiImage: uiImage), url: nil) else {
                return
            }
            photos.append(photo)
        }
        updateLibraryPhoto(photoId: photoId, uiImage: uiImage, previousImage: previousImage)
    }
    
    func deleteLibraryPhoto(photoId: String) {
        isLoadingLibraryPhoto = true
        Task {
            do {
                let decodedResult = try await networkManager.deleteCityLibraryPhoto(cityId: id, photoId: photoId)
                guard decodedResult.result else {
                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: deleteErrorModel)
                    throw NetworkErrors.apiErrorTest
                }
                await MainActor.run {
                    self.isLoadingLibraryPhoto = false
                    if let index = photos.firstIndex(where: { $0.id == photoId }) {
                        photos.remove(at: index)
                    }
                }
            } catch {
                debugPrint("ERROR - deleteLibraryPhoto: ", error)
                errorManager.showApiErrorOrMessage(apiError: nil, or: deleteErrorModel)
                await MainActor.run {
                    self.isLoadingLibraryPhoto = false
                }
            }
        }
    }
    
    //MARK: - Private Functions
    
    private func updateImage(uiImage: UIImage, previousImage: AdminPhoto?) {
        Task {
            let scaledImage = uiImage.cropImage(width: 600, height: 750)
            let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
            do {
                let decodedResult = try await networkManager.updateCityPhoto(cityId: id, uiImage: scaledImage)
                guard decodedResult.result else {
                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                    throw NetworkErrors.apiErrorTest
                }
                await MainActor.run {
                    self.isLoadingPhoto = false
                }
            } catch {
                debugPrint("ERROR - update city image: ", error)
                errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
                await MainActor.run {
                    self.isLoadingPhoto = false
                    self.photo = previousImage
                }
            }
        }
    }
    
    private func updateLibraryPhoto(photoId: String, uiImage: UIImage, previousImage: Image?) {
        Task {
            let scaledImage = uiImage.cropImage(width: 600, height: 750)
            do {
                let decodedResult = try await networkManager.updateCityLibraryPhoto(cityId: id, photoId: photoId, uiImage: scaledImage)
                guard decodedResult.result else {
                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: loadErrorModel)
                    throw NetworkErrors.apiErrorTest
                }
                await MainActor.run {
                    self.isLoadingLibraryPhoto = false
                }
            } catch {
                debugPrint("ERROR - update city library photo: ", error)
                errorManager.showApiErrorOrMessage(apiError: nil, or: loadErrorModel)
                await MainActor.run {
                    if let index = photos.firstIndex(where: { $0.id == photoId }) {
                        if let previousImage = previousImage {
                            photos[index].updateImage(image: previousImage)
                        } else {
                            photos.remove(at: index)
                        }
                    }
                    self.isLoadingLibraryPhoto = false
                }
            }
        }
    }
}
