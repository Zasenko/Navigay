//
//  OrganizerRequiredFieldsView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 23.09.24.
//

import SwiftUI
import MapKit

struct OrganizerRequiredFieldsView: View {
    
    //MARK: - Properties
    
    @ObservedObject var viewModel: AddOrganizerViewModel
    
    //MARK: - Private Properties
    
    @State private var position: MapCameraPosition = .automatic
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                titleField
                locationField
            }
            .background(AppColors.lightGray6)
            .cornerRadius(10)
            .padding(.bottom, 40)
            .padding(.horizontal)
        }
    }
    
    //MARK: - Views
    
    private var titleField: some View {
        NavigationLink {
            EditTextFieldView(text: viewModel.name, characterLimit: 255, minHaracters: 2, title: "Title", placeholder: "Title") { string in
                viewModel.name = string
            }
        } label: {
            EditField(title: "Title", text: $viewModel.name, emptyFieldColor: .red)
        }
    }
    
    private var locationField: some View {
        HStack {
            Text("Location")
                .font(.callout)
                .foregroundStyle(viewModel.countryEnglish.isEmpty || viewModel.cityEnglish.isEmpty ? .red : .green)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 5) {
                Text(viewModel.countryEnglish)
                Text("•")
                Text(viewModel.cityEnglish)
            }
            .font(.callout)
            .frame(maxWidth: .infinity, alignment: .leading)
            AppImages.iconRight
                .foregroundStyle(.quaternary)
        }
        .padding()
     //   .background(AppColors.lightGray6, in: RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            viewModel.showMap.toggle()
        }
        .fullScreenCover(isPresented: $viewModel.showMap) {
            AddLocationView2 { location in
                viewModel.isoCountryCode = location.isoCountryCode
                viewModel.countryEnglish = location.countryEnglish
                viewModel.regionEnglish = location.regionEnglish
                viewModel.cityEnglish = location.cityEnglish
                viewModel.showMap.toggle()
            }
        }
    }
}

#Preview {
    let errorManager: ErrorManagerProtocol = ErrorManager()
    let keychainManager: KeychainManagerProtocol = KeychainManager()
    let appSettingsManager: AppSettingsManagerProtocol = AppSettingsManager()
    let networkMonitorManager: NetworkMonitorManagerProtocol = NetworkMonitorManager(errorManager: errorManager)
    let networkManager = NetworkManager(session: URLSession.shared, networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager, keychainManager: keychainManager)
   let authNetworkManager = AuthNetworkManager(networkManager: networkManager)
    var authenticationManager = AuthenticationManager(keychainManager: keychainManager, networkMonitorManager: networkMonitorManager, networkManager: networkManager, authNetworkManager: authNetworkManager, errorManager: errorManager)
    let editNetworkManager = EditOrganizerNetworkManager(networkManager: networkManager)
    AddOrganizerView(viewModel: AddOrganizerViewModel(networkManager: editNetworkManager, errorManager: errorManager))
        .environmentObject(authenticationManager)
}
