//
//  AddOrganizerView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 23.09.24.
//

import SwiftUI

struct AddOrganizerView: View {
    
    // MARK: - Private Properties
    
    @StateObject private var viewModel: AddOrganizerViewModel
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Init
    
    init(viewModel: AddOrganizerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                listView
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New Organizer")
                        .font(.headline.bold())
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.resetItems()
                        dismiss()
                    } label: {
                        AppImages.iconLeft
                            .bold()
                            .frame(width: 30, height: 30, alignment: .leading)
                    }
                    .tint(.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.blue)
                    } else {
                        Button("Add") {
                            guard let user = authenticationManager.appUser else { return }
                            viewModel.add(from: user)
                        }
                        .bold()
                        .disabled(viewModel.name.isEmpty)
                    }
                }
            }
            .disabled(viewModel.isLoading)
            .navigationDestination(item: $viewModel.id) { id in
                if let user = authenticationManager.appUser {
                    EditOrganizerView(viewModel: EditOrganizerViewModel(id: id, organizer: nil, user: user, networkManager: viewModel.networkManager, errorManager: viewModel.errorManager))
                }
            }
        }
    }
    
    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                Text("Add required information:")
                    .foregroundStyle(.secondary)
                    .padding()
                OrganizerRequiredFieldsView(viewModel: viewModel)
                Text("Add additional information:")
                    .foregroundStyle(.secondary)
                    .padding()
                    .padding(.top)
                OrganizerAdditionalFieldsView(viewModel: viewModel)
                
                if authenticationManager.appUser?.status == .admin || authenticationManager.appUser?.status == .moderator {
                    VStack {
                        ActivationFieldsView(isActive: $viewModel.isActive, isChecked: $viewModel.isChecked)
                        NavigationLink {
                            EditTextEditorView(title: "Notes", text: viewModel.adminNotes, characterLimit: 3000, onSave: { string in
                                viewModel.adminNotes = string
                            })
                        } label: {
                            EditField(title: "Notes", text: $viewModel.adminNotes, emptyFieldColor: .secondary)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 40)
                }
            }
        }
        .scrollIndicators(.hidden)
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
    return AddOrganizerView(viewModel: AddOrganizerViewModel(networkManager: editNetworkManager, errorManager: errorManager))
        .environmentObject(authenticationManager)
}
