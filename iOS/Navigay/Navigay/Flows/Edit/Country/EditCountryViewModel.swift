//
//  EditCountryViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 14.11.23.
//

import SwiftUI

final class EditCountryViewModel: ObservableObject {
    
    //MARK: - Properties
    
    private let id: Int
    private var isoCountryCode: String = ""
    var nameOrigin: String = ""
    @Published var nameEn: String = ""
    @Published var flagEmoji: String = ""
    @Published var photo: AdminPhoto? = nil
    @Published var about: String = ""
    @Published var showRegions: Bool = false
    @Published var isActive: Bool = false
    @Published var isChecked: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var isLoadingPhoto: Bool = false
    
    var isFetched: Bool = false
    
    //MARK: - Private Properties
    
    private let errorManager: ErrorManagerProtocol
    private let networkManager: EditCountryNetworkManagerProtocol
    
    // MARK: - Inits
    
    init(id: Int, country: Country?, errorManager: ErrorManagerProtocol, networkManager: EditCountryNetworkManagerProtocol) {
        self.errorManager = errorManager
        self.networkManager = networkManager
        self.id = id
    }
}

extension EditCountryViewModel {
    
    //MARK: - Functions
    
    func fetchCountry(for user: AppUser) {
        Task {
            guard !isFetched else {
                return
            }
            do {
                let decodedCountry = try await networkManager.fetchCountry(id: id, for: user)
                await MainActor.run {
                    isFetched = true
                    isoCountryCode = decodedCountry.isoCountryCode
                    nameOrigin = decodedCountry.nameOrigin ?? ""
                    nameEn = decodedCountry.nameEn ?? ""
                    flagEmoji = decodedCountry.flagEmoji ?? ""
                    photo = AdminPhoto(id: UUID().uuidString, image: nil, url: decodedCountry.photo)
                    about = decodedCountry.about ?? ""
                    showRegions = decodedCountry.showRegions
                    isActive = decodedCountry.isActive
                    isChecked = decodedCountry.isChecked
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
    
    func updateInfo(user: AppUser) async -> Bool {
        await MainActor.run {
            isLoading = true
        }
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
            try await networkManager.updateCountry(country: country, from: user)
            await MainActor.run {
                isLoading = false
            }
            return true
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
        return false
    }
        
    func updateImage(uiImage: UIImage, from user: AppUser) {
        isLoadingPhoto = true
        Task {
            let scaledImage = uiImage.cropImage(width: 600, height: 750)
            let message = "Something went wrong. The photo didn't load. Please try again later."
            do {
                let newUrl = try await networkManager.updateCountryPhoto(countryId: id, uiImage: scaledImage, from: user)
                await MainActor.run {
                    photo = AdminPhoto(id: UUID().uuidString, image: Image(uiImage: uiImage), url: newUrl)
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
}
