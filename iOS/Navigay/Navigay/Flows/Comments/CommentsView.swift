//
//  CommentsView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 23.04.24.
//

import SwiftUI

struct CommentsView: View {
    
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    
    let placeNetworkManager: PlaceNetworkManagerProtocol
    let errorManager: ErrorManagerProtocol
    
    let size: CGSize
    let place: Place
    
    @Binding var comments: [DecodedComment]
    
    private let firstReviewPrompt = "Hey there! Looks like this place is waiting to be discovered. Share your thoughts and be the first to leave a review!"
    private let firstReviewPrompts = [
        "Hey there! Looks like this place is waiting to be discovered. Share your thoughts and be the first to leave a review!",
        "Be the trailblazer! Drop a review for this place and let others know about your experience.",
        "Psst... the review section is feeling lonely. Care to share your thoughts and help others with your feedback?",
        "Ready to be a trendsetter? Leave the first review and pave the way for others!",
        "Silence is golden, but reviews are priceless! Be the first to break the silence and share your thoughts about this place."
    ]
    
    @State private var showAddReviewView: Bool = false
    @State private var showRegistrationView: Bool = false
    @State private var showLoginView: Bool = false
    
    var body: some View {
            Section {
                HStack {
                    Text("Reviews")
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let user = authenticationManager.appUser, user.status != .blocked {
                        addReviewButton
                        
                    }
                }
                .padding(.top, 50)
                .padding(.bottom, 10)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                if comments.isEmpty {
                    HStack(alignment: .top, spacing: 10) {
                        AppImages.iconInfoBubble
                            .font(.title)
                            .foregroundStyle(.secondary)
                        Text(firstReviewPrompts.randomElement() ?? firstReviewPrompt)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                }
                
                if authenticationManager.appUser == nil {
                    authButtons
                }
                ForEach(comments) { comment in
                    commentView(comment: comment)
                }
            }
    }
    
    private var addReviewButton: some View {
        Button {
            showAddReviewView.toggle()
        } label: {
            HStack(spacing: 4) {
                AppImages.iconPlus
                    .font(.headline)
                Text("Add review")
                    .font(.caption)
                    .bold()
            }
            .foregroundStyle(.blue)
            .padding()
            .background(AppColors.lightGray6)
            .clipShape(Capsule(style: .continuous))
        }
        .sheet(isPresented: $showAddReviewView) {
            AddCommentView(viewModel: AddCommentViewModel(placeId: place.id, placeNetworkManager: placeNetworkManager, errorManager:errorManager))
        }
    }
    
    private var authButtons: some View {
        HStack {
            Button {
                showLoginView = true
            } label: {
                Text("Log In")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.blue)
                    .padding()
                    .background(AppColors.lightGray6)
                    .clipShape(Capsule(style: .continuous))
            }
            .fullScreenCover(isPresented: $showLoginView) {
                LoginView(viewModel: LoginViewModel(email: nil)) {
                    showLoginView = false
                }
            }
            Button {
                showRegistrationView = true
            } label: {
                Text("Registation")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.blue)
                    .padding()
                    .background(AppColors.lightGray6)
                    .clipShape(Capsule(style: .continuous))
            }
            .fullScreenCover(isPresented: $showRegistrationView) {
                RegistrationView(authenticationManager: authenticationManager, errorManager: authenticationManager.errorManager) {
                    showRegistrationView = false
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .padding(.bottom)
    }
    
    private func commentView(comment: DecodedComment) -> some View {
        VStack(spacing: 10) {
            if comment.rating != 0 {
                HStack(spacing: 4) {
                    ForEach(1..<6) { int in
                        Image(systemName: "star.fill")
                            .font(.caption).bold()
                            .foregroundStyle(int <= comment.rating ? .yellow : AppColors.lightGray5)
                    }
                }
            }
            if let comment = comment.comment {
                Text(comment)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
            }
            if let photos = comment.photos {
                HStack {
                    ForEach(photos, id: \.self) { photo in
                        ImageLoadingView(url: photo, width: size.width / 4, height: size.width / 4, contentMode: .fill) {
                            Color.orange
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppColors.lightGray5, lineWidth: 1))
                    }
                }
            }
            /// User
            HStack(spacing: 20) {
                Text(comment.createdAt)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let user = comment.user {
                    HStack {
                        if let url = user.photo {
                            ImageLoadingView(url: url, width: 32, height: 32, contentMode: .fill) {
                                AppColors.lightGray6 // TODO: animation in ImageLoadingView
                            }
                            .clipShape(.circle)
                        } else {
                            AppImages.iconPerson
                                .font(.callout)
                        }
                        Text(user.name)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Menu {
                    Button{
                        // EDIT
                        // пожаловаться
                        // delite
                    } label: {
                        Text("Button")
                    }
                } label: {
                    AppImages.iconEllipsisRectangle
                        .font(.callout)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            if let reply = comment.reply {
                HStack(alignment: .top) {
                    AppImages.iconArrowTurnDownRight //arrow.turn.down.right
                    Text(reply.comment)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.top)
            }
            Divider()
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let errorManager = ErrorManager()
    let appSettingsManager = AppSettingsManager()
    let keychainManager = KeychainManager()
    let networkMonitorManager = NetworkMonitorManager(errorManager: errorManager)
    let networkManager = AuthNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
    let authenticationManager = AuthenticationManager(keychainManager: keychainManager, networkMonitorManager: networkMonitorManager, networkManager: networkManager, errorManager: errorManager)
    let decodedUser: DecodedAppUser = DecodedAppUser(id: 1, name: "Zasenko", email: "test@test.com", status: .user, sessionKey: "", bio: nil, photo: nil)
    let appUser = AppUser(decodedUser: decodedUser)
    
    let decodedCommentUser1: DecodedUser = DecodedUser(id: 1, name: "Stefan", bio: nil, photo: nil, updatedAt: "2024-02-22")
    let decodedCommentUser2: DecodedUser = DecodedUser(id: 1, name: "Stefan", bio: nil, photo: "https://sun9-64.userapi.com/s/v1/ig2/44i4TMbTQSNnMkNJYcu9VIiE0SFqhmdXuozczFkT_i8gLZ5omWmB3K9T85qrEx6uEyBtSndNHNqdc4XehNDu3V9P.jpg?size=200x200&quality=96&crop=56,56,288,288&ava=1", updatedAt: "2024-02-22")
    authenticationManager.appUser = appUser
    let comments: [DecodedComment] = [
        DecodedComment(id: 1, comment: nil, rating: 2, photos: nil, isActive: true, createdAt: "2024-02-22", reply: nil, user: nil),
        DecodedComment(id: 2, comment: "Very nice place.", rating: 5, photos: nil, isActive: true, createdAt: "2022-05-22", reply: DecodedCommentReply(id: 1, comment: "Thank you so much for your kind words!", isActive: true, createdAt: "2024-02-22"), user: decodedCommentUser2),
        DecodedComment(id: 3, comment: "The source code contains a TabView example as well, but this iOS 16 video almost uses the same concept for the usage of the TabView. Check it out.", rating: 5, photos: nil, isActive: true, createdAt: "2022-02-22", reply: DecodedCommentReply(id: 1, comment: "Thank you so much for your kind words! We're thrilled to hear that you enjoyed your experience at [Place Name]. It's our pleasure to provide excellent service and delicious food to our guests. We truly appreciate your recommendation and can't wait to welcome you back soon!", isActive: true, createdAt: "2024-02-22"), user: decodedCommentUser1),
        DecodedComment(id: 4, comment: "The source code contains a TabView example as well, but this iOS 16 video almost uses the same concept for the usage of the TabView. Check it out.", rating: 4, photos: ["https://modof.club/uploads/posts/2023-09/thumbs/1694178317_modof-club-p-platya-v-stile-maskarad-19.jpg", "https://pictures.pibig.info/uploads/posts/2023-04/thumbs/1680816613_pictures-pibig-info-p-bal-maskarad-risunok-pinterest-36.jpg", ""], isActive: true, createdAt: "2022-02-22", reply: DecodedCommentReply(id: 1, comment: "Thank you so much for your kind words! We're thrilled to hear that you enjoyed your experience at [Place Name]. It's our pleasure to provide excellent service and delicious food to our guests. We truly appreciate your recommendation and can't wait to welcome you back soon!", isActive: true, createdAt: "2024-02-22"), user: decodedCommentUser2)
    ]
    let decodedPlace: DecodedPlace = DecodedPlace(id: 1, name: "", type: .bar, address: "", latitude: 0.0, longitude: 0.0, lastUpdate: "", avatar: nil, mainPhoto: nil, photos: nil, tags: nil, timetable: nil, otherInfo: nil, about: nil, www: nil, facebook: nil, instagram: nil, phone: nil, city: nil, cityId: nil, events: nil)
    let place = Place(decodedPlace: decodedPlace)
    
    let placeNetworkManager = PlaceNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
    return NavigationStack {
        List {
            CommentsView(placeNetworkManager: placeNetworkManager, errorManager: errorManager, size: CGSize(width: 400, height: 700), place: place, comments: .constant(comments))
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .buttonStyle(PlainButtonStyle())
        .environmentObject(authenticationManager)
    }
}
