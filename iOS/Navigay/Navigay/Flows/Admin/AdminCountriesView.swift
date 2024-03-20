//
//  AdminCountriesView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.12.23.
//

import SwiftUI

final class AdminCountriesViewModel: ObservableObject {
    
    let errorManager: ErrorManagerProtocol
    let networkManager: AdminNetworkManagerProtocol
    
    @Published var countries: [AdminCountry] = []
    
    // MARK: - Inits
    
    init(errorManager: ErrorManagerProtocol, networkManager: AdminNetworkManagerProtocol) {
        self.errorManager = errorManager
        self.networkManager = networkManager
    }
}

extension AdminCountriesViewModel {
    
    func fetchCountries(for user: AppUser) {
        Task {
            do {
                let decodedCountries = try await networkManager.getCountries(for: user)
                await MainActor.run {
                    countries = decodedCountries
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


struct AdminCountriesView: View {
    
    @StateObject private var viewModel: AdminCountriesViewModel
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    
    init(viewModel: AdminCountriesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.countries) { country in
//                    NavigationLink {
//                        EditCountryView(viewModel: EditCountryViewModel(country: country, errorManager: viewModel.errorManager, networkManager: viewModel.networkManager))
//                    } label: {
//                        HStack {
//                            VStack(alignment: .leading, spacing: 10) {
//                                Text("id: \(country.id), code: \(country.isoCountryCode)")
//                                    .font(.footnote)
//                                    .foregroundStyle(.secondary)
//                                Text(country.nameEn ?? country.nameOrigin ?? "")
//                                    .font(.headline)
//                                    .bold()
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                            }
//                            VStack(alignment: .leading, spacing: 10) {
//                                HStack {
//                                    Circle()
//                                        .foregroundStyle(country.isActive ? .green : .red)
//                                        .frame(width: 8)
//                                    Text("is active")
//                                }
//                                HStack {
//                                    Circle()
//                                        .foregroundStyle(country.isChecked ? .green : .red)
//                                        .frame(width: 8)
//                                    Text("is checked")
//                                }
//                            }
//                        }
//                    }
                }
            }
            //.navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Countries")
                        .font(.headline.bold())
                }
            }
            .onAppear() {
                guard let user = authenticationManager.appUser else { return }
                viewModel.fetchCountries(for: user)
            }
        }
    }
}
//
//#Preview {
//    AdminCountriesView()
//}
