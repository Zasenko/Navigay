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
    @Published var nameFr: String
    @Published var nameDe: String
    @Published var nameRu: String
    @Published var nameIt: String
    @Published var nameEs: String
    @Published var namePt: String
    @Published var flagEmoji: String
    @Published var photo: Image?
    @Published var languages: [Language]
    @Published var about: [NewPlaceAbout]
    @Published var showRegions: Bool = false
    @Published var isActive: Bool = false
    @Published var isChecked: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var isLoadingPhoto: Bool = false
    
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
        self.nameFr = country.nameFr ?? ""
        self.nameDe = country.nameDe ?? ""
        self.nameRu = country.nameRu ?? ""
        self.nameIt = country.nameIt ?? ""
        self.nameEs = country.nameEs ?? ""
        self.namePt = country.namePt ?? ""
        self.flagEmoji = country.flagEmoji ?? ""
        self.about = country.about?.map({ NewPlaceAbout(language: $0.language, about: $0.about) }) ?? []
        let existingLanguages = country.about?.map( { $0.language } ) ?? []
        self.languages = Language.allCases.filter { !existingLanguages.contains($0) }
        self.showRegions = country.showRegions
        self.isActive = country.isActive
        self.isChecked = country.isChecked
    }
}

extension EditCountryViewModel {
    
    //MARK: - Functions
    
    func updateInfo() async -> Bool {
            let errorModel = ErrorModel(massage: "Something went wrong. The country didn't update in database. Please try again later.", img: nil, color: nil)
            let about = about.map( { DecodedAbout(language: $0.language, about: $0.about) } )
            let country: AdminCountry = AdminCountry(id: id,
                                                     isoCountryCode: isoCountryCode,
                                                     nameOrigin: nameOrigin.isEmpty ? nil : nameOrigin,
                                                     nameEn: nameEn.isEmpty ? nil : nameEn,
                                                     nameFr: nameFr.isEmpty ? nil : nameFr,
                                                     nameDe: nameDe.isEmpty ? nil : nameDe,
                                                     nameRu: nameRu.isEmpty ? nil : nameRu,
                                                     nameIt: nameIt.isEmpty ? nil : nameIt,
                                                     nameEs: nameEs.isEmpty ? nil : nameEs,
                                                     namePt: namePt.isEmpty ? nil : namePt,
                                                     about: about.isEmpty ? nil : about,
                                                     flagEmoji: flagEmoji.isEmpty ? nil : flagEmoji,
                                                     photo: nil,
                                                     showRegions: showRegions,
                                                     isActive: isActive,
                                                     isChecked: isChecked)
            do {
                let decodedResult = try await networkManager.updateCountry(country: country)
                print("decodedResult: ", decodedResult)
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
    
    //MARK: - Private Functions
    
    private func updateImage(uiImage: UIImage, previousImage: Image?) {
        Task {
            let scaledImage = uiImage.cropImage(maxWidth: 750, maxHeight: 750)
            let scaledImageSmall = uiImage.cropImage(maxWidth: 350, maxHeight: 350)
            let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
            do {
                let decodedResult = try await networkManager.updateCountryPhoto(countryId: id, uiImage: uiImage)
                guard decodedResult.result else {
                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                    return
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
