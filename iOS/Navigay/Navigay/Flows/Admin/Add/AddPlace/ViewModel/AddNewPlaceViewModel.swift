//
//  AddNewPlaceViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 25.10.23.
//

import SwiftUI

final class AddNewPlaceViewModel: ObservableObject {
    
    //MARK: - Properties
    
    @Published var router: AddNewPlaceRouter = .photos
    
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
    
    //@Published var secectedPhotosPickerItem: PhotosPickerItem?
    @Published var croppedImageBig: Image?
    @Published var croppedImageSmall: Image?
    @Published var uiImageBig: UIImage?
    @Published var uiImageSmall: UIImage?
    
    @Published var tags: [Tag] = []
    @Published var timetable: [NewWorkingDay] = []
    @Published var otherInfo: String = ""
    @Published var languages: [Language] = Language.allCases
    @Published var about: [PlaceAbout] = []
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var www: String = ""
    @Published var facebook: String = ""
    @Published var instagram: String = ""
    
    @Published var isOwned: Bool = false
    
    @Published var isActive: Bool = false
    @Published var isChecked: Bool = false
    
    @Published var showMap: Bool = false
    
    //MARK: - Private Properties
    
    private let networkManager: AddNetworkManagerProtocol
    private var id: Int? = nil
    private var place: DecodedPlace? = nil
    
    //MARK: - Inits
    
    init(networkManager: AddNetworkManagerProtocol) {
        self.networkManager = networkManager
    }
}
extension AddNewPlaceViewModel {
    
    //MARK: - Functions
    
    func chanchRouter(page: AddNewPlaceRouter) {
        withAnimation {
            self.router = page
        }
    }
    
    func addNewPlace() {
        Task {
            guard !name.isEmpty else { return }
            guard let type = type?.rawValue else { return }
            guard !isoCountryCode.isEmpty else { return }
            guard !addressOrigin.isEmpty else { return }
            guard let latitude else { return }
            guard let longitude else { return }
            
            let newPlace: PlaceRequiredInfo = PlaceRequiredInfo(name: name,
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
                                                                longitude: longitude)
                                                                //ownerId: nil)
            do {
                let result = try await networkManager.addNewPlace(place: newPlace)
                //TODO ошибки и id
                if let place = result.place {
                    self.place = place
                    router = .photos
                }
            } catch {
                //TODO
                print("Что-то пошло не так... Место не добавилось.")
                print(error)
            }
        }
    }
    
//    func addAdditionalInformation() {
//        Task {
//         //   guard let id = place?.id else { return }
//            let id = 24
//            let about = about.map( { PlaceAboutForSend(language: $0.language.rawValue, about: $0.about) } )
//            let tags = tags.map( { $0.rawValue} )
//            let timetable = timetable.map( { PlaceWorkDay(day: $0.day, opening: $0.opening.format("HH:mm"), closing: $0.closing.format("HH:mm")) } )
//            
//            let newPlace: PlaceAdditionalInfo = PlaceAdditionalInfo(id: id,
//                                                                    about: about.isEmpty ? nil : about,
//                                                                    tags: tags.isEmpty ? nil : tags,
//                                                                    timetable: timetable.isEmpty ? nil : timetable,
//                                                                    otherInfo: otherInfo.isEmpty ? nil : otherInfo,
//                                                                    email: email.isEmpty ? nil : email,
//                                                                    phone: phone.isEmpty ? nil : phone,
//                                                                    www: www.isEmpty ? nil : www,
//                                                                    facebook: facebook.isEmpty ? nil : facebook,
//                                                                    instagram: instagram.isEmpty ? nil : instagram)
//            do {
//                let result = try await networkManager.addAdditionalInfoToPlace(place: newPlace)
//                //TODO ошибки и id
//                if let place = result.place {
//                    self.place = place
//                    router = .mainInfo
//                }
//            } catch {
//                //TODO
//                print("Что-то пошло не так... Место не добавилось.")
//                print(error)
//            }
//        }
//    }
    
    //    func addNewPlace() {
    //        Task {
    //            guard !name.isEmpty else { return }
    //            guard let type = type?.rawValue else { return }
    //            guard !isoCountryCode.isEmpty else { return }
    //            guard !addressOrigin.isEmpty else { return }
    //            guard let latitude else { return }
    //            guard let longitude else { return }
    //            let about = about.map( { AboutPlace(language: $0.language.rawValue, about: $0.about) } )
    //            let tags = tags.map( { $0.rawValue} )
    //            let timetable = timetable.map( { PlaceWorkDay(day: $0.day, opening: $0.opening.format("HH:mm"), closing: $0.closing.format("HH:mm")) } )
    //            let newPlace: NewPlace = NewPlace(name: name,
    //                                              type: type,
    //                                              isoCountryCode: isoCountryCode,
    //                                              countryOrigin: countryOrigin.isEmpty ? nil : countryOrigin,
    //                                              countryEnglish: countryEnglish.isEmpty ? nil : countryEnglish,
    //                                              regionOrigin: regionOrigin.isEmpty ? nil : regionOrigin,
    //                                              regionEnglish: regionEnglish.isEmpty ? nil : regionEnglish,
    //                                              cityOrigin: cityOrigin.isEmpty ? nil : cityOrigin,
    //                                              cityEnglish: cityEnglish.isEmpty ? nil : cityEnglish,
    //                                              address: addressOrigin,
    //                                              latitude: latitude,
    //                                              longitude: longitude,
    //                                              about: about.isEmpty ? nil : about,
    //                                              tags: tags.isEmpty ? nil : tags,
    //                                              timetable: timetable.isEmpty ? nil : timetable,
    //                                              otherInfo: otherInfo.isEmpty ? nil : otherInfo,
    //                                              email: email.isEmpty ? nil : email,
    //                                              phone: phone.isEmpty ? nil : phone,
    //                                              www: www.isEmpty ? nil : www,
    //                                              facebook: facebook.isEmpty ? nil : facebook,
    //                                              instagram: instagram.isEmpty ? nil : instagram,
    //                                              ownerId: nil,
    //                                              isActive: isActive,
    //                                              isChecked: isChecked)
    //
    //            do {
    //                let place = try await networkManager.addNewPlace(place: newPlace, uiImageSmall: uiImageSmall, uiImageBig: uiImageBig)
    //            } catch {
    //                print(error)
    //            }
    //        }
    //    }
    
    func cropSmallImage(uiImage: UIImage) {
        Task {
            let targetSizeSmall = CGSize(width: 100, height: 100)
            let scaledImageSmall = uiImage.scaleAndFill(targetSize: targetSizeSmall)
            await MainActor.run {
                croppedImageSmall = Image(uiImage: scaledImageSmall)
                uiImageSmall = scaledImageSmall
            }
        }
    }
    
    func cropBigImage(uiImage: UIImage) {
        Task {
            let targetSizeBig = CGSize(width: 600, height: 750)
            let scaledImageBig = uiImage.scaleAndFill(targetSize: targetSizeBig)
            await MainActor.run {
                croppedImageBig = Image(uiImage: scaledImageBig)
                uiImageBig = scaledImageBig
            }
        }
    }
}
