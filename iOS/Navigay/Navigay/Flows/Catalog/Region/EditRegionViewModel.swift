//
//  EditRegionViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 15.11.23.
//

import SwiftUI

final class EditRegionViewModel: ObservableObject {
    
    //MARK: - Properties
    
    let id: Int
    let countryId: Int
    @Published var nameOrigin: String = ""
    @Published var nameEn: String = ""
    @Published var photo: AdminPhoto? = nil
    @Published var isActive: Bool = false
    @Published var isChecked: Bool = false

    @Published var isLoading: Bool = false
    @Published var isLoadingPhoto: Bool = false
    
    var isFetched: Bool = false
    
    //MARK: - Private Properties
    
    private let errorManager: ErrorManagerProtocol
    private let networkManager: EditRegionNetworkManagerProtocol
    private let user: AppUser
    private let region: Region?
    
    // MARK: - Inits
    
    init(id: Int, countryId: Int, region: Region?, user: AppUser, errorManager: ErrorManagerProtocol, networkManager: EditRegionNetworkManagerProtocol) {
        self.errorManager = errorManager
        self.networkManager = networkManager
        self.countryId = countryId
        self.id = id
        self.user = user
        self.region = region
    }
}

extension EditRegionViewModel {
    
    //MARK: - Functions
    
    func fetchRegion() {
        Task {
            guard !isFetched else {
                return
            }
            do {
                let decodedRegion = try await networkManager.fetchRegion(id: id, user: user)
                await MainActor.run {
                    isFetched = true
                    nameOrigin = decodedRegion.nameOrigin ?? ""
                    nameEn = decodedRegion.nameEn ?? ""
                    photo = AdminPhoto(id: UUID().uuidString, image: nil, url: decodedRegion.photo)
                    isActive = decodedRegion.isActive
                    isChecked = decodedRegion.isChecked
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
                try await networkManager.updateRegion(id: id, name: nameEn, isActive: isActive, isChecked: isChecked, user: user)
                await MainActor.run {
                    
                    //todo update region
                    
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
    
    //MARK: - Private Functions
    
    func updateImage(uiImage: UIImage) {
        isLoadingPhoto = true
        Task {
            let scaledImage = uiImage.cropImage(width: 600, height: 750)
            let message = "Something went wrong. The photo didn't load. Please try again later."
            do {
                let newUrl = try await networkManager.updateRegionPhoto(regionId: id, uiImage: uiImage, user: user)
                await MainActor.run {
                    photo = AdminPhoto(id: UUID().uuidString, image: Image(uiImage: uiImage), url: newUrl)
                    
                    //todo update region
                    
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
