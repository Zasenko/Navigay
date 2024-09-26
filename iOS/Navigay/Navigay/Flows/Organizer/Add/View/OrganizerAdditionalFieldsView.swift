//
//  OrganizerAdditionalFieldsView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 23.09.24.
//

import SwiftUI

struct OrganizerAdditionalFieldsView: View {
    
    //MARK: - Properties
    
    @ObservedObject var viewModel: AddOrganizerViewModel

    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            LazyVStack(spacing: 0) {
                VStack(spacing: 0) {
                    NavigationLink {
                        EditTextEditorView(title: "Information", text: viewModel.about, characterLimit: 3000, onSave: { string in
                            viewModel.about = string
                        })
                    } label: {
                        EditField(title: "Information", text: $viewModel.about, emptyFieldColor: .secondary)
                    }
                    
                    NavigationLink {
                        EditTextEditorView(title: "Other Informations", text: viewModel.otherInfo, characterLimit: 255) { string in
                            viewModel.otherInfo = string
                        }
                    } label: {
                        EditField(title: "Other Informations", text: $viewModel.otherInfo, emptyFieldColor: .secondary)
                    }
                }
                .background(AppColors.lightGray6)
                .cornerRadius(10)
                .padding(.bottom, 40)
                
                VStack(spacing: 0) {
                    NavigationLink {
                        EditEmailView(email: viewModel.email) { string in
                            viewModel.email = string.lowercased()
                        }
                    } label: {
                        EditField(title: "Email", text: $viewModel.email, emptyFieldColor: .secondary)
                    }
                    Divider()
                        .padding(.horizontal)
                    NavigationLink {
                        EditPhoneView(isoCountryCode: viewModel.isoCountryCode) { string in
                            viewModel.phone = string
                        }
                    } label: {
                        EditField(title: "Phone", text: $viewModel.phone, emptyFieldColor: .secondary)
                    }
                    Divider()
                        .padding(.horizontal)
                    NavigationLink {
                        EditTextFieldView(text: viewModel.www, characterLimit: 255, minHaracters: 0, title: "Web page", placeholder: "www") { string in
                            viewModel.www = string
                        }
                    } label: {
                        EditField(title: "www", text: $viewModel.www, emptyFieldColor: .secondary)
                    }
                    Divider()
                        .padding(.horizontal)
                    NavigationLink {
                        EditTextFieldView(text: viewModel.facebook, characterLimit: 255, minHaracters: 0, title: "Facebook", placeholder: "Facebook") { string in
                            viewModel.facebook = string
                        }
                    } label: {
                        EditField(title: "Facebook", text: $viewModel.facebook, emptyFieldColor: .secondary)
                    }
                    Divider()
                        .padding(.horizontal)
                    NavigationLink {
                        EditTextFieldView(text: viewModel.instagram, characterLimit: 255, minHaracters: 0, title: "Instagram", placeholder: "Instagram") { string in
                            viewModel.instagram = string
                        }
                    } label: {
                        EditField(title: "Instagram", text: $viewModel.instagram, emptyFieldColor: .secondary)
                    }
                }
                .background(AppColors.lightGray6)
                .cornerRadius(10)
                .padding(.bottom, 40)
            }
            .padding(.horizontal)
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
