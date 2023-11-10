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
    
    //MARK: - Private Properties
        
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
                    PlaceAdditionalFieldsView(viewModel: viewModel)
                    ActivationFieldsView(isActive: $viewModel.isActive, isChecked: $viewModel.isChecked)
                        .padding(.bottom)
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
