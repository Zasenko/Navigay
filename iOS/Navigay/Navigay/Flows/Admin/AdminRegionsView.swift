//
//  AdminRegionsView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 21.02.24.
//

import SwiftUI

final class AdminRegionsViewModel: ObservableObject {
    
    let errorManager: ErrorManagerProtocol
    let networkManager: AdminNetworkManagerProtocol
    
    @Published var regions: [AdminRegion] = []
    
    let country: AdminCountry
    let user: AppUser
    
    // MARK: - Inits
    
    init(country: AdminCountry, user: AppUser, errorManager: ErrorManagerProtocol, networkManager: AdminNetworkManagerProtocol) {
        self.errorManager = errorManager
        self.networkManager = networkManager
        self.country = country
        self.user = user
    }
}

extension AdminRegionsViewModel {
    
    func fetchRegions() {
        Task {
            do {
                let decodedRegions = try await networkManager.getRegions(countryID: country.id, user: user)
                await MainActor.run {
                    regions = decodedRegions
                }
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: errorManager.errorMessage, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: errorManager.errorMessage, img: nil, color: nil))
            }
        }
    }
}


struct AdminRegionsView: View {
    
    @StateObject private var viewModel: AdminRegionsViewModel
    @EnvironmentObject private var authManager: AuthenticationManager
    
    init(viewModel: AdminRegionsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.regions) { region in
                    Section {
                        NavigationLink {
                            EditRegionView(viewModel: EditRegionViewModel(id: region.id, countryId: viewModel.country.id, region: nil, user: viewModel.user, errorManager: viewModel.errorManager, networkManager: EditRegionNetworkManager(networkMonitorManager: authManager.networkMonitorManager)))
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("id: \(region.id)")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                    Text(region.nameEn ?? "")
                                        .font(.headline)
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Circle()
                                            .foregroundStyle(region.isActive ? .green : .red)
                                            .frame(width: 8)
                                        Text("is active")
                                    }
                                    HStack {
                                        Circle()
                                            .foregroundStyle(region.isChecked ? .green : .red)
                                            .frame(width: 8)
                                        Text("is checked")
                                    }
                                }
                            }
                        }
                    } footer: {
                        NavigationLink {
                            AdminCitiesView(viewModel: AdminCitiesViewModel(region: region, user: viewModel.user, errorManager: viewModel.errorManager, networkManager: viewModel.networkManager))
                        } label: {
                            Text("Show cities")
                                .padding()
                        }
                    }

                }
            }
            //.navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text(viewModel.country.nameEn ?? "ID: \(viewModel.country.id)")
                            .font(.caption).bold()
                            .foregroundStyle(.secondary)
                        Text("Regions")
                            .font(.headline).bold()
                    }
                }
            }
            .onAppear() {
                viewModel.fetchRegions()
            }
        }
    }
}

//#Preview {
//    AdminRegionsView()
//}
