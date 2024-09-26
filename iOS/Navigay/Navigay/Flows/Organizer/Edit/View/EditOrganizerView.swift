//
//  EditOrganizerView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.09.24.
//

import SwiftUI

struct EditOrganizerView: View {
    
    // MARK: - Private Properties
    
    @StateObject private var viewModel: EditOrganizerViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Inits
    
    init(viewModel: EditOrganizerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                if viewModel.fetched {
                    listView
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text("ID: \(viewModel.id)")
                            .font(.caption).bold()
                            .foregroundStyle(.secondary)
                        Text("Edit Organizer")
                            .font(.headline).bold()
                    }
                    
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        AppImages.iconLeft
                            .bold()
                            .frame(width: 30, height: 30, alignment: .leading)
                    }
                    .tint(.primary)
                }
            }
            .disabled(viewModel.mainPhotoLoading)
            .disabled(viewModel.avatarLoading)
            .disabled(viewModel.libraryPhotoLoading)
            .disabled(viewModel.isLoading)
            .onAppear() {
                viewModel.fetched = true //delete!
                //viewModel.fetch()
            }
        }
    }
    
    // MARK: - Views
    
    private var listView: some View {
        GeometryReader{ geometry in
            List {
                photosView(width: geometry.size.width)
                titleView
                informationView
                additionalInformationView
                requiredInformationView
                if viewModel.user.status == .admin || viewModel.user.status == .moderator {
                    adminView
                }
                Button("Delete Organizer") {
                    viewModel.showDeleteSheet.toggle()
                }
                .buttonStyle(.bordered)
                .padding()
                .alert("Delete Organizer", isPresented: $viewModel.showDeleteSheet) {
                    Button("Delete", role: .destructive) {
//                        guard let user = authenticationManager.appUser else {
//                            return
//                        }
//                        viewModel.deleteEvent(user: user)
                    }
                    Button("Cancel", role: .cancel) {
                        viewModel.showDeleteSheet.toggle()
                    }
                } message: {
                    Text("Are you shure you want to delete this Organizer?")
                }
                
                Color.clear
                    .frame(height: 50)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var titleView: some View {
        Section {
            NavigationLink {
              //  EditPlaceTitleView(viewModel: viewModel)
            } label: {
                headerText(text: "Title")
            }
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                Text(viewModel.name).bold()
                    .padding(.vertical)
            }
            Spacer(minLength: 40)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    //todo doulicate editPlace
    private func headerText(text: String) -> some View {
        HStack {
            Text(text)
                .font(.title3).bold()
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Edit")
                .foregroundStyle(.blue)
        }
    }
    
    private var informationView: some View {
        Section {
            NavigationLink {
               // EditPlaceAboutView(viewModel: viewModel)
            } label: {
                headerText(text: "Information")
            }
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                Group {
                    if viewModel.about.isEmpty {
                        Text("Informations is not added.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(viewModel.about)
                            .lineLimit(5)
                    }
                }
                .padding(.vertical)
            }
            Spacer(minLength: 40)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    private var additionalInformationView: some View {
        Section {
            NavigationLink {
               // EditPlaceAdditionalInfoView(viewModel: viewModel)
            } label: {
                headerText(text: "Additional Information")
            }
            VStack(spacing: 0) {
                Divider()
                VStack(spacing: 20) {
                    if viewModel.otherInfo.isEmpty {
                        Text("Other informations is not added.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(viewModel.otherInfo)
                    }
                    HStack {
                        AppImages.iconEnvelope
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(viewModel.email.isEmpty ? AppColors.lightGray3 : .primary)
                            .frame(maxWidth: .infinity)
                        AppImages.iconPhoneFill
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(viewModel.phone.isEmpty ? AppColors.lightGray3 : .primary)
                            .frame(maxWidth: .infinity)
                        AppImages.iconGlobe
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(viewModel.www.isEmpty ? AppColors.lightGray3 : .primary)
                            .frame(maxWidth: .infinity)
                        AppImages.iconFacebook
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(viewModel.facebook.isEmpty ? AppColors.lightGray3 : .primary)
                            .frame(maxWidth: .infinity)
                        AppImages.iconInstagram
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(viewModel.instagram.isEmpty ? AppColors.lightGray3 : .primary)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical)
            }
            Spacer(minLength: 40)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    
    private var requiredInformationView: some View {
        Section {
            NavigationLink {
                EmptyView()
                    //
            } label: {
                headerText(text: "Location")
            }
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 10) {
                    Text(viewModel.cityEnglish ?? "city")
                    Text("•")
                    Text(viewModel.countryEnglish ?? "country")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
            Spacer(minLength: 40)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    private var adminView: some View {
        Section {
            NavigationLink {
              //  EditPlaceAdminView(viewModel: viewModel)
            } label: {
                headerText(text: "Admin Panel")
            }
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                VStack(alignment: .leading) {
                    HStack {
                        Text("•")
                            .font(.title).bold()
                            .foregroundStyle(viewModel.isActive ? .green : .red)
                        Text(viewModel.isActive ? "active" : "not active")
                            .foregroundStyle(viewModel.isActive ? .green : .red)
                    }
                    HStack(spacing: 10) {
                        Text("•")
                            .font(.title).bold()
                            .foregroundStyle(viewModel.isChecked ? .green : .red)
                        Text(viewModel.isChecked ? "checked" : "not checked")
                            .foregroundStyle(viewModel.isChecked ? .green : .red)
                    }
                }
                .padding(.vertical)
                Text(viewModel.adminNotes.isEmpty ? "Notes are not added." : viewModel.adminNotes)
                    .foregroundStyle(viewModel.adminNotes.isEmpty ? .secondary : .primary)
                    .font(.callout)
            }
            Spacer(minLength: 40)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    //doto dublicate with edit Place
    private func photosView(width: CGFloat) -> some View {
        Section {
            ZStack(alignment: .bottomLeading) {
                mainPhotoView(width: width)
                avatarView
            }
            EditLibraryView(photos: $viewModel.photos, isLoading: $viewModel.libraryPhotoLoading, width: width) { result in
                viewModel.updateLibraryPhoto(uiImage: result.uiImage, photoId: result.id)
            } onDelete: { id in
                viewModel.deleteLibraryPhoto(photoId: id)
            }
            .padding(.vertical)
            Spacer(minLength: 40)
        }
        .listRowSeparator(.hidden)
        .listSectionSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    //doto dublicate with edit Place
    private func mainPhotoView(width: CGFloat) -> some View {
        PhotoEditView(canDelete: false, canAddFromUrl: true) {
            ZStack {
                if let photo = viewModel.mainPhoto {
                    if let image = photo.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: (width / 4) * 5)
                            .clipped()
                            .opacity(viewModel.mainPhotoLoading ? 0.2 : 1)
                    } else if let url = photo.url {
                        ImageLoadingView(url: url, width: width, height:  (width / 4) * 5, contentMode: .fill) {
                            AppColors.lightGray6
                        }
                        .clipped()
                        .opacity(viewModel.mainPhotoLoading ? 0.2 : 1)
                    }
                } else {
                    AppImages.iconCamera
                        .resizable()
                        .scaledToFit()
                        .opacity(viewModel.mainPhotoLoading ? 0 : 1)
                        .tint(.primary)
                        .frame(width: 100)
                        .frame(width: width, height: (width / 4) * 5)
                        .background(AppColors.lightGray6)
                }
                if viewModel.mainPhotoLoading {
                    ProgressView()
                        .tint(.blue)
                }
            }
        } onSave: { uiImage in
            viewModel.updateMainPhoto(uiImage: uiImage)
        } onDelete: {}
    }
    
    //doto dublicate with edit Place
    private var avatarView:  some View {
        PhotoEditView(canDelete: false, canAddFromUrl: true) {
            ZStack {
                AppColors.background
                    .frame(width: 80, height: 80)
                    .clipShape(.circle)
                    .padding()
                if let photo = viewModel.avatar {
                    if let image = photo.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .opacity(viewModel.avatarLoading ? 0.3 : 1)
                            .overlay(Circle().stroke(Color.white, lineWidth: 5))
                            .padding()
                    } else if let url = photo.url {
                        ImageLoadingView(url: url, width: 80, height: 80, contentMode: .fill) {
                            AppColors.lightGray6
                        }
                        .clipShape(Circle())
                        .opacity(viewModel.avatarLoading ? 0.2 : 1)
                        .overlay(Circle().stroke(Color.white, lineWidth: 5))
                        .padding()
                    }
                } else {
                    AppImages.iconCamera
                        .resizable()
                        .scaledToFit()
                        .opacity(viewModel.avatarLoading ? 0 : 1)
                        .tint(.primary)
                        .frame(width: 40)
                        .frame(width: 80, height: 80)
                        .background(AppColors.background, in: Circle())
                        .padding()
                }
                if viewModel.avatarLoading {
                    ProgressView()
                        .tint(.blue)
                }
            }
        } onSave: { uiImage in
            viewModel.updateAvatar(uiImage: uiImage)
        } onDelete: {}
    }
}

#Preview {
    let appSettingsManager = AppSettingsManager()
    let errorManager = ErrorManager()
    let keychainManager = KeychainManager()
    let networkMonitorManager = NetworkMonitorManager(errorManager: errorManager)
    let networkManager = NetworkManager(session: URLSession.shared, networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager, keychainManager: keychainManager)
    let editOrganizerNetworkManager: EditOrganizerNetworkManagerProtocol = EditOrganizerNetworkManager(networkManager: networkManager)
    let decodedUser = DecodedAppUser(id: 0, name: "Dima", email: "test@test.ru", status: .admin, sessionKey: "fddddddd", bio: "dddd", photo: nil)
    let user = AppUser(decodedUser: decodedUser)
    EditOrganizerView(viewModel: EditOrganizerViewModel(id: 0, organizer: nil, user: user, networkManager: editOrganizerNetworkManager, errorManager: errorManager))
      //  .modelContainer(for: [Place.self], inMemory: false)
}

