//
//  NewEventViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 11.11.23.
//

import SwiftUI

enum NewEventRouter {
    case info
    case poster
}

final class NewEventViewModel: ObservableObject {
    
    //MARK: - Properties
    
    var id: Int? = nil
    
    @Published var router: NewEventRouter = .info
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
    let networkManager: EventNetworkManagerProtocol
    
    //MARK: - Private Properties
    
    private let place: Place?
    
    //MARK: - Inits
    
    init(place: Place?, networkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
        self.place = place
        self.networkManager = networkManager
        self.errorManager = errorManager
        
        if let isoCountryCode = place?.city?.region?.country?.isoCountryCode,
           place?.city?.region?.country?.id != nil,
           place?.city?.region?.id != nil,
           place?.city?.id != nil {
            self.addressOrigin = place?.address ?? ""
            self.isoCountryCode = isoCountryCode
            self.latitude = place?.latitude
            self.longitude = place?.longitude
            self.location = place?.name ?? ""
        }
    }
}

extension NewEventViewModel {
    
    func addNewEvent(user: AppUser) {
        isLoading = true
        Task {
            guard !name.isEmpty,
                  let type = type?.rawValue,
                  !isoCountryCode.isEmpty,
                  !addressOrigin.isEmpty,
                  let latitude,
                  let longitude,
                  let startDateString = startDate?.format("yyyy-MM-dd")
            else {
                await MainActor.run {
                    isLoading = false
                }
                return
            }
            let startTimeString = startTime?.format("HH:mm")
            let finishDateString = finishDate?.format("yyyy-MM-dd")
            let finishTimeString = finishTime?.format("HH:mm")
            let tags = tags.map( { $0.rawValue} )
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
                                              startDate: startDateString,
                                              startTime: startTimeString,
                                              finishDate: finishDateString,
                                              finishTime: finishTimeString,
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
                                              addedBy: user.id,
                                              isActive: isActive,
                                              isChecked: isChecked,
                                              countryId: place?.city?.region?.country?.id,
                                              regionId: place?.city?.region?.id,
                                              cityId: place?.city?.id)
            let id = await networkManager.addNewEvent(event: newEvent)
            await MainActor.run {
                if let id {
                    self.id = id
                    self.isLoading = false
                    withAnimation {
                        self.router = .poster
                    }
                } else {
                    self.isLoading = false
                }
            }
        }
    }
}
