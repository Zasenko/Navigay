//
//  EditEventView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 18.01.24.
//

import SwiftUI

struct EditEventView: View {
    
    // MARK: - Private Properties
    
    @StateObject private var viewModel: EditEventViewModel
    @Environment(\.dismiss) private var dismiss
     
    // MARK: - Inits
    
    init(viewModel: EditEventViewModel) {
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
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.blue)
                            }
                            VStack(spacing: 0) {
                                Text("ID: \(viewModel.id)")
                                    .font(.caption).bold()
                                    .foregroundStyle(.secondary)
                                Text("Edit Event")
                                    .font(.headline).bold()
                            }
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
                .onAppear() {
                    viewModel.fetchEvent()
                }
        }
    }
    
    // MARK: - Views
    
    private var listView: some View {
        GeometryReader{ geometry in
            List {
                posterView
                titleTypeView
                informationView
                additionalInformationView
                timeView
                feeView
                requiredInformationView
                if viewModel.showAdminFields {
                    adminView
                }
                deleteButton
                Color.clear
                    .frame(height: 50)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var posterView: some View {
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
                viewModel.updatePoster(uiImage: uiImage)
            } onDelete: {
                viewModel.deletePoster()
            }
            Spacer(minLength: 40)
        }
        .listRowSeparator(.hidden)
        .listSectionSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    private var titleTypeView: some View {
        Section {
            NavigationLink {
                EditEventTitleView(viewModel: viewModel)
            } label: {
                headerText(text: "Title & Type")
            }
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                VStack(alignment: .leading) {
                    Text(viewModel.name).bold()
                    HStack {
                        Text(viewModel.type.getName())
                    }
                }
                .padding(.vertical)
            }
            Spacer(minLength: 40)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    private var informationView: some View {
        Section {
            NavigationLink {
                EditEventAboutView(viewModel: viewModel)
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
    
    private var timeView: some View {
        Section {
            NavigationLink {
                EditEventTimeView(viewModel: viewModel)
            } label: {
                headerText(text: "Time of the Event")
            }
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                VStack(alignment: .leading) {
                    Text("Start date: ").bold()
                    + Text(viewModel.startDate.formatted(date: .long, time: .omitted))
                    
                    Text("Start time: ").bold()
                    + Text(viewModel.startTime?.formatted(date: .omitted, time: .shortened) ?? "")
                    
                    Text("Finish date: ").bold()
                     + Text(viewModel.finishDate?.formatted(date: .long, time: .omitted) ?? "")
                    
                    Text("Finish time: ").bold()
                     + Text(viewModel.finishTime?.formatted(date: .omitted, time: .shortened) ?? "")
                }
                .font(.callout)
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
                EmptyView()
                EditEventAdditionalInfoView(viewModel: viewModel)
            } label: {
                headerText(text: "Additional Information")
            }
            VStack(spacing: 0) {
                Divider()
                VStack(spacing: 20) {
                    if viewModel.tags.isEmpty {
                        Text("Tags are not added.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    } else {
                        TagsView(tags: viewModel.tags)
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
    
    private var feeView: some View {
        Section {
            NavigationLink {
                EditEventFeeView(viewModel: viewModel)
            } label: {
                headerText(text: "Fee")
            }
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                if viewModel.isFree {
                    Text("free event")
                } else {
                    VStack(alignment: .leading) {
                        Text("Fee: ").bold()
                        + Text(viewModel.fee)
                        Text("Tickets: ").bold()
                        + Text(viewModel.tickets)
                    }
                    .font(.callout)
                    .padding(.vertical)
                }
               
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
            } label: {
                headerText(text: "Required information")
            }
            VStack(spacing: 0) {
                Divider()
                Text(viewModel.address)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer(minLength: 40)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    private var adminView: some View {
        Section {
            NavigationLink {
                EditEventAdminView(viewModel: viewModel)
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
    
    private var deleteButton: some View {
        Button("Delete Event") {
            viewModel.showDeleteSheet.toggle()
        }
        .buttonStyle(.bordered)
        .padding()
        .alert("Delete Event", isPresented: $viewModel.showDeleteSheet) {
            Button("Delete", role: .destructive) {
                Task {
                    if await viewModel.deleteEvent() {
                        await MainActor.run {
                            dismiss()
                        }
                    }
                }
                
            }
            Button("Cancel", role: .cancel) {
                viewModel.showDeleteSheet.toggle()
            }
        } message: {
            Text("Are you shure you want to delete this Event?")
        }
    }
    
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
}


#Preview {
    let appSettingsManager = AppSettingsManager()
    let errorManager = ErrorManager()
    let networkMonitorManager: NetworkMonitorManagerProtocol = NetworkMonitorManager(errorManager: errorManager)
    let networkManager: EditEventNetworkManagerProtocol = EditEventNetworkManager(networkMonitorManager: networkMonitorManager)
    let user = AppUser(decodedUser: DecodedAppUser(id: 0, name: "Dima", email: "test@test.ru", status: .admin, sessionKey: "fddddddd", bio: "dddd", photo: nil))
    
    return EditEventView(viewModel: EditEventViewModel(eventID: 1, user: user, event: nil, networkManager: networkManager, errorManager: errorManager))

}
