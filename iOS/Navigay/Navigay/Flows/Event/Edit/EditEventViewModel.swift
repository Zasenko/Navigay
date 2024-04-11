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

    @Published var fetched: Bool = false
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
    @Published var adminNotes: String = ""
    
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
    
    @Published var showEditPosterView: Bool = false
    @Published var showDeleteSheet: Bool = false
    
    @Published var showAdminFields: Bool = false
    
    //MARK: - Private Properties
    
    private let event: Event?
    private let user: AppUser
    private let networkManager: EditEventNetworkManagerProtocol
    private let errorManager: ErrorManagerProtocol

    // MARK: - Inits

    init(eventID: Int, user: AppUser, event: Event?, networkManager: EditEventNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
        self.event = event
        self.id = eventID
        self.networkManager = networkManager
        self.errorManager = errorManager
        self.user = user
        if (user.status == .admin || user.status == .moderator) {
            self.showAdminFields = true
        }
    }
}

extension EditEventViewModel {
    
    //MARK: - Functions
    
    func fetchEvent() {
        guard !fetched else { return }
        isLoading = true
        Task {
            do {
                let event = try await networkManager.fetchEvent(id: id, for: user)
                await MainActor.run {
//                    self.name = "event.name"
//                    self.type = .festival
//                    self.countryId = nil
//                    self.regionId = nil
//                    self.cityId = nil
//                    self.latitude = 0.0
//                    self.longitude = 0.0
//                    self.address = "eee"
//                    self.startDate = "2024-04-13".dateFromString(format: "yyyy-MM-dd") ?? .now
//                    self.startTime = "23:00:00".dateFromString(format: "HH:mm:ss")
//                    self.finishDate = "2024-04-13".dateFromString(format: "yyyy-MM-dd")
//                    self.finishTime = "08:00:00".dateFromString(format: "HH:mm:ss")
//                    self.location = "event.location"
//                    self.about = "event.about"
//                    self.poster = AdminPhoto(id: UUID().uuidString, image: nil, url: "https://i.ebayimg.com/images/g/YocAAOSwx09jPfnj/s-l400.jpg")
//                    self.smallPoster = AdminPhoto(id: UUID().uuidString, image: nil, url: "https://i.ebayimg.com/images/g/YocAAOSwx09jPfnj/s-l400.jpg")
//                    self.isFree = false
//                    self.tickets = ""
//                    self.fee = ""
//                    self.email = ""
//                    self.phone = ""
//                    self.www = ""
//                    self.facebook = ""
//                    self.instagram = ""
//                    self.tags = []
//                    self.isActive = false
//                    self.isChecked = true
//                    
//                    self.fetched = true
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
                    
                    if user.status == .admin || user.status == .moderator {
                        self.showAdminFields = true
                    }
                    
                    self.fetched = true
                    
                    
                }
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: errorManager.errorMessage, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: errorManager.errorMessage, img: nil, color: nil))
            }
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    func updateTitleAndType(name: String, type: EventType) async -> Bool {
        do {
            try await networkManager.updateTitleAndType(id: id, name: name, type: type, user: user)
            await MainActor.run {
                self.name = name
                self.type = type
                event?.name = name
                event?.type = type
            }
            return true
        } catch NetworkErrors.noConnection {
            errorManager.showNetworkNoConnected()
        } catch NetworkErrors.apiError(let apiError) {
            errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
        } catch {
            errorManager.showError(model: ErrorModel(error: error, message: errorManager.updateMessage, img: nil, color: nil))
        }
        return false
    }
        
    func updateTime(startDate: Date, startTime: Date?, finishDate: Date?, finishTime: Date?) async -> Bool {
        do {
            try await networkManager.updateTime(id: id, startDate: startDate, startTime: startTime, finishDate: finishDate, finishTime: finishTime, user: user)
            await MainActor.run {
                self.startDate = startDate
                self.startTime = startTime
                self.finishDate = finishDate
                self.finishTime = finishTime
                event?.startDate = startDate
                event?.startTime = startTime
                event?.finishDate = finishDate
                event?.finishTime = finishTime
            }
            return true
        } catch NetworkErrors.noConnection {
            errorManager.showNetworkNoConnected()
        } catch NetworkErrors.apiError(let apiError) {
            errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
        } catch {
            errorManager.showError(model: ErrorModel(error: error, message: errorManager.updateMessage, img: nil, color: nil))
        }
        return false
    }
    
    func updateAbout(about: String) async -> Bool {
            do {
                try await networkManager.updateAbout(id: id, about: about.isEmpty ? nil : about, user: user)
                await MainActor.run {
                    self.about = about
                    event?.about = about
                }
                return true
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: errorManager.updateMessage, img: nil, color: nil))
            }
            return false
    }
    
    func updateAdditionalInformation(email: String?, phone: String?, www: String?, facebook: String?, instagram: String?, tags: [Tag]?) async -> Bool {
            do {
                try await networkManager.updateAdditionalInformation(id: id, email: email, phone: phone, www: www, facebook: facebook, instagram: instagram, tags: tags, user: user)
                await MainActor.run {
                    self.phone = phone ?? ""
                    self.www = www ?? ""
                    self.facebook = facebook ?? ""
                    self.instagram = instagram ?? ""
                    self.tags = tags ?? []
                    self.email = email ?? ""
                    event?.phone = phone
                    event?.www = www
                    event?.facebook = facebook
                    event?.instagram = instagram
                    event?.tags = tags ?? []
                }
                return true
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: errorManager.updateMessage, img: nil, color: nil))
            }
            return false
    }
    
    func updateActivity(isActive: Bool, isChecked: Bool, adminNotes: String) async -> Bool {
        do {
            try await networkManager.updateActivity(id: id, isActive: isActive, isChecked: isChecked, adminNotes: adminNotes.isEmpty ? nil : adminNotes, user: user)
            await MainActor.run {
                self.isActive = isActive
                self.isChecked = isChecked
                self.adminNotes = adminNotes
            }
            return true
        } catch NetworkErrors.noConnection {
            errorManager.showNetworkNoConnected()
        } catch NetworkErrors.apiError(let apiError) {
            errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
        } catch {
            errorManager.showError(model: ErrorModel(error: error, message: errorManager.updateMessage, img: nil, color: nil))
        }
        return false
    }
    
    func updatePoster(uiImage: UIImage) {
        self.isLoadingPoster = true
        Task {
            do {
                let scaledImage = uiImage.cropImage(maxWidth: 750, maxHeight: 750)
                let scaledSmallImage = uiImage.cropImage(maxWidth: 350, maxHeight: 350)
                let urls = try await networkManager.updatePoster(eventId: id, poster: scaledImage, smallPoster: scaledSmallImage, from: user)
                let image = Image(uiImage: uiImage)
                await MainActor.run {
                    self.poster = AdminPhoto(id: UUID().uuidString, image: image, url: urls.posterUrl)
                    self.smallPoster = AdminPhoto(id: UUID().uuidString, image: image, url: urls.smallPosterUrl)
                    if let event {
                        event.poster = urls.posterUrl
                        event.smallPoster = urls.smallPosterUrl
                        event.image = image
                    }
                }
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: errorManager.errorMessage, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: errorManager.errorMessage, img: nil, color: nil))
            }
            await MainActor.run {
                self.isLoadingPoster = false
            }
        }
    }
    
    
//    func updateInfo() async -> Bool {
//        let errorModel = ErrorModel(message: "Something went wrong. The city didn't update in database. Please try again later.", img: nil, color: nil)
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

    
    func deletePoster() {
        self.isLoadingPoster = true
        Task {
            do {
                try await networkManager.deletePoster(eventId: id, from: user)
                await MainActor.run {
                    self.poster = nil
                    self.smallPoster = nil
                    if let event {
                        event.poster = nil
                        event.smallPoster = nil
                        event.image = nil
                    }
                }
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: errorManager.errorMessage, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: errorManager.errorMessage, img: nil, color: nil))
            }
            await MainActor.run {
                self.isLoadingPoster = false
            }
        }
    }
    
    func deleteEvent() {
        self.isLoading = true
        Task {
            do {
                try await networkManager.deleteEvent(eventId: id, from: user)
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: errorManager.errorMessage, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: errorManager.errorMessage, img: nil, color: nil))
            }
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}
