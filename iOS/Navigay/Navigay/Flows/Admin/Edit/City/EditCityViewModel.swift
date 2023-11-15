//
//  EditCityViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 15.11.23.
//

import SwiftUI

import SwiftUI

final class EditCityViewModel: ObservableObject {
    
    //MARK: - Properties

    @Published var nameOrigin: String
    @Published var nameEn: String
    @Published var nameFr: String
    @Published var nameDe: String
    @Published var nameRu: String
    @Published var nameIt: String
    @Published var nameEs: String
    @Published var namePt: String
    @Published var photo: Image?
    @Published var photos: [Photo]
    @Published var languages: [Language]
    @Published var about: [NewPlaceAbout]
    @Published var isActive: Bool
    @Published var isChecked: Bool
    
    @Published var isLoading: Bool = false
    @Published var isLoadingPhoto: Bool = false
    @Published var isLoadingLibraryPhoto: Bool = false
    
    //MARK: - Private Properties
    
    private let id: Int
    private let countryId: Int
    private let regionId: Int
    
    private let errorManager: ErrorManagerProtocol
    private let networkManager: AdminNetworkManagerProtocol
    
    private let loadErrorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
    private let deleteErrorModel = ErrorModel(massage: "Something went wrong. The photo didn't delete. Please try again later.", img: Image(systemName: "trash.slash.fill"), color: .red)
    
    // MARK: - Inits
    
    init(city: AdminCity, errorManager: ErrorManagerProtocol, networkManager: AdminNetworkManagerProtocol) {
        self.errorManager = errorManager
        self.networkManager = networkManager
        self.id = city.id
        self.countryId = city.countryId
        self.regionId = city.regionId
        self.nameOrigin = city.nameOrigin ?? ""
        self.nameEn = city.nameEn ?? ""
        self.nameFr = city.nameFr ?? ""
        self.nameDe = city.nameDe ?? ""
        self.nameRu = city.nameRu ?? ""
        self.nameIt = city.nameIt ?? ""
        self.nameEs = city.nameEs ?? ""
        self.namePt = city.namePt ?? ""
        self.about = city.about?.map({ NewPlaceAbout(language: $0.language, about: $0.about) }) ?? []
        let existingLanguages = city.about?.map( { $0.language } ) ?? []
        self.languages = Language.allCases.filter { !existingLanguages.contains($0) }
        self.isActive = city.isActive
        self.isChecked = city.isChecked
        self.photos = []// [Photo(id: UUID(), image: Image("1")), Photo(id: UUID(), image: Image("2"))]
        //photo photos!
    }
}

extension EditCityViewModel {
    
    //MARK: - Functions
    
    func updateInfo() async -> Bool {
        let errorModel = ErrorModel(massage: "Something went wrong. The city didn't update in database. Please try again later.", img: nil, color: nil)
        let about = about.map( { DecodedAbout(language: $0.language, about: $0.about) } )
        let city: AdminCity = AdminCity(id: id,
                                        countryId: countryId,
                                        regionId: regionId,
                                        nameOrigin: nameOrigin.isEmpty ? nil : nameOrigin,
                                        nameEn: nameEn.isEmpty ? nil : nameEn,
                                        nameFr: nameFr.isEmpty ? nil : nameFr,
                                        nameDe: nameDe.isEmpty ? nil : nameDe,
                                        nameRu: nameRu.isEmpty ? nil : nameRu,
                                        nameIt: nameIt.isEmpty ? nil : nameIt,
                                        nameEs: nameEs.isEmpty ? nil : nameEs,
                                        namePt: namePt.isEmpty ? nil : namePt,
                                        about: about.isEmpty ? nil : about,
                                        photo: nil,
                                        photos: nil,
                                        isActive: isActive,
                                        isChecked: isChecked)
        do {
            let decodedResult = try await networkManager.updateCity(city: city)
            guard decodedResult.result else {
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                return false
            }
            return true
        } catch {
            debugPrint("ERROR - update country info: ", error)
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            return false
        }
    }
    
    func loadImage(uiImage: UIImage) {
        isLoadingPhoto = true
        let previousImage = photo
        photo = Image(uiImage: uiImage)
        updateImage(uiImage: uiImage, previousImage: previousImage)
    }
    
    func loadLibraryPhoto(photoId: UUID, uiImage: UIImage) {
        isLoadingLibraryPhoto = true
        var previousImage: Image? = nil
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            previousImage = photos[index].image
            photos[index].updateImage(image: Image(uiImage: uiImage))
        } else {
            let photo = Photo(id: photoId, image: Image(uiImage: uiImage))
            photos.append(photo)
        }
        updateLibraryPhoto(photoId: photoId, uiImage: uiImage, previousImage: previousImage)
    }
    
    func deleteLibraryPhoto(photoId: UUID) {
        isLoadingLibraryPhoto = true
        Task {
            do {
                let decodedResult = try await networkManager.deleteCityLibraryPhoto(cityId: id, photoId: photoId)
                guard decodedResult.result else {
                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: deleteErrorModel)
                    throw NetworkErrors.apiError
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
    
    private func updateImage(uiImage: UIImage, previousImage: Image?) {
        Task {
            let scaledImage = uiImage.cropImage(width: 600, height: 750)
            let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
            do {
                let decodedResult = try await networkManager.updateCityPhoto(cityId: id, uiImage: scaledImage)
                guard decodedResult.result else {
                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                    throw NetworkErrors.apiError
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
    
    private func updateLibraryPhoto(photoId: UUID, uiImage: UIImage, previousImage: Image?) {
        Task {
            let scaledImage = uiImage.cropImage(width: 600, height: 750)
            do {
                let decodedResult = try await networkManager.updateCityLibraryPhoto(cityId: id, photoId: photoId, uiImage: scaledImage)
                guard decodedResult.result else {
                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: loadErrorModel)
                    throw NetworkErrors.apiError
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
