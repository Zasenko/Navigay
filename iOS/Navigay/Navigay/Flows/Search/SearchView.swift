//
//  SearchView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    
    @State private var viewModel: SearchViewModel
    
    init(modelContext: ModelContext, catalogNetworkManager: CatalogNetworkManagerProtocol, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
        
        _viewModel = State(initialValue: SearchViewModel(modelContext: modelContext, catalogNetworkManager: catalogNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager))
        
        viewModel.getCountriesFromDB()
        viewModel.fetch()
    }
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView()
                .tint(.blue)
                .frame(maxHeight: .infinity)
        } else {
            
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                ListView
            }
              //  .searchable(text: $searchText, placement: .toolbar, prompt: nil)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Catalog")
                            .font(.title2.bold())
                    }
                    ToolbarItem(placement: .principal) {
                        SearchView
                    }
                }
                .toolbarBackground(AppColors.background)
                //.searchable(text: $searchText)
//                .onAppear() {
//                    fetch()
//                }
        }
    }
    }
    
    var SearchView: some View {
     //   HStack {
        TextField("", text: $viewModel.searchText) {
                  //  authenticationManager.checkEmail(email: viewModel.email)
                }
                .textInputAutocapitalization(.never)
                .lineLimit(1)
                //.focused($focusedField, equals: .email)
            
//            AppImages.iconEnvelope
//                .font(.callout)
//                .foregroundColor(.secondary)
//                .bold()
      //  }
      //  .padding()
       // .padding(.horizontal, 10)
        .background(AppColors.lightGray6)
        .cornerRadius(16)
       // .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
//        .onTapGesture {
//            focusedField = .email
//        }
        .padding(.leading)
        .frame(maxWidth: .infinity)
    }
    
    private var ListView: some View {
        List(viewModel.countries) { country in
            NavigationLink {
                CountryView(modelContext: viewModel.modelContext, country: country, catalogNetworkManager: viewModel.catalogNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager)
            } label: {
                HStack(alignment: .center, spacing: 20) {
                    Text(country.flagEmoji)
                        .font(.title)
                        .padding()
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 4) {
                        Text(country.name)
                            .font(.title2)
                        //                                    HStack {
                        //                                        Text("25 мест")
                        //                                        Text("| ")
                        //                                        Text("17 мероприятий")
                        //                                    }
                        //                                    .foregroundStyle(.secondary)
                        //                                    .font(.caption2)
                    }
                    
                }
            }
            .listRowBackground(AppColors.background)
            .listSectionSeparator(.hidden)
          //  .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
       // .scrollContentBackground(.hidden)
    }
}

//#Preview {
//    SearchView(networkManager: CatalogNetworkManager(appSettingsManager: AppSettingsManager()))
//        .modelContainer(for: [
//            Country.self, Region.self, City.self], inMemory: false)
//}
