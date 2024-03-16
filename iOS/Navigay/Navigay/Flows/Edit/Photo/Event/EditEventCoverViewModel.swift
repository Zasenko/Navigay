//
//  EditEventCoverViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.11.23.
//

import SwiftUI

final class EditEventCoverViewModel: ObservableObject {
    
    //MARK: - Properties
    
//    @Published var showPicker: Bool = false
//    @Published var pickerImage: UIImage? {
//        didSet {
//            if let pickerImage {
//                loadPoster(uiImage: pickerImage)
//            }
//        }
//    }
    @Published var poster: Image?
    @Published var smallPoster: Image?
    
    @Published var posterUIImage: UIImage?
    @Published var smallPosterUIImage: UIImage?
    
    @Published var isLoading: Bool = false
    
    //MARK: - Private Properties
    
  //  private let networkManager: EventNetworkManagerProtocol
  //  private let errorManager: ErrorManagerProtocol
  //  private var eventId: Int
    
  //  private let errorModel = ErrorModel(message: "Something went wrong. The poster didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
    
    //MARK: - Inits
    
    init(poster: Image?, smallPoster: Image?) {
        self.poster = poster
        self.smallPoster = smallPoster
//        self.eventId = eventId
//        self.networkManager = networkManager
//        self.errorManager = errorManager
    }
}

extension EditEventCoverViewModel {
    
    //MARK: - Functions
    
    func createPoster(uiImage: UIImage) {
        Task {
            let scaledImage = uiImage.cropImage(maxWidth: 750, maxHeight: 750)
            let scaledSmallImage = uiImage.cropImage(maxWidth: 350, maxHeight: 350)
                await MainActor.run {
                    self.poster = Image(uiImage: scaledImage)
                    self.smallPoster = Image(uiImage: scaledSmallImage)
                    
                    self.posterUIImage = scaledImage
                    self.smallPosterUIImage = scaledSmallImage
                }
        }
    }
    
    func deletePoster() {
        poster = nil
        smallPoster = nil
        posterUIImage = nil
        smallPosterUIImage = nil
    }
    
//    func createSmallPoster(uiImage: UIImage) {
//        isLoading = true
//        let previousImage = poster
//        poster = Image(uiImage: uiImage)
//       // updateEvents(posters: id, uiImage: uiImage, previousImage: previousImage, addedBy: addedBy, sessionKey: sessionKey)
//      //  update(uiImage: uiImage, previousImage: previousImage)
//        
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
    
//    func loadPosters(posters id: [Int], uiImage: UIImage, addedBy: Int, sessionKey: String) {
//        isLoading = true
//        let previousImage = poster
//        poster = Image(uiImage: uiImage)
//        updateEvents(posters: id, uiImage: uiImage, previousImage: previousImage, addedBy: addedBy, sessionKey: sessionKey)
//      //  update(uiImage: uiImage, previousImage: previousImage)
//    }
    
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
    
//    private func updateEvents(posters ids: [Int], uiImage: UIImage, previousImage: Image?, addedBy: Int, sessionKey: String) {
//        Task {
//            let scaledImage = uiImage.cropImage(maxWidth: 750, maxHeight: 750)
//            let scaledImageSmall = uiImage.cropImage(maxWidth: 350, maxHeight: 350)
//            do {
//                let decodedResult = try await networkManager.updateEventsPoster(ids: ids, poster: scaledImage, smallPoster: scaledImageSmall, addedBy: addedBy, sessionKey: sessionKey)
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
