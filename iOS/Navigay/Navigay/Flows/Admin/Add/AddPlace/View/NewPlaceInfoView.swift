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
                    NewPlaceRequiredFieldsView(viewModel: viewModel)
                    Text("Add additional information:")
                        .foregroundStyle(.secondary)
                        .padding()
                        .padding(.top)
                    NewPlaceAdditionalFieldsView(viewModel: viewModel)
                    
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
}

#Preview {
    NewPlaceInfoView(viewModel: AddNewPlaceViewModel(networkManager: AddNetworkManager()))
}
