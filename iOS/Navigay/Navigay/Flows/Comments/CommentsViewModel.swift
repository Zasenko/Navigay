//
//  CommentsViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.06.24.
//

import SwiftUI

final class CommentsViewModel: ObservableObject {
    
    @Published var comments: [DecodedComment] = []
    @Published var isLoading = true
    @Published var showAddReviewView: Bool = false
    @Published var showRegistrationView: Bool = false
    @Published var showLoginView: Bool = false
    
    let commentsNetworkManager: CommentsNetworkManagerProtocol
    let errorManager: ErrorManagerProtocol
    let size: CGSize
    let place: Place
        
    let firstReviewPrompt = "Hey there! Looks like this place is waiting to be discovered. Share your thoughts and be the first to leave a review!"
    let firstReviewPrompts = [
        "Hey there! Looks like this place is waiting to be discovered. Share your thoughts and be the first to leave a review!",
        "Be the trailblazer! Drop a review for this place and let others know about your experience.",
        "Psst... the review section is feeling lonely. Care to share your thoughts and help others with your feedback?",
        "Ready to be a trendsetter? Leave the first review and pave the way for others!",
        "Silence is golden, but reviews are priceless! Be the first to break the silence and share your thoughts about this place."
    ]
    
    init(commentsNetworkManager: CommentsNetworkManagerProtocol, errorManager: ErrorManagerProtocol, size: CGSize, place: Place) {
        self.commentsNetworkManager = commentsNetworkManager
        self.errorManager = errorManager
        self.size = size
        self.place = place
    }
}

extension CommentsViewModel {
    
    func fetchComments() {
        Task {
            let message = "Oops! Looks like the comments failed to load. Don't worry, we're actively working to resolve the issue."
            do {
                let decodedComments = try await commentsNetworkManager.fetchComments(placeID: place.id)
                await MainActor.run {
                    comments = decodedComments.filter( { $0.isActive } )
                    isLoading = false
                }
            } catch NetworkErrors.noConnection {
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: message, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: message))
            }
        }
    }
    
    func deleteComment(id: Int) {
        comments.removeAll(where: { $0.id == id})
        //commentsNetworkManager.
    }
}
