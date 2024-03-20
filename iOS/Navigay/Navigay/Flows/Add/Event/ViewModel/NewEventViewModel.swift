//
//  NewEventViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 11.11.23.
//

import SwiftUI

struct EventTime: Identifiable {
    let id: UUID = .init()
    var startDate: Date?
    var startTime: Date?
    var finishDate: Date?
    var finishTime: Date?
}

struct EventTimeToSend: Codable {
    let startDate: String
    let startTime: String?
    let finishDate: String?
    let finishTime: String?
}

final class NewEventViewModel: ObservableObject {
    
    //MARK: - Properties
    
    var ids: [Int]? = nil
    
    @Published var showAddPosterView: Bool = false
    @Published var isEventAdded: Bool = false
    
    @Published var name: String = ""
    @Published var type: EventType? = nil
    @Published var isoCountryCode: String = ""
    @Published var countryOrigin: String = ""
    @Published var countryEnglish: String = ""
    @Published var regionOrigin: String = ""
    @Published var regionEnglish: String = ""
    @Published var cityOrigin: String = ""
    @Published var cityEnglish: String = ""
    @Published var addressOrigin: String = ""
    @Published var latitude: Double? = nil
    @Published var longitude: Double? = nil
    
    @Published var startDate: Date? = nil
    @Published var startTime: Date? = nil
    @Published var finishDate: Date? = nil
    @Published var finishTime: Date? = nil
    
    @Published var repeatDates: [EventTime] = []
    
    @Published var isFree: Bool = false
    @Published var fee: String = ""
    @Published var tickets: String = ""
    
    @Published var tags: [Tag] = []

    @Published var about: String = ""
    
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var www: String = ""
    @Published var facebook: String = ""
    @Published var instagram: String = ""
    
    @Published var location: String = ""
    @Published var isOwned: Bool = false
    @Published var isActive: Bool = false
    @Published var isChecked: Bool = false
    
    @Published var isLoading: Bool = false
    
    let errorManager: ErrorManagerProtocol
    let networkManager: EditEventNetworkManagerProtocol
    
    //MARK: - Private Properties
    
    private var place: Place? = nil

    //MARK: - Inits
    
    init(place: Place?, copy event: Event?, networkManager: EditEventNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
        if let place,
           let isoCountryCode = place.city?.region?.country?.isoCountryCode,
           place.city?.region?.country?.id != nil,
           place.city?.region?.id != nil,
           place.city?.id != nil {
            self.addressOrigin = place.address
            self.isoCountryCode = isoCountryCode
            self.latitude = place.latitude
            self.longitude = place.longitude
            self.location = place.name
            self.place = place
        } else if let event {
            self.name = event.name
            self.startTime = event.startTime
            self.finishTime = event.finishTime
            self.about = event.about ?? ""
            self.type = event.type
            self.addressOrigin = event.address
            self.latitude = event.latitude
            self.longitude = event.longitude
            self.isFree = event.isFree
            self.tags = event.tags
            self.location = event.location ?? ""
            self.www = event.www ?? ""
            self.instagram = event.instagram ?? ""
            self.phone = event.phone ?? ""
            self.fee = event.fee ?? ""
            if let place = event.place,
               let isoCountryCode = place.city?.region?.country?.isoCountryCode {
                self.isoCountryCode = isoCountryCode
                self.place = place
            }
        }
        
        self.networkManager = networkManager
        self.errorManager = errorManager
    }
}

extension NewEventViewModel {
    
    func cloneDate(newDate: Date) {
        guard let existingStartDate = startDate else {
            return
        }
        var updatedFinishDate: Date? = nil
        if let existingFinishDate = finishDate {
            let calendar = Calendar.current
            let difference = calendar.dateComponents([.day], from: existingStartDate, to: existingFinishDate)
            if let updatedFinish = calendar.date(byAdding: difference, to: newDate) {
                updatedFinishDate = updatedFinish
            }
        }
        let newEventTime = EventTime(startDate: newDate, startTime: startTime, finishDate: updatedFinishDate, finishTime: finishTime)
        repeatDates.append(newEventTime)
    }
    
    func addNewEvent(user: AppUser) {
        isLoading = true
        Task {
            guard let sessionKey = user.sessionKey else {
                await MainActor.run {
                    isLoading = false
                }
                return
            }
            guard !name.isEmpty,
                  let type = type?.rawValue,
                  !isoCountryCode.isEmpty,
                  !addressOrigin.isEmpty,
                  let latitude,
                  let longitude
            else {
                await MainActor.run {
                    isLoading = false
                }
                return
            }
            let tags = tags.map( { $0.rawValue} )
            
            var datestToSend: [EventTimeToSend] = []
            guard let startDateString = startDate?.format("yyyy-MM-dd") else {
                await MainActor.run {
                    isLoading = false
                }
                return
            }
            let startTimeString = startTime?.format("HH:mm")
            let finishDateString = finishDate?.format("yyyy-MM-dd")
            let finishTimeString = finishTime?.format("HH:mm")
            datestToSend.append(EventTimeToSend(startDate: startDateString, startTime: startTimeString, finishDate: finishDateString, finishTime: finishTimeString))
            
            let repeatDatesToSend: [EventTimeToSend] = repeatDates.compactMap { repeatDate in
                guard let startDateString = repeatDate.startDate?.format("yyyy-MM-dd") else {
                    return nil
                }
                let startTimeString = repeatDate.startTime?.format("HH:mm")
                let finishDateString = repeatDate.finishDate?.format("yyyy-MM-dd")
                let finishTimeString = repeatDate.finishTime?.format("HH:mm")
                return EventTimeToSend(startDate: startDateString, startTime: startTimeString, finishDate: finishDateString, finishTime: finishTimeString)
            }
            datestToSend.append(contentsOf: repeatDatesToSend)
            
            
            
            guard !datestToSend.isEmpty else {
                await MainActor.run {
                    isLoading = false
                }
                return
            }
            let newEvent: NewEvent = NewEvent(name: name,
                                              type: type,
                                              isoCountryCode: isoCountryCode,
                                              countryOrigin: countryOrigin.isEmpty ? nil : countryOrigin,
                                              countryEnglish: countryEnglish.isEmpty ? nil : countryEnglish,
                                              regionOrigin: regionOrigin.isEmpty ? nil : regionOrigin,
                                              regionEnglish: regionEnglish.isEmpty ? nil : regionEnglish,
                                              cityOrigin: cityOrigin.isEmpty ? nil : cityOrigin,
                                              cityEnglish: cityEnglish.isEmpty ? nil : cityEnglish,
                                              address: addressOrigin,
                                              latitude: latitude,
                                              longitude: longitude,
                                              repeatDates: datestToSend,
                                              location: location.isEmpty ? nil : location,
                                              about: about.isEmpty ? nil : about,
                                              isFree: isFree,
                                              tickets: tickets.isEmpty ? nil : tickets,
                                              fee: fee.isEmpty ? nil : fee,
                                              email: email.isEmpty ? nil : email,
                                              phone: phone.isEmpty ? nil : phone,
                                              www: www.isEmpty ? nil : www,
                                              facebook: facebook.isEmpty ? nil : facebook,
                                              instagram: instagram.isEmpty ? nil : instagram,
                                              tags: tags.isEmpty ? nil : tags,
                                              ownderId: isOwned ? user.id : nil,
                                              placeId: place?.id,
                                              isActive: isActive,
                                              isChecked: isChecked,
                                              countryId: place?.city?.region?.country?.id,
                                              regionId: place?.city?.region?.id,
                                              cityId: place?.city?.id,
                                              userId: user.id,
                                              sessionKey: sessionKey)
            let message = "Something went wrong. The event didn't load. Please try again later."
            do {
                let ids = try await networkManager.addNewEvent(event: newEvent)
                await MainActor.run {
                    self.ids = ids
                    self.isLoading = false
                    withAnimation {
                        self.isEventAdded = true
                        self.showAddPosterView = true
                    }
                }
                return
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: message, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: message, img: nil, color: nil))
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    @MainActor
    func addPoster(to eventsIDs: [Int], poster: UIImage, smallPoster: UIImage, user: AppUser) async -> Bool {
        self.isLoading = true
        do {
            try await networkManager.addPosterToEvents(with: eventsIDs, poster: poster, smallPoster: smallPoster, from: user)
            self.isLoading = false
            return true
        } catch {
            debugPrint("ERROR - updateAvatar: ", error)
            // errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            self.isLoading = false
            return false
        }
    }
    
        //MARK: - Private Functions
        
    //    private func update(uiImage: UIImage, previousImage: Image?) {
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
    //    }
    
}
