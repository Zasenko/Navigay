//
//  AddNewPlaceViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 25.10.23.
//

import SwiftUI


final class AddNewPlaceViewModel: ObservableObject {
    
    //MARK: - Properties
    
    @Published var id: Int?
    @Published var name: String = ""
    @Published var type: PlaceType? = nil
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
    @Published var showMap: Bool = false
    @Published var isLoading: Bool = false
    @Published var showEditView: Bool = false
    
    let errorManager: ErrorManagerProtocol
    let networkManager: EditPlaceNetworkManagerProtocol
    
    //MARK: - Private Properties
        
    //MARK: - Inits
    
    init(networkManager: EditPlaceNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
        self.networkManager = networkManager
        self.errorManager = errorManager
    }
}
extension AddNewPlaceViewModel {
    
    //MARK: - Functions
    
    func addNewPlace(from user: AppUser) {
        isLoading = true
        Task {
            let errorMessage = "Something went wrong. The place didn't load to database. Please try again later."
            guard !name.isEmpty else { return }
            guard let type = type?.rawValue else { return }
            guard !isoCountryCode.isEmpty else { return }
            guard !addressOrigin.isEmpty else { return }
            guard let latitude else { return }
            guard let longitude else { return }
            let tags = tags.map( { $0.rawValue} )
            let timetable = timetable.map( { PlaceWorkDay(day: $0.day, opening: $0.opening.format("HH:mm"), closing: $0.closing.format("HH:mm")) } )
            let newPlace: NewPlace = NewPlace(name: name,
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
                                              about: about.isEmpty ? nil : about,
                                              tags: tags.isEmpty ? nil : tags,
                                              timetable: timetable.isEmpty ? nil : timetable,
                                              otherInfo: otherInfo.isEmpty ? nil : otherInfo,
                                              email: email.isEmpty ? nil : email,
                                              phone: phone.isEmpty ? nil : phone,
                                              www: www.isEmpty ? nil : www,
                                              facebook: facebook.isEmpty ? nil : facebook,
                                              instagram: instagram.isEmpty ? nil : instagram,
                                              ownderId: isOwned ? user.id : nil,
                                              addedBy: user.id,
                                              isActive: isActive,
                                              isChecked: isChecked)
            do {
                let decodedResult = try await networkManager.addNewPlace(place: newPlace)
                await MainActor.run {
                    self.isLoading = false
                    self.id = decodedResult
//                    withAnimation {
//                        self.router = .photos
//                    }
                }
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: errorMessage, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: errorMessage, img: nil, color: nil))
            }
        }
    }
}
