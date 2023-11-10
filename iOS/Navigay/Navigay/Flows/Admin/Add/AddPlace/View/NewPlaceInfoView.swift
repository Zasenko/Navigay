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
                    activationField
                    checkField
                    Button("Add new place") {
                        viewModel.addNewPlace()
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.name.isEmpty)
                    .disabled(viewModel.addressOrigin.isEmpty == true)
                    .disabled(viewModel.type == nil)
                    .disabled(viewModel.longitude == nil)
                    .disabled(viewModel.latitude == nil)
                }
            }
        }
    }
    
    private var activationField: some View {
        HStack {
            Text("Place is Active")
                .font(.callout)
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("", isOn: $viewModel.isActive)
        }
        .padding()
    }
    private var checkField: some View {
        HStack {
            Text("Place is checked")
                .font(.callout)
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("", isOn: $viewModel.isChecked)
        }
        .padding()
    }
}

//#Preview {
//    let decodetUser = DecodedAppUser(id: 0, name: "Test", email: "test@test.com", status: .admin, bio: nil, photo: nil, instagram: nil, likedPlacesId: nil)
//    let user = AppUser(decodedUser: decodetUser)
//    return NewPlaceInfoView(viewModel: AddNewPlaceViewModel(user: user, networkManager: PlaceNetworkManager(errorManager: ErrorManager())))
//}
