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

    @Published var languages: [Language] = Language.allCases
    @Published var about: [NewPlaceAbout] = []
    
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
    
    let user: AppUser
    let errorManager: ErrorManagerProtocol
    let networkManager: EventNetworkManagerProtocol
    
    //MARK: - Private Properties
    
    private let place: Place?
    //MARK: - Inits
    
    init(user: AppUser, place: Place?, networkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
        self.user = user
        self.place = place
        self.networkManager = networkManager
        self.errorManager = errorManager
    }
}

extension NewEventViewModel {
    
    
    func addNewEvent() {
        isLoading = true
        Task {
            let errorModel = ErrorModel(massage: "Something went wrong. The event didn't load to database. Please try again later.", img: nil, color: nil)
            guard !name.isEmpty else { return }
            guard let type = type?.rawValue else { return }
            guard !isoCountryCode.isEmpty else { return }
            guard !addressOrigin.isEmpty else { return }
            guard let latitude else { return }
            guard let longitude else { return }
            
            guard let startDateString = startDate?.format("yyyy-MM-dd") else { return }
            let startTimeString = startTime?.format("HH:mm")
            let finishDateString = finishDate?.format("yyyy-MM-dd")
            let finishTimeString = finishTime?.format("HH:mm")

            let about = about.map( { DecodedAbout(language: $0.language, about: $0.about) } )
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
                                              isChecked: isChecked)
            do {
                let decodedResult = try await networkManager.addNewEvent(event: newEvent)
                guard let id = decodedResult.id, decodedResult.result else {
                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                    return
                }
                await MainActor.run {
                    self.isLoading = false
                    self.id = id
                    withAnimation {
                        self.router = .poster
                    }
                }
            } catch {
                debugPrint("ERROR - addNewEvent: ", error)
                errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}
