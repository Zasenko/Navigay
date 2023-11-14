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
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    EventRequiredFieldsView(name: $viewModel.name, type: $viewModel.type, isoCountryCode: $viewModel.isoCountryCode, countryOrigin: $viewModel.countryOrigin, countryEnglish: $viewModel.countryEnglish, regionOrigin: $viewModel.regionOrigin, regionEnglish: $viewModel.regionEnglish, cityOrigin: $viewModel.cityOrigin, cityEnglish: $viewModel.cityEnglish, addressOrigin: $viewModel.addressOrigin, latitude: $viewModel.latitude, longitude: $viewModel.longitude)
                        .padding(.bottom, 40)
                    NavigationLink {
                        EditTextFieldView(text: viewModel.location, characterLimit: 0, minHaracters: 2, title: "Event location", placeholder: "Location title") { string in
                            viewModel.location = string
                        }
                    } label: {
                        EditField(title: "Event location", text: $viewModel.location, emptyFieldColor: .secondary)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 40)
                    EventTimeFieldsView(startDate: $viewModel.startDate, startTime: $viewModel.startTime, finishDate: $viewModel.finishDate, finishTime: $viewModel.finishTime)
                        .padding(.bottom, 40)
                    EventFeeFieldsView(isFree: $viewModel.isFree, fee: $viewModel.fee, tickets: $viewModel.tickets)
                        .padding(.bottom, 40)
                    EventAdditionalFieldsView(languages: $viewModel.languages, about: $viewModel.about, tags: $viewModel.tags, isoCountryCode: $viewModel.isoCountryCode, phone: $viewModel.phone, email: $viewModel.email, www: $viewModel.www, facebook: $viewModel.facebook, instagram: $viewModel.instagram)
                        .padding(.bottom, 40)
                    if viewModel.user.status == .admin || viewModel.user.status == .moderator {
                        ActivationFieldsView(isActive: $viewModel.isActive, isChecked: $viewModel.isChecked)
                            .padding(.bottom, 40)
                    }
                }
            }
        }
    }
}

#Preview {
    let decodetUser = DecodedAppUser(id: 0, name: "Test", email: "test@test.com", status: .user, bio: nil, photo: nil, instagram: nil, likedPlacesId: nil)
    let user = AppUser(decodedUser: decodetUser)
    let errorManager = ErrorManager()
    let appSettingsManager = AppSettingsManager()
    let networkManager = EventNetworkManager(appSettingsManager: appSettingsManager)
    return NewEventInfoView(viewModel: NewEventViewModel(user: user, place: nil, networkManager: networkManager, errorManager: errorManager))
}
