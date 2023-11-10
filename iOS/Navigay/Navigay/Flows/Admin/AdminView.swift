//
//  AdminView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 19.10.23.
//

import SwiftUI

final class AdminViewModel: ObservableObject {
    
    let user: AppUser
    let errorManager: ErrorManagerProtocol
    
    // MARK: - Inits
    
    init(user: AppUser, errorManager: ErrorManagerProtocol) {
        self.user = user
        self.errorManager = errorManager
    }
}

struct AdminView: View {

    @StateObject var viewModel: AdminViewModel
    
    init(viewModel: AdminViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Add new place") {
                        AddNewPlaceView(viewModel: AddNewPlaceViewModel(user: viewModel.user, networkManager: PlaceNetworkManager(), errorManager: viewModel.errorManager))
                    }
                    NavigationLink("Add new event") {
                        Color.red
                    }
                }
            }
            .navigationTitle("Admin panel")
        }
    }
}

//#Preview {
//    AdminView()
//}
