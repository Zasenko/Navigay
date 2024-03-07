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
    let event: Event?
    
    @Published var eventDidLoad: Bool = false
    
    @Published var isLoading: Bool = false

    @Published var name: String = ""
    @Published var type: EventType = .other
    @Published var isoCountryCode: String? = nil
    @Published var countryId: Int? = nil
    @Published var regionId: Int? = nil
    @Published var cityId: Int? = nil
    @Published var latitude: Double = 0
    @Published var longitude: Double = 0
    @Published var address: String = ""
    @Published var startDate: Date = .now
    @Published var startTime: Date? = nil
    @Published var finishDate: Date? = nil
    @Published var finishTime: Date? = nil
    @Published var location: String = ""
    @Published var about: String = ""
    @Published var isFree: Bool = false
    @Published var fee: String = ""
    @Published var tickets: String = ""
    @Published var tags: [Tag] = []
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var www: String = ""
    @Published var facebook: String = ""
    @Published var instagram: String = ""
    @Published var isActive: Bool = false
    @Published var isChecked: Bool = false
    
    @Published var createdAt: String = ""
    @Published var updatedAt: String = ""
    
    
    @Published var isLoadingPoster: Bool = false
    @Published var poster: AdminPhoto?
    @Published var smallPoster: AdminPhoto?
    
    @Published var countryOrigin: String? = nil
    @Published var countryEnglish: String? = nil
    @Published var regionOrigin: String? = nil
    @Published var regionEnglish: String? = nil
    @Published var cityOrigin: String? = nil
    @Published var cityEnglish: String? = nil
    
    
    @Published var showPicker: Bool = false
//    @Published var pickerImage: UIImage? {
//        didSet {
//            if let pickerImage {
//                loadPoster(uiImage: pickerImage)
//            }
//        }
//    }
    
    @Published var showEditPosterView: Bool = false
   // @Published var showEditTitle: Bool = false
    
    //TODO Объеденить из AdminNetworkManagerProtocol в eventNetworkManager
  let networkManager: AdminNetworkManagerProtocol
    let eventNetworkManager: EventNetworkManagerProtocol = EventNetworkManager(appSettingsManager: AppSettingsManager(), errorManager: ErrorManager())
    
    // MARK: - Inits

    init(eventID: Int, event: Event?, networkManager: AdminNetworkManagerProtocol) {
        debugPrint("init EditEventViewModel event id: \(eventID)")
        self.networkManager = networkManager
        self.event = event
        self.id = eventID
    }
}

extension EditEventViewModel {
    
    //MARK: - Functions
    
    func fetchEvent(for user: AppUser) {
        Task {
            do {
                let event = try await networkManager.fetchEvent(id: id, for: user)
                await MainActor.run {
                    self.name = event.name
                    self.type = event.type
                    self.countryId = event.countryId
                    self.regionId = event.regionId
                    self.cityId = event.cityId
                    self.latitude = event.latitude ?? 0.0
                    self.longitude = event.longitude ?? 0.0
                    self.address = event.address ?? ""
                    self.startDate = event.startDate.dateFromString(format: "yyyy-MM-dd") ?? .now
                    self.startTime = event.startTime?.dateFromString(format: "HH:mm:ss")
                    self.finishDate = event.finishDate?.dateFromString(format: "yyyy-MM-dd")
                    self.finishTime = event.finishTime?.dateFromString(format: "HH:mm:ss")
                    self.location = event.location ?? ""
                    self.about = event.about ?? ""
                    self.poster = AdminPhoto(id: UUID().uuidString, image: nil, url: event.poster)
                    self.smallPoster = AdminPhoto(id: UUID().uuidString, image: nil, url: event.smallPoster)
                    self.isFree = event.isFree
                    self.tickets = event.tickets ?? ""
                    self.fee = event.fee ?? ""
                    self.email = event.email ?? ""
                    self.phone = event.phone ?? ""
                    self.www = event.www ?? ""
                    self.facebook = event.facebook ?? ""
                    self.instagram = event.instagram ?? ""
                    self.tags = event.tags ?? []
                    self.isActive = event.isActive
                    self.isChecked = event.isChecked
                    self.createdAt = event.createdAt
                    self.updatedAt = event.updatedAt
                    
                    self.eventDidLoad = true
                }
            } catch {
                debugPrint(error)
            }
        }
    }
    
    func updateTitle() {
    }
    
    func updateAbout() {
    }
    
    func updatePoster(user: AppUser, uiImage: UIImage) {
        self.isLoadingPoster = true
        Task {
            do {
                let scaledImage = uiImage.cropImage(maxWidth: 750, maxHeight: 750)
                let scaledSmallImage = uiImage.cropImage(maxWidth: 350, maxHeight: 350)
                let urls = try await eventNetworkManager.updatePoster(eventId: id, poster: scaledImage, smallPoster: scaledSmallImage, user: user)
                let image = Image(uiImage: uiImage)
                await MainActor.run {
                    self.poster = AdminPhoto(id: UUID().uuidString, image: image, url: urls.posterUrl)
                    self.smallPoster = AdminPhoto(id: UUID().uuidString, image: image, url: urls.smallPosterUrl)
                    if let event {
                        event.poster = urls.posterUrl
                        event.smallPoster = urls.smallPosterUrl
                        event.image = image
                    }
                    self.isLoadingPoster = false
                }
            } catch {
                debugPrint("ERROR - updateAvatar: ", error)
                // errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
                self.isLoadingPoster = false
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

    
    func deletePoster(user: AppUser) {
        self.isLoadingPoster = true
        Task {
            do {
                try await eventNetworkManager.deletePoster(eventId: id, user: user)
                await MainActor.run {
                    self.poster = nil
                    self.smallPoster = nil
                    if let event {
                        event.poster = nil
                        event.smallPoster = nil
                        event.image = nil
                    }
                    self.isLoadingPoster = false
                }
            } catch {
                debugPrint("ERROR - updateAvatar: ", error)
                // errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
                self.isLoadingPoster = false
            }
        }
    }
}
