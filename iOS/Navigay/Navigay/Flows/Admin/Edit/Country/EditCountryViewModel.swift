//
//  EditCountryViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 14.11.23.
//

import SwiftUI

final class EditCountryViewModel: ObservableObject {
    
    //MARK: - Properties
    
    let id: Int
    let isoCountryCode: String
    @Published var nameOrigin: String
    @Published var nameEn: String
    @Published var flagEmoji: String
    @Published var photo: AdminPhoto?
    @Published var about: String
    @Published var showRegions: Bool
    @Published var isActive: Bool
    @Published var isChecked: Bool
    
    @Published var isLoading: Bool = false
    @Published var isLoadingPhoto: Bool = false
    
    var isFetched: Bool = false
    
    //MARK: - Private Properties
    
    private let errorManager: ErrorManagerProtocol
    private let networkManager: AdminNetworkManagerProtocol
    
    // MARK: - Inits
    
    init(country: AdminCountry, errorManager: ErrorManagerProtocol, networkManager: AdminNetworkManagerProtocol) {
        self.errorManager = errorManager
        self.networkManager = networkManager
        self.id = country.id
        self.isoCountryCode = country.isoCountryCode
        self.nameOrigin = country.nameOrigin ?? ""
        self.nameEn = country.nameEn ?? ""
        self.flagEmoji = country.flagEmoji ?? ""
        self.photo = AdminPhoto(id: UUID().uuidString, image: nil, url: country.photo)
        self.about = country.about ?? ""
        self.showRegions = country.showRegions
        self.isActive = country.isActive
        self.isChecked = country.isChecked
    }
}

extension EditCountryViewModel {
    
    //MARK: - Functions
    
    func fetchCountry() {
        Task {
            guard !isFetched, let decodedCountry = await networkManager.fetchCountry(id: id) else {
                return
            }
            await MainActor.run {
                isFetched = true
                nameOrigin = decodedCountry.nameOrigin ?? ""
                nameEn = decodedCountry.nameEn ?? ""
                flagEmoji = decodedCountry.flagEmoji ?? ""
                photo = AdminPhoto(id: UUID().uuidString, image: nil, url: decodedCountry.photo)
                about = decodedCountry.about ?? ""
                showRegions = decodedCountry.showRegions
                isActive = decodedCountry.isActive
                isChecked = decodedCountry.isChecked
            }
        }
    }
    
    func updateInfo() async -> Bool {
            let errorModel = ErrorModel(massage: "Something went wrong. The information didn't update in database. Please try again later.", img: nil, color: nil)
            let country: AdminCountry = AdminCountry(id: id,
                                                     isoCountryCode: isoCountryCode,
                                                     nameOrigin: nameOrigin.isEmpty ? nil : nameOrigin,
                                                     nameEn: nameEn.isEmpty ? nil : nameEn,
                                                     about: about.isEmpty ? nil : about,
                                                     flagEmoji: flagEmoji.isEmpty ? nil : flagEmoji,
                                                     photo: nil,
                                                     showRegions: showRegions,
                                                     isActive: isActive,
                                                     isChecked: isChecked)
            do {
                let decodedResult = try await networkManager.updateCountry(country: country)
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
        photo = AdminPhoto(id: UUID().uuidString, image: Image(uiImage: uiImage), url: nil)
        updateImage(uiImage: uiImage, previousImage: previousImage)
    }
    
    //MARK: - Private Functions
    
    private func updateImage(uiImage: UIImage, previousImage: AdminPhoto?) {
        Task {
            let scaledImage = uiImage.cropImage(width: 600, height: 750)
            let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
            do {
                let decodedResult = try await networkManager.updateCountryPhoto(countryId: id, uiImage: scaledImage)
                guard decodedResult.result else {
                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                    throw NetworkErrors.apiError
                }
                await MainActor.run {
                    self.isLoadingPhoto = false
                }
            } catch {
                debugPrint("ERROR - updateAvatar: ", error)
                errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
                await MainActor.run {
                    self.isLoadingPhoto = false
                    self.photo = previousImage
                }
            }
        }
    }
}
