//
//  EditPlaceView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.01.24.
//

import SwiftUI

struct EditPlaceView: View {
    
    // MARK: - Private Properties
    
    @StateObject private var viewModel: EditPlaceViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Inits
    
    init(viewModel: EditPlaceViewModel) {
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
                        Text("Edit Place")
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
                if !viewModel.fetched {
                    viewModel.fetchPlace()
                }
            }
        }
    }
    
    // MARK: - Views
    
    private var listView: some View {
        GeometryReader{ geometry in
            List {
                photosView(width: geometry.size.width)
                
                Section("Title & Type") {
                    NavigationLink {
                        EditPlaceTitleView(viewModel: viewModel)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(viewModel.name)
                            Text(viewModel.type.getName())
                        }
                    }
                }
                .listRowSeparator(.hidden)
                
                Section("Information") {
                    NavigationLink {
                        EditPlaceAboutView(viewModel: viewModel)
                    } label: {
                        VStack(spacing: 0) {
                            Divider()
                            Text(viewModel.about)
                                .lineLimit(5)
                                .padding(.vertical)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                Section("Additional Information") {
                    NavigationLink {
                        EditPlaceAdditionalInfoView(viewModel: viewModel)
                    } label: {
                        VStack(spacing: 0) {
                            Divider()
                            VStack(spacing: 20) {
                                Text(viewModel.otherInfo)
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                                    ForEach(viewModel.tags, id: \.self) { tag in
                                        Text(tag.getString())
                                            .font(.footnote)
                                            .bold()
                                            .foregroundStyle(AppColors.background)
                                            .padding(5)
                                            .padding(.horizontal, 5)
                                            .background(.secondary)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                                HStack {
                                    AppImages.iconEnvelope
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(viewModel.email.isEmpty ? .secondary : .primary)
                                        .frame(maxWidth: .infinity)
                                    AppImages.iconPhoneFill
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(viewModel.phone.isEmpty ? .secondary : .primary)
                                        .frame(maxWidth: .infinity)
                                    AppImages.iconGlobe
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(viewModel.www.isEmpty ? .secondary : .primary)
                                        .frame(maxWidth: .infinity)
                                    AppImages.iconFacebook
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(viewModel.facebook.isEmpty ? .secondary : .primary)
                                        .frame(maxWidth: .infinity)
                                    AppImages.iconInstagram
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(viewModel.instagram.isEmpty ? .secondary : .primary)
                                        .frame(maxWidth: .infinity)
                                }
                                .bold()
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.vertical)
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                Section("Timetable") {
                    NavigationLink {
                        EditPlaceTimetableView(viewModel: viewModel)
                    } label: {
                        VStack(spacing: 0) {
                            Divider()
                            VStack(spacing: 10) {
                                ForEach(viewModel.timetable.sorted(by: { $0.day.rawValue < $1.day.rawValue } )) { day in
                                    HStack {
                                        Text(day.day.getString())
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text(day.opening.formatted(date: .omitted, time: .shortened))
                                        Text("—")
                                        Text(day.closing.formatted(date: .omitted, time: .shortened))
                                    }
                                    .font(.caption)
                                }
                            }
                            .padding(.vertical)
                            .padding(.trailing)
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                Section("Required information") {
                    NavigationLink {
                        EmptyView()
                    } label: {
                        VStack(spacing: 0) {
                            Divider()
                            VStack(alignment: .leading) {
                                Text(viewModel.address)
                            }
                            .padding(.vertical)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                if viewModel.user.status == .admin || viewModel.user.status == .moderator {
                    Color.clear
                        .frame(height: 30)
                        .listRowSeparator(.hidden)
                    Section("Admin Panel") {
                        NavigationLink {
                            EditPlaceAdminView(viewModel: viewModel)
                        } label: {
                            VStack(spacing: 0) {
                                Divider()
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Circle()
                                            .foregroundStyle(viewModel.isActive ? .green : .red)
                                            .frame(width: 8)
                                        Text(viewModel.isActive ? "active" : "not active")
                                    }
                                    HStack {
                                        Circle()
                                            .foregroundStyle(viewModel.isChecked ? .green : .red)
                                            .frame(width: 8)
                                        Text(viewModel.isChecked ? "checked" : "not checked")
                                    }
                                }
                                .padding(.vertical)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                Text(viewModel.adminNotes)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                }
                
                Button("Delete Place") {
                    viewModel.showDeleteSheet.toggle()
                }
                .buttonStyle(.bordered)
                .padding()
                .alert("Delete Place", isPresented: $viewModel.showDeleteSheet) {
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
                    Text("Are you shure you want to delete this Place?")
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
            
            
        }
        .listRowSeparator(.hidden)
        .listSectionSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
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

//#Preview {
//    let appSettingsManager = AppSettingsManager()
//    let errorManager = ErrorManager()
//    let networkMonitorManager: NetworkMonitorManagerProtocol = NetworkMonitorManager(errorManager: errorManager)
//    let editPlaceNetworkManager: EditPlaceNetworkManagerProtocol = EditPlaceNetworkManager(networkMonitorManager: networkMonitorManager)
//    let user = AppUser(decodedUser: DecodedAppUser(id: 0, name: "Dima", email: "test@test.ru", status: .admin, sessionKey: "fddddddd", bio: "dddd", photo: nil))
//    return EditPlaceView(viewModel: EditPlaceViewModel(id: 142, place: nil, user: user, networkManager: editPlaceNetworkManager, errorManager: errorManager))
//      //  .modelContainer(for: [Place.self], inMemory: false)
//}
