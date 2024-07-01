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
    var isoCountryCode: String = ""
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
    private let user: AppUser
    private let country: Country?

    
    // MARK: - Inits
    
    init(id: Int, country: Country?, user: AppUser, errorManager: ErrorManagerProtocol, networkManager: EditCountryNetworkManagerProtocol) {
        self.user = user
        self.errorManager = errorManager
        self.networkManager = networkManager
        self.id = id
        self.country = country
    }
}

extension EditCountryViewModel {
    
    //MARK: - Functions
    
    func fetchCountry() {
        Task {
            guard !isFetched else {
                return
            }
            do {
                let decodedCountry = try await networkManager.fetchCountry(id: id, for: user)
                await MainActor.run {
                    isFetched = true
                    isoCountryCode = decodedCountry.isoCountryCode
                    nameEn = decodedCountry.nameEn ?? ""
                    flagEmoji = decodedCountry.flagEmoji ?? ""
                    photo = AdminPhoto(id: UUID().uuidString, image: nil, url: decodedCountry.photo)
                    about = decodedCountry.about ?? ""
                    showRegions = decodedCountry.showRegions ?? false
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
    
    func updateInfo() async -> Bool {
        await MainActor.run {
            isLoading = true
        }
        do {
            try await networkManager.updateCountry(id: id, name: nameEn, flag: flagEmoji, about: about, showRegions: showRegions, isActive: isActive, isChecked: isChecked, user: user)
            await MainActor.run {
                isLoading = false
                country?.name = nameEn
                country?.flagEmoji = flagEmoji
                country?.about = about
                country?.showRegions = showRegions
                //todo delete country if isActive false
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
        
    func updateImage(uiImage: UIImage) {
        isLoadingPhoto = true
        Task {
            let scaledImage = uiImage.cropImage(width: 600, height: 750)
            let message = "Something went wrong. The photo didn't load. Please try again later."
            do {
                let newUrl = try await networkManager.updateCountryPhoto(countryId: id, uiImage: scaledImage, from: user)
                await MainActor.run {
                    photo = AdminPhoto(id: UUID().uuidString, image: Image(uiImage: uiImage), url: newUrl)
                    country?.photo = Image(uiImage: uiImage)
                    country?.photoUrl = newUrl
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
