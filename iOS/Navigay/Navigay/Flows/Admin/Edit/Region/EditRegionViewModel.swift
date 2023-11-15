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
    @Published var nameOrigin: String
    @Published var nameEn: String
    @Published var nameFr: String
    @Published var nameDe: String
    @Published var nameRu: String
    @Published var nameIt: String
    @Published var nameEs: String
    @Published var namePt: String
    @Published var photo: Image?
    @Published var isActive: Bool
    @Published var isChecked: Bool
    
    @Published var isLoading: Bool = false
    @Published var isLoadingPhoto: Bool = false
    
    //MARK: - Private Properties
    
    private let errorManager: ErrorManagerProtocol
    private let networkManager: AdminNetworkManagerProtocol
    
    // MARK: - Inits
    
    init(region: AdminRegion, errorManager: ErrorManagerProtocol, networkManager: AdminNetworkManagerProtocol) {
        self.errorManager = errorManager
        self.networkManager = networkManager
        self.id = region.id
        self.countryId = region.countryId
        self.nameOrigin = region.nameOrigin ?? ""
        self.nameEn = region.nameEn ?? ""
        self.nameFr = region.nameFr ?? ""
        self.nameDe = region.nameDe ?? ""
        self.nameRu = region.nameRu ?? ""
        self.nameIt = region.nameIt ?? ""
        self.nameEs = region.nameEs ?? ""
        self.namePt = region.namePt ?? ""
        self.isActive = region.isActive
        self.isChecked = region.isChecked
        
        //photo!!!!!!!!!!!!!!! и в country
    }
}

extension EditRegionViewModel {
    
    //MARK: - Functions
    
    func updateInfo() async -> Bool {
        let errorModel = ErrorModel(massage: "Something went wrong. The region didn't update in database. Please try again later.", img: nil, color: nil)
        let region: AdminRegion = AdminRegion(id: id,
                                              countryId: countryId,
                                              nameOrigin: nameOrigin.isEmpty ? nil : nameOrigin,
                                              nameEn: nameEn.isEmpty ? nil : nameEn,
                                              nameFr: nameFr.isEmpty ? nil : nameFr,
                                              nameDe: nameDe.isEmpty ? nil : nameDe,
                                              nameRu: nameRu.isEmpty ? nil : nameRu,
                                              nameIt: nameIt.isEmpty ? nil : nameIt,
                                              nameEs: nameEs.isEmpty ? nil : nameEs,
                                              namePt: namePt.isEmpty ? nil : namePt,
                                              photo: nil,
                                              isActive: isActive,
                                              isChecked: isChecked)
        do {
            let decodedResult = try await networkManager.updateRegion(region: region)
            guard decodedResult.result else {
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                return false
            }
            return true
        } catch {
            debugPrint("ERROR - update region info: ", error)
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
    
    //MARK: - Private Functions
    
    private func updateImage(uiImage: UIImage, previousImage: Image?) {
        Task {
            let scaledImage = uiImage.cropImage(width: 600, height: 750)
            let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
            do {
                let decodedResult = try await networkManager.updateRegionPhoto(regionId: id, uiImage: scaledImage)
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
