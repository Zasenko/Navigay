//
//  NewPlaceInfoView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.11.23.
//

import SwiftUI

struct NewPlaceInfoView: View {
    
    //MARK: - Properties
    
    @ObservedObject var viewModel: AddNewPlaceViewModel
            
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    Text("Add required information:")
                        .foregroundStyle(.secondary)
                        .padding()
                    PlaceRequiredFieldsView(viewModel: viewModel)
                    Text("Add additional information:")
                        .foregroundStyle(.secondary)
                        .padding()
                        .padding(.top)
                    PlaceAdditionalFieldsView(isoCountryCode: $viewModel.isoCountryCode, email: $viewModel.email, phone: $viewModel.phone, www: $viewModel.www, facebook: $viewModel.facebook, instagram: $viewModel.instagram, about: $viewModel.about, timetable: $viewModel.timetable, otherInfo: $viewModel.otherInfo, tags: $viewModel.tags)
                    
                    if viewModel.user.status == .admin || viewModel.user.status == .moderator {
                        ActivationFieldsView(isActive: $viewModel.isActive, isChecked: $viewModel.isChecked)
                            .padding(.bottom, 40)
                    } else {
                        EditToggleField(toggle: $viewModel.isOwned, text: "Are you an owner of this place?")
                            .padding(.bottom, 40)
                    }
                }
            }
        }
    }
}

//#Preview {
//    let decodetUser = DecodedAppUser(id: 0, name: "Test", email: "test@test.com", status: .admin, bio: nil, photo: nil, instagram: nil, likedPlacesId: nil)
//    let user = AppUser(decodedUser: decodetUser)
//    return NewPlaceInfoView(viewModel: AddNewPlaceViewModel(user: user, networkManager: PlaceNetworkManager(errorManager: ErrorManager())))
//}
