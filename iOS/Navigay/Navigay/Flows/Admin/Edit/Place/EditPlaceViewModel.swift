//
//  EditPlaceViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.01.24.
//

import SwiftUI

final class EditPlaceViewModel: ObservableObject {
    
    //MARK: - Properties

    let id: Int
    
    @Published var name: String = ""
    @Published var type: PlaceType? = nil
    @Published var isoCountryCode: String = ""
    @Published var address: String = ""
    @Published var latitude: Double? = nil
    @Published var longitude: Double? = nil
    @Published var tags: [Tag] = []
    @Published var timetable: [NewWorkingDay] = []
    @Published var otherInfo: String = ""
    @Published var about: String = ""
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var www: String = ""
    @Published var facebook: String = ""
    @Published var instagram: String = ""
    @Published var isOwned: Bool = false
    @Published var isActive: Bool = false
    @Published var isChecked: Bool = false
    
    @Published var avatar: AdminPhoto?
    @Published var mainPhoto: AdminPhoto?
    @Published var photos: [AdminPhoto] = []
    
//    @Published var showMap: Bool = false // TODO! убрать
//    @Published var isLoading: Bool = false
    
    let networkManager: AdminNetworkManagerProtocol
//
//    // MARK: - Inits
//    
    init(place: Place, networkManager: AdminNetworkManagerProtocol) {
        debugPrint("init EditPlaceViewModel place id: \(place.id)")
        self.networkManager = networkManager
        self.id = place.id
        self.name = place.name
        self.type = place.type
        self.address = place.address
        self.latitude = place.latitude
        self.longitude = place.longitude
        self.tags = place.tags
        self.timetable = place.timetable.map( { NewWorkingDay(day: $0.day, opening: $0.open, closing: $0.close) } )
        self.otherInfo = place.otherInfo ?? ""
        self.about = place.about ?? ""
        self.phone = place.phone ?? ""
        self.www = place.www ?? ""
        self.facebook = place.facebook ?? ""
        self.instagram = place.instagram ?? ""
        self.isActive = place.isActive
        self.avatar = AdminPhoto(id: UUID().uuidString, image: nil, url: place.avatar)
        self.mainPhoto = AdminPhoto(id: UUID().uuidString, image: nil, url: place.mainPhoto)
    }
}

extension EditPlaceViewModel {
    
    //MARK: - Functions
    
    func fetchPlace() {
        Task {
            guard let decodedPlace = await networkManager.fetchPlace(id: id) else {
                //TODO!!!!!!!!!!!! на вью назад
                return
            }
            await MainActor.run {
                self.email = decodedPlace.email ?? ""
                self.isChecked = decodedPlace.isChecked
                if let photos = decodedPlace.photos, !photos.isEmpty {
                    let adminPhotos = photos.compactMap( { AdminPhoto(id: $0.id, image: nil, url: $0.url)})
                    self.photos = adminPhotos
                } else {
                    self.photos = []
                }
            }
        }
    }
    
//    func updateInfo() async -> Bool {
//        let errorModel = ErrorModel(massage: "Something went wrong. The city didn't update in database. Please try again later.", img: nil, color: nil)
//        let about = about.map( { DecodedAbout(language: $0.language, about: $0.about) } )
//        let city: AdminCity = AdminCity(id: id,
//                                        countryId: countryId,
//                                        regionId: regionId,
//                                        nameOrigin: nameOrigin.isEmpty ? nil : nameOrigin,
//                                        nameEn: nameEn.isEmpty ? nil : nameEn,
//                                        nameFr: nameFr.isEmpty ? nil : nameFr,
//                                        nameDe: nameDe.isEmpty ? nil : nameDe,
//                                        nameRu: nameRu.isEmpty ? nil : nameRu,
//                                        nameIt: nameIt.isEmpty ? nil : nameIt,
//                                        nameEs: nameEs.isEmpty ? nil : nameEs,
//                                        namePt: namePt.isEmpty ? nil : namePt,
//                                        about: about.isEmpty ? nil : about,
//                                        photo: nil,
//                                        photos: nil,
//                                        isActive: isActive,
//                                        isChecked: isChecked)
//        do {
//            let decodedResult = try await networkManager.updateCity(city: city)
//            guard decodedResult.result else {
//                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
//                return false
//            }
//            return true
//        } catch {
//            debugPrint("ERROR - update country info: ", error)
//            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
//            return false
//        }
//    }
    
//    func loadImage(uiImage: UIImage) {
//        isLoadingPhoto = true
//        let previousImage = photo
//        photo = AdminPhoto(id: UUID().uuidString, image: Image(uiImage: uiImage), url: nil)
//        updateImage(uiImage: uiImage, previousImage: previousImage)
//    }
    
//    func loadLibraryPhoto(photoId: String, uiImage: UIImage) {
//        isLoadingLibraryPhoto = true
//        var previousImage: Image? = nil
//        if let index = photos.firstIndex(where: { $0.id == photoId }) {
//            previousImage = photos[index].image
//            photos[index].updateImage(image: Image(uiImage: uiImage))
//        } else {
//            guard let photo = AdminPhoto(id: photoId, image: Image(uiImage: uiImage), url: nil) else {
//                return
//            }
//            photos.append(photo)
//        }
//        updateLibraryPhoto(photoId: photoId, uiImage: uiImage, previousImage: previousImage)
//    }
    
//    func deleteLibraryPhoto(photoId: String) {
//        isLoadingLibraryPhoto = true
//        Task {
//            do {
//                let decodedResult = try await networkManager.deleteCityLibraryPhoto(cityId: id, photoId: photoId)
//                guard decodedResult.result else {
//                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: deleteErrorModel)
//                    throw NetworkErrors.apiError
//                }
//                await MainActor.run {
//                    self.isLoadingLibraryPhoto = false
//                    if let index = photos.firstIndex(where: { $0.id == photoId }) {
//                        photos.remove(at: index)
//                    }
//                }
//            } catch {
//                debugPrint("ERROR - deleteLibraryPhoto: ", error)
//                errorManager.showApiErrorOrMessage(apiError: nil, or: deleteErrorModel)
//                await MainActor.run {
//                    self.isLoadingLibraryPhoto = false
//                }
//            }
//        }
//    }
    
    //MARK: - Private Functions
    
//    private func updateImage(uiImage: UIImage, previousImage: AdminPhoto?) {
//        Task {
//            let scaledImage = uiImage.cropImage(width: 600, height: 750)
//            let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
//            do {
//                let decodedResult = try await networkManager.updateCityPhoto(cityId: id, uiImage: scaledImage)
//                guard decodedResult.result else {
//                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
//                    throw NetworkErrors.apiError
//                }
//                await MainActor.run {
//                    self.isLoadingPhoto = false
//                }
//            } catch {
//                debugPrint("ERROR - update city image: ", error)
//                errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
//                await MainActor.run {
//                    self.isLoadingPhoto = false
//                    self.photo = previousImage
//                }
//            }
//        }
//    }
    
//    private func updateLibraryPhoto(photoId: String, uiImage: UIImage, previousImage: Image?) {
//        Task {
//            let scaledImage = uiImage.cropImage(width: 600, height: 750)
//            do {
//                let decodedResult = try await networkManager.updateCityLibraryPhoto(cityId: id, photoId: photoId, uiImage: scaledImage)
//                guard decodedResult.result else {
//                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: loadErrorModel)
//                    throw NetworkErrors.apiError
//                }
//                await MainActor.run {
//                    self.isLoadingLibraryPhoto = false
//                }
//            } catch {
//                debugPrint("ERROR - update city library photo: ", error)
//                errorManager.showApiErrorOrMessage(apiError: nil, or: loadErrorModel)
//                await MainActor.run {
//                    if let index = photos.firstIndex(where: { $0.id == photoId }) {
//                        if let previousImage = previousImage {
//                            photos[index].updateImage(image: previousImage)
//                        } else {
//                            photos.remove(at: index)
//                        }
//                    }
//                    self.isLoadingLibraryPhoto = false
//                }
//            }
//        }
//    }
}
