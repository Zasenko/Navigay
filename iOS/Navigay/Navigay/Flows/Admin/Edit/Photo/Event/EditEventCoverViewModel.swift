//
//  EditEventCoverViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.11.23.
//

import SwiftUI
import PhotosUI

final class EditEventCoverViewModel: ObservableObject {
    
    //MARK: - Properties
    
    @Published var showPosterPhotoPicker: Bool = false
    @Published var posterPickerItem: PhotosPickerItem? = nil
    @Published var poster: Image?
    @Published var isLoading: Bool = false
    
    //MARK: - Private Properties
    
    private let networkManager: EventNetworkManagerProtocol
    private let errorManager: ErrorManagerProtocol
    private var eventId: Int
    
    private let errorModel = ErrorModel(massage: "Something went wrong. The poster didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
    
    //MARK: - Inits
    
    init(poster: Image?, eventId: Int, networkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
        self.poster = poster
        self.eventId = eventId
        self.networkManager = networkManager
        self.errorManager = errorManager
    }
}

extension EditEventCoverViewModel {
    
    //MARK: - Functions
    
    @MainActor
    func loadPoster(uiImage: UIImage) {
        isLoading = true
        let previousImage = poster
        poster = Image(uiImage: uiImage)
        update(uiImage: uiImage, previousImage: previousImage)
    }
    
    //MARK: - Private Functions
    
    private func update(uiImage: UIImage, previousImage: Image?) {
        Task {
            let scaledImage = uiImage.cropImage(maxWidth: 750, maxHeight: 750)
            let scaledImageSmall = uiImage.cropImage(maxWidth: 350, maxHeight: 350)
            do {
                let decodedResult = try await networkManager.updatePoster(eventId: eventId, poster: scaledImage, smallPoster: scaledImageSmall)
                guard decodedResult.result else {
                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                    return
                }
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                debugPrint("ERROR - updateAvatar: ", error)
                errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
                await MainActor.run {
                    self.isLoading = false
                    self.poster = previousImage
                }
            }
        }
    }
}
