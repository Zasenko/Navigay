//
//  AdminView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 19.10.23.
//

import SwiftUI

final class AdminViewModel: ObservableObject {
    
    let user: AppUser
    
    init(user: AppUser) {
        self.user = user
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
                        AddNewPlaceView(viewModel: AddNewPlaceViewModel(user: viewModel.user, networkManager: PlaceNetworkManager()))
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
