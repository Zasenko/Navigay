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
    
    @Published var countries: [AdminCountry] = []
    
    // MARK: - Inits
    
    init(errorManager: ErrorManagerProtocol, networkManager: AdminNetworkManagerProtocol) {
        self.errorManager = errorManager
        self.networkManager = networkManager
    }
}

extension AdminRegionsViewModel {
    
    func fetchCountries() {
        Task {
            
            guard let decodedCountries = await networkManager.getCountries() else {
                return
            }
            await MainActor.run {
                countries = decodedCountries
            }
        }
    }
}


struct AdminRegionsView: View {
    
    @StateObject private var viewModel: AdminRegionsViewModel
//
//    init(viewModel: AdminCountriesViewModel) {
//        _viewModel = StateObject(wrappedValue: viewModel)
//    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.countries) { country in
                    NavigationLink {
                        EditCountryView(viewModel: EditCountryViewModel(country: country, errorManager: viewModel.errorManager, networkManager: viewModel.networkManager))
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("id: \(country.id), code: \(country.isoCountryCode)")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                Text(country.nameEn ?? country.nameOrigin ?? "")
                                    .font(.headline)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Circle()
                                        .foregroundStyle(country.isActive ? .green : .red)
                                        .frame(width: 8)
                                    Text("is active")
                                }
                                HStack {
                                    Circle()
                                        .foregroundStyle(country.isChecked ? .green : .red)
                                        .frame(width: 8)
                                    Text("is checked")
                                }
                            }
                        }
                    }
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
                viewModel.fetchCountries()
            }
        }
    }
}

//#Preview {
//    AdminRegionsView()
//}
