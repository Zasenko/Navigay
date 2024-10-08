//
//  NewEventView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 11.11.23.
//

import SwiftUI

struct NewEventView: View {
    
    // MARK: - Private Properties
    
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @StateObject private var viewModel: NewEventViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Init
    
    init(viewModel: NewEventViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                listView
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New Event")
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
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.blue)
                    } else {
                        Button("Add") {
                            viewModel.addNewEvent()
                        }
                        .bold()
                        .disabled(viewModel.name.isEmpty)
                       // .disabled(viewModel.addressOrigin.isEmpty == true)
                        .disabled(viewModel.type == nil)
                        .disabled(viewModel.longitude == nil)
                        .disabled(viewModel.latitude == nil)
                        .disabled(viewModel.startDate == nil)
                        .disabled(viewModel.finishTime != nil && viewModel.finishDate == nil)
                    }
                }
            }
            .disabled(viewModel.isLoading)
            .navigationDestination(isPresented: $viewModel.isEventAdded) {
                EditEventCoverView(viewModel: viewModel)
            }
        }
    }
    
    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                EventRequiredFieldsView(name: $viewModel.name, type: $viewModel.type, isoCountryCode: $viewModel.isoCountryCode, countryEnglish: $viewModel.countryEnglish, regionEnglish: $viewModel.regionEnglish, cityEnglish: $viewModel.cityEnglish, addressOrigin: $viewModel.addressOrigin, latitude: $viewModel.latitude, longitude: $viewModel.longitude)
                NavigationLink {
                    EditTextFieldView(text: viewModel.location, characterLimit: 255, minHaracters: 2, title: "Event location", placeholder: "Location's title") { string in
                        viewModel.location = string
                    }
                } label: {
                    EditField(title: "Event location", text: $viewModel.location, emptyFieldColor: .secondary)
                        .padding(.horizontal)
                }
                .padding(.bottom, 40)
                
                VStack(spacing: 0) {
                    EventTimeFieldsView(startDate: $viewModel.startDate, startTime: $viewModel.startTime, finishDate: $viewModel.finishDate, finishTime: $viewModel.finishTime)
                    if viewModel.startDate != nil {
                        NavigationLink {
                            AddDatesView(eventDate: viewModel.startDate ?? Date(), eventsDates: viewModel.cloneDates.compactMap( { $0.startDate })) { dates in
                                viewModel.cloneDates(newDates: dates)
                            }
                        } label: {
                            Text("+ Add another dates")
                        }
                    }
                    if !viewModel.cloneDates.isEmpty {
                        VStack(spacing: 0) {
                            Text("Upcomming dates:")
                                .padding()
                            ForEach(viewModel.cloneDates) { repeatDate in
                                Divider()
                                NavigationLink {
                                    RepitEventEditView(eventTime: repeatDate) { newTime in
                                        if let index = viewModel.cloneDates.firstIndex(where: { $0.id == newTime.id }) {
                                            viewModel.cloneDates[index] = newTime
                                        }
                                    } onDelete: { deleteTime in
                                        if let index = viewModel.cloneDates.firstIndex(where: { $0.id == deleteTime.id }) {
                                            viewModel.cloneDates.remove(at: index)
                                        }
                                    }
                                } label: {
                                    VStack {
                                        HStack {
                                            VStack {
                                                if let startDate = repeatDate.startDate {
                                                    if let finishDate = repeatDate.finishDate {
                                                        if finishDate.isSameDayWithOtherDate(startDate) {
                                                            Text(startDate.formatted(date: .long, time: .omitted))
                                                                .font(.footnote)
                                                                .tint(.primary)
                                                            HStack {
                                                                if let startTime = repeatDate.startTime {
                                                                    HStack(spacing: 5) {
                                                                        AppImages.iconClock
                                                                        Text(startTime.formatted(date: .omitted, time: .shortened))
                                                                    }
                                                                }
                                                                if let finishTime = repeatDate.finishTime {
                                                                    Text("—")
                                                                        .frame(width: 20, alignment: .center)
                                                                    HStack(spacing: 5) {
                                                                        AppImages.iconClock
                                                                        Text(finishTime.formatted(date: .omitted, time: .shortened))
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            HStack(alignment: .top) {
                                                                VStack(spacing: 5) {
                                                                    Text(startDate.formatted(date: .long, time: .omitted))
                                                                        .font(.footnote)
                                                                        .tint(.primary)
                                                                    if let startTime = repeatDate.startTime {
                                                                        HStack(spacing: 5) {
                                                                            AppImages.iconClock
                                                                            Text(startTime.formatted(date: .omitted, time: .shortened))
                                                                        }
                                                                    }
                                                                }
                                                                Text("—")
                                                                    .frame(width: 20, alignment: .center)
                                                                VStack(spacing: 5) {
                                                                    Text(finishDate.formatted(date: .long, time: .omitted))
                                                                        .font(.footnote)
                                                                        .tint(.primary)
                                                                    if let finishTime = repeatDate.finishTime {
                                                                        HStack(spacing: 5) {
                                                                            AppImages.iconClock
                                                                            Text(finishTime.formatted(date: .omitted, time: .shortened))
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        Text(startDate.formatted(date: .long, time: .omitted))
                                                            .font(.footnote)
                                                            .tint(.primary)
                                                        if let startTime = repeatDate.startTime {
                                                            HStack(spacing: 5) {
                                                                AppImages.iconClock
                                                                Text(startTime.formatted(date: .omitted, time: .shortened))
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            .font(.caption)
                                            .tint(.secondary)
                                            .frame(maxWidth: .infinity)
                                            AppImages.iconRight
                                                .foregroundStyle(.quaternary)
                                        }
                                        .padding()
                                    }
                                }
                            }
                        }
                        .background(AppColors.lightGray6)
                        .cornerRadius(10)
                        .padding()
                    }
                }
                .padding(.bottom, 40)

                NavigationLink {
                    EditTextEditorView(title: "About", text: viewModel.about, characterLimit: 3000, onSave: { string in
                        viewModel.about = string
                    })
                } label: {
                    EditField(title: "About", text: $viewModel.about, emptyFieldColor: .secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
                
                EventFeeFieldsView(isFree: $viewModel.isFree, fee: $viewModel.fee, tickets: $viewModel.tickets)
                    .padding(.bottom, 40)
                EventAdditionalFieldsView(tags: $viewModel.tags, isoCountryCode: $viewModel.isoCountryCode, phone: $viewModel.phone, email: $viewModel.email, www: $viewModel.www, facebook: $viewModel.facebook, instagram: $viewModel.instagram)
                    .padding(.bottom, 40)
                if viewModel.user.status == .admin {
                    ActivationFieldsView(isActive: $viewModel.isActive, isChecked: $viewModel.isChecked)
                        .padding(.bottom)
                    NavigationLink {
                        EditTextEditorView(title: "Notes", text: viewModel.adminNotes, characterLimit: 3000, onSave: { string in
                            viewModel.adminNotes = string
                        })
                    } label: {
                        EditField(title: "Notes", text: $viewModel.adminNotes, emptyFieldColor: .secondary)
                            .padding(.vertical)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

//#Preview {
//    let decodetUser = DecodedAppUser(id: 0, name: "Test", email: "test@test.com", status: .admin, sessionKey: "000", bio: nil, photo: nil)
//    let user = AppUser(decodedUser: decodetUser)
//    let errorManager = ErrorManager()
//    let appSettingsManager = AppSettingsManager()
//    let networkMonitorManager = NetworkMonitorManager(errorManager: errorManager)
//    let networkManager = EditEventNetworkManager(networkMonitorManager: networkMonitorManager)
//    let auth = AuthenticationManager(keychainManager: KeychainManager(), networkMonitorManager: networkMonitorManager, networkManager: AuthNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager), errorManager: errorManager)
//    return NewEventView(viewModel: NewEventViewModel(user: user, place: nil, copy: nil, networkManager: networkManager, errorManager: errorManager))
//        .environmentObject(auth)
//}
