//
//  EditEventView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 18.01.24.
//

import SwiftUI

struct EditEventView: View {
    
    //MARK: - Private Properties
    
    @StateObject private var viewModel: EditEventViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authenticationManager: AuthenticationManager
     
    //MARK: - Inits
    
    init(viewModel: EditEventViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
                VStack(spacing: 0) {
                    Divider()
                    if viewModel.eventDidLoad {
                        eventView()
                            .environmentObject(viewModel)
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
                        Text("Edit Event")
                            .font(.headline.bold())
                            
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
//                    ToolbarItem(placement: .topBarTrailing) {
//                        if viewModel.isLoading {
//                            ProgressView()
//                                .tint(.blue)
//                        } else {
//                            Button("Save") {
//                                viewModel.isLoading = true
//                                Task {
//                                    let result = await viewModel.updateInfo()
//                                    await MainActor.run {
//                                        if result {
//                                            self.viewModel.isLoading = false
//                                            self.dismiss()
//                                        } else {
//                                            self.viewModel.isLoading = false
//                                        }
//                                    }
//                                }
//                            }
//                            .bold()
//                        }
//                    }
                }
//                .disabled(viewModel.isLoadingPhoto)
//                .disabled(viewModel.isLoading)
//                .disabled(viewModel.isLoadingLibraryPhoto)
                .onAppear() {
                    guard let user = authenticationManager.appUser else { return }
                    viewModel.fetchEvent(for: user)
                }
        }
    }
    
    @ViewBuilder private func eventView() -> some View {
        List {
            Section {
                PhotoEditView(canDelete: true, canAddFromUrl: true) {
                    ZStack {
                        if let photo = viewModel.poster {
                            if let image = photo.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .opacity(viewModel.isLoadingPoster ? 0.2 : 1)
                            } else if let url = photo.url {
                                ImageLoadingView(url: url, width: .infinity, height: nil, contentMode: .fit) {
                                    AppColors.lightGray6
                                }
                                .opacity(viewModel.isLoadingPoster ? 0.2 : 1)
                            }
                        } else {
                            AppImages.iconCamera
                                .resizable()
                                .scaledToFit()
                                .opacity(viewModel.isLoadingPoster ? 0 : 1)
                                .tint(.primary)
                                .frame(width: 100)
                                .frame(width: .infinity, height: 150)
                        }
                        if viewModel.isLoadingPoster {
                            ProgressView()
                                .tint(.blue)
                        }
                    }
                } onSave: { uiImage in
                    guard let user = authenticationManager.appUser else {
                        return
                    }
                    viewModel.updatePoster(user: user, uiImage: uiImage)
                } onDelete: {
                    guard let user = authenticationManager.appUser else {
                        return
                    }
                    viewModel.deletePoster(user: user)
                }
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            Section {
                NavigationLink {
                    EditTextFieldView(text: viewModel.name, characterLimit: 255, minHaracters: 3, title: "Event's Title", placeholder: "Title") { string in
                        viewModel.updateAbout()
                    }
                } label: {
                    VStack(alignment: .leading) {
                        Text(viewModel.name)
                        Text(viewModel.type.getName())
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("Information") {
                NavigationLink {
                    EditTextEditorView(title: "Edit Information", text: viewModel.about, characterLimit: 255) { string in
                        viewModel.updateAbout()
                    }
                } label: {
                    Text(viewModel.about)
                        .lineLimit(5)
                }
            }

            Section("Other Information") {
                NavigationLink {
                    EditEventAdditionalView()
                } label: {
                    VStack(spacing: 20) {
                        if viewModel.isFree != true {
                            HStack {
                                AppImages.iconWallet
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(viewModel.tickets.isEmpty ? .secondary : .primary)
                                Text(viewModel.fee)
                            }
                        } else {
                            Text("free event")
                                .foregroundStyle(.primary)
                                .padding()
                                .background(.secondary)
                                .clipShape(Capsule())
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                            ForEach(viewModel.tags, id: \.self) { tag in
                                Text(tag.getString())
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                        
                        HStack {
                            AppImages.iconEnvelope
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(viewModel.email.isEmpty ? .secondary : .primary)
                            AppImages.iconPhoneFill
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(viewModel.phone.isEmpty ? .secondary : .primary)
                            AppImages.iconGlobe
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(viewModel.www.isEmpty ? .secondary : .primary)
                            AppImages.iconFacebook
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(viewModel.facebook.isEmpty ? .secondary : .primary)
                            AppImages.iconInstagram
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(viewModel.instagram.isEmpty ? .secondary : .primary)
            
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                }
            }
            
            Section("Event time") {
                NavigationLink {
                    EmptyView()
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Start date: ")
                            .foregroundStyle(.secondary)
                        + Text(viewModel.startDate.formatted(date: .long, time: .omitted))
                        Text("Start time: ")
                            .foregroundStyle(.secondary)
                        + Text(viewModel.startTime?.formatted(date: .omitted, time: .shortened) ?? "")
                        Text("Finish date: ")
                            .foregroundStyle(.secondary)
                        + Text(viewModel.finishDate?.formatted(date: .long, time: .shortened) ?? "")
                        Text("Finish time: ")
                            .foregroundStyle(.secondary)
                        + Text(viewModel.finishTime?.formatted(date: .omitted, time: .omitted) ?? "")
                    }
                }
            }
            
            Section("Required Information") {
                NavigationLink {
                    EditEventRequiredView()
                } label: {
                    VStack(spacing: 0) {
                        Text(viewModel.address)
                        Text(viewModel.location)
                    }
                }
            }
            
            if let user = authenticationManager.appUser, user.status == .admin {
                Section {
                    NavigationLink {
                        EmptyView()
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Circle()
                                    .foregroundStyle(viewModel.isActive ? .green : .red)
                                    .frame(width: 8)
                                Text("is active")
                            }
                            HStack {
                                Circle()
                                    .foregroundStyle(viewModel.isChecked ? .green : .red)
                                    .frame(width: 8)
                                Text("is checked")
                            }
                        }
                    }
                }
            }
           
        }
        .listStyle(.insetGrouped)
    }
}

//#Preview {
//    EditEventView(viewModel: EditEventViewModel(event: Event(decodedEvent: DecodedEvent(id: 213, name: "Rugby MEETS Rubber & Sports", type: .party, startDate: "2024-03-09", startTime: "23:00:00", finishDate: "2024-03-10", finishTime: "03:00:00", address: "Hamburgerstraße, 4", latitude: 48.19611791448819, longitude: 16.357055501725107, poster: "https://www.navigay.me/images/events/AT/206/1708499193850_239.jpg", smallPoster: "https://www.navigay.me/images/events/AT/213/1709028081570_764.jpg", isFree: true, tags: [], location: "location LMC Vienna - HARD ON", lastUpdate: "2024-02-27 10:01:21", about: "🏉For one night, the HARD ON becomes a playing field! Experience the full masculinity of tough sport when the Vienna Eagles Rugby Football Club visits us at HARD ON! Come in your sharpest sports outfit and meet the hottest athletes of Vienna!\n\n 09.03.2024 23:00\n Door open until 03:00", fee: "", tickets: "", www: "www.mail.ru", facebook: "", instagram: "", phone: "+45 5698977", place: nil, owner: nil, city: nil, cityId: nil)), networkManager: AdminNetworkManager(errorManager: ErrorManager())))
//}
