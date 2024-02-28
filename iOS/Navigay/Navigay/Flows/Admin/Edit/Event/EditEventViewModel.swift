//
//  EditEventViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 18.01.24.
//

import SwiftUI

final class EditEventViewModel: ObservableObject {
    
    //MARK: - Properties

    let id: Int
    //TODO: поля не соответствуют Event (просто скопированно с Place) - доделать полностью редактирование
    @Published var name: String = ""
    @Published var type: EventType? = nil
    @Published var isoCountryCode: String = ""
    
    @Published var address: String = ""
    @Published var location: String = ""
    @Published var latitude: Double? = nil
    @Published var longitude: Double? = nil
    
    @Published var tags: [Tag] = []
    @Published var about: String = ""
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var www: String = ""
    @Published var facebook: String = ""
    @Published var instagram: String = ""
    
    @Published var isOwned: Bool = false
    
    @Published var isActive: Bool = false
    @Published var isChecked: Bool = false
    
    @Published var startDate: Date? = nil
    @Published var startTime: Date? = nil
    @Published var finishDate: Date? = nil
    @Published var finishTime: Date? = nil
    
    @Published var isLoadingPoster: Bool = false
    @Published var poster: AdminPhoto?
    @Published var smallPoster: AdminPhoto?
    
    @Published var posterT: Image?
    @Published var smallPosterT: Image?
    
    @Published var isLoading: Bool = false
    
    @Published var countryOrigin: String = ""
    @Published var countryEnglish: String = ""
    @Published var regionOrigin: String = ""
    @Published var regionEnglish: String = ""
    @Published var cityOrigin: String = ""
    @Published var cityEnglish: String = ""
    
    @Published var isFree: Bool = false
    @Published var fee: String = ""
    @Published var tickets: String = ""
    
    @Published var showPicker: Bool = false
    @Published var pickerImage: UIImage? {
        didSet {
            if let pickerImage {
                loadPoster(uiImage: pickerImage)
            }
        }
    }
    
    let networkManager: AdminNetworkManagerProtocol
//
//    // MARK: - Inits
//
    init(event: Event, networkManager: AdminNetworkManagerProtocol) {
        debugPrint("init EditEventViewModel event id: \(event.id)")
        self.networkManager = networkManager
        self.id = event.id
        self.name = event.name
        self.type = event.type
        self.address = event.address
        self.latitude = event.latitude
        self.longitude = event.longitude
        self.tags = event.tags
        
        self.startDate = event.startDate
        self.startTime = event.startTime
        self.finishDate = event.finishDate
        self.finishTime = event.finishTime
        
        self.about = event.about ?? ""
        self.phone = event.phone ?? ""
        self.www = event.www ?? ""
        self.facebook = event.facebook ?? ""
        self.instagram = event.instagram ?? ""
       // self.isActive = event.isActive
        self.poster = AdminPhoto(id: UUID().uuidString, image: event.image, url: event.poster)
        self.smallPoster = AdminPhoto(id: UUID().uuidString, image: event.image, url: event.smallPoster)
    }
}

extension EditEventViewModel {
    
    //MARK: - Functions
    
    func fetchEvent() {
//        location = "location"
//        about = "🏉For one night, the HARD ON becomes a playing field! Experience the full masculinity of tough sport when the Vienna Eagles Rugby Football Club visits us at HARD ON! Come in your sharpest sports outfit and meet the hottest athletes of Vienna!\n\n 09.03.2024 23:00\n Door open until 03:00"
//        phone = "+45 5698977"
//        www = "www.www.ru"
//        tags =  [.adultsOnly, .beach, .darkroom, .gayFriendly]
//        facebook = "www.facebook.ru"
//        instagram = "www.instagram.ru"
//        tickets = "www.tickets.ru"
//        fee = "www.fee.ru"
        
//        Task {
//            guard let decodedPlace = await networkManager.fetchPlace(id: id) else {
//                //TODO!!!!!!!!!!!! на вью назад
//                return
//            }
//            await MainActor.run {
//                self.email = decodedPlace.email ?? ""
//                self.isChecked = decodedPlace.isChecked
//                if let photos = decodedPlace.photos, !photos.isEmpty {
//                    let adminPhotos = photos.compactMap( { AdminPhoto(id: $0.id, image: nil, url: $0.url)})
//                    self.photos = adminPhotos
//                } else {
//                    self.photos = []
//                }
//            }
//        }
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
    
    func deletePoster() {
    }
    
    func loadPoster(uiImage: UIImage) {
        isLoading = true
        let previousImage = posterT
        let previousImageS = smallPosterT
        
        posterT = Image(uiImage: uiImage)
        update(uiImage: uiImage, previousImage: previousImage, previousImageS: previousImageS)
    }
    
    //MARK: - Private Functions
    
    private func update(uiImage: UIImage, previousImage: Image?, previousImageS: Image?) {
//        Task {
//            let scaledImage = uiImage.cropImage(maxWidth: 750, maxHeight: 750)
//            let scaledImageSmall = uiImage.cropImage(maxWidth: 350, maxHeight: 350)
//            do {
//                let decodedResult = try await networkManager.updatePoster(eventId: eventId, poster: scaledImage, smallPoster: scaledImageSmall)
//                guard decodedResult.result else {
//                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
//                    throw NetworkErrors.apiErrorTest
//                }
//                await MainActor.run {
//                    self.isLoading = false
//                }
//            } catch {
//                debugPrint("ERROR - updateAvatar: ", error)
//                errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
//                await MainActor.run {
//                    self.isLoading = false
//                    self.poster = previousImage
//                }
//            }
//        }
    }
}
