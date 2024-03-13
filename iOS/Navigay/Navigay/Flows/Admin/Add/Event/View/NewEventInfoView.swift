//
//  NewEventInfoView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.11.23.
//

import SwiftUI

struct NewEventInfoView: View {
    
    //MARK: - Properties
    
    @ObservedObject var viewModel: NewEventViewModel
    @ObservedObject var authenticationManager: AuthenticationManager
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    EventRequiredFieldsView(name: $viewModel.name, type: $viewModel.type, isoCountryCode: $viewModel.isoCountryCode, countryOrigin: $viewModel.countryOrigin, countryEnglish: $viewModel.countryEnglish, regionOrigin: $viewModel.regionOrigin, regionEnglish: $viewModel.regionEnglish, cityOrigin: $viewModel.cityOrigin, cityEnglish: $viewModel.cityEnglish, addressOrigin: $viewModel.addressOrigin, latitude: $viewModel.latitude, longitude: $viewModel.longitude)
                        .padding(.bottom, 40)
                    NavigationLink {
                        EditTextFieldView(text: viewModel.location, characterLimit: 255, minHaracters: 2, title: "Event location", placeholder: "Location's title") { string in
                            viewModel.location = string
                        }
                    } label: {
                        EditField(title: "Event location", text: $viewModel.location, emptyFieldColor: .secondary)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 40)
                    EventTimeFieldsView(startDate: $viewModel.startDate, startTime: $viewModel.startTime, finishDate: $viewModel.finishDate, finishTime: $viewModel.finishTime)
                        .padding(.bottom, 40)
                    
                    
                    NavigationLink {
                        EditDateView(date: nil, pickerStartDate: nil, editType: .start) { date in
                            viewModel.cloneDate(newDate: date)
                        } onDelete: {
                            
                        }
                    } label: {
                        Text("+ Clone Event")

                    }
                    
                    
                    if !viewModel.repeatDates.isEmpty {
                        ForEach(viewModel.repeatDates) { repeatDate in
                            NavigationLink {
                                RepitEventEditView(eventTime: repeatDate) { newTime in
                                    if let index = viewModel.repeatDates.firstIndex(where: { $0.id == newTime.id }) {
                                        viewModel.repeatDates[index] = newTime
                                    }
                                } onDelete: { deleteTime in
                                    if let index = viewModel.repeatDates.firstIndex(where: { $0.id == deleteTime.id }) {
                                        viewModel.repeatDates.remove(at: index)
                                    }
                                }

                            } label: {
                                VStack {
                                    if let startDate = repeatDate.startDate {
                                        Text(startDate.formatted(date: .long, time: .omitted))
                                            .multilineTextAlignment(.leading)
                                            .tint(.primary)
                                    }
                                    
                                    if let startTime = repeatDate.startTime  {
                                        Text(startTime.formatted(date: .omitted, time: .shortened))
                                            .multilineTextAlignment(.leading)
                                            .tint(.primary)
                                    }
                                    
                                    if let finishDate = repeatDate.finishDate {
                                        Text(finishDate.formatted(date: .long, time: .omitted))
                                            .multilineTextAlignment(.leading)
                                            .tint(.primary)
                                    }
                                    
                                    if let finishTime = repeatDate.finishTime  {
                                        Text(finishTime.formatted(date: .omitted, time: .shortened))
                                            .multilineTextAlignment(.leading)
                                            .tint(.primary)
                                    }
                                }
                                .background(.red)
                                .padding()
                            }
                        }
                    }
                    
                    NavigationLink {
                        EditTextEditorView(title: "About", text: viewModel.about, characterLimit: 3000, onSave: { string in
                            viewModel.about = string
                        })
                    } label: {
                        EditField(title: "About", text: $viewModel.about, emptyFieldColor: .secondary)
                    }
                    .padding(.horizontal)
                    
                    EventFeeFieldsView(isFree: $viewModel.isFree, fee: $viewModel.fee, tickets: $viewModel.tickets)
                        .padding(.bottom, 40)
                    EventAdditionalFieldsView(tags: $viewModel.tags, isoCountryCode: $viewModel.isoCountryCode, phone: $viewModel.phone, email: $viewModel.email, www: $viewModel.www, facebook: $viewModel.facebook, instagram: $viewModel.instagram)
                        .padding(.bottom, 40)
                    if let user = authenticationManager.appUser, user.status == .admin {
                        ActivationFieldsView(isActive: $viewModel.isActive, isChecked: $viewModel.isChecked)
                            .padding(.bottom, 40)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

//#Preview {
//    let decodetUser = DecodedAppUser(id: 0, name: "Test", email: "test@test.com", status: .user, bio: nil, photo: nil, instagram: nil, likedPlacesId: nil)
//    let user = AppUser(decodedUser: decodetUser)
//    let errorManager = ErrorManager()
//    let appSettingsManager = AppSettingsManager()
//    let networkManager = EventNetworkManager(appSettingsManager: appSettingsManager)
//    return NewEventInfoView(viewModel: NewEventViewModel(user: user, place: nil, networkManager: networkManager, errorManager: errorManager))
//}
