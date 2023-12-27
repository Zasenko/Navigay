//
//  TabBarView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 04.10.23.
//

import SwiftUI

enum TabBarRouter {
    case home, search, user, admin
}

struct TabBarView: View {
    
    @Environment(\.modelContext) var modelContext
    
    @State private var selectedPage: TabBarRouter = TabBarRouter.home
    
    private let homeButton = TabBarButton(title: "Around Me", img: AppImages.iconHome, page: .home)
    private let searchButton = TabBarButton(title: "Catalog", img: AppImages.iconSearch, page: .search)
    private let userButton = TabBarButton(title: "Around Me", img: AppImages.iconPerson, page: .user)
    private let adminButton = TabBarButton(title: "Admin Panel", img: AppImages.iconAdmin, page: .admin)
    
    @State private var userImage: Image? = nil

    @StateObject private var locationManager: LocationManager
    @ObservedObject private var authenticationManager: AuthenticationManager

    private let appSettingsManager: AppSettingsManagerProtocol
    private let errorManager: ErrorManagerProtocol
    private let aroundNetworkManager: AroundNetworkManagerProtocol
    private let catalogNetworkManager: CatalogNetworkManagerProtocol
    private let placeNetworkManager: PlaceNetworkManagerProtocol
    private let eventNetworkManager: EventNetworkManagerProtocol
    
    init(locationManager: LocationManager = LocationManager(), authenticationManager: AuthenticationManager, appSettingsManager: AppSettingsManagerProtocol, errorManager: ErrorManagerProtocol) {
        _locationManager = StateObject(wrappedValue: locationManager)
        _authenticationManager = ObservedObject(wrappedValue: authenticationManager)
        self.authenticationManager = authenticationManager
        self.errorManager = errorManager
        self.appSettingsManager = appSettingsManager
        self.aroundNetworkManager = AroundNetworkManager(appSettingsManager: appSettingsManager, errorManager: errorManager)
        self.catalogNetworkManager = CatalogNetworkManager(appSettingsManager: appSettingsManager, errorManager: errorManager)
        self.eventNetworkManager = EventNetworkManager(appSettingsManager: appSettingsManager, errorManager: errorManager)
        self.placeNetworkManager = PlaceNetworkManager(appSettingsManager: appSettingsManager, errorManager: errorManager)
    }
    
    var body: some View {
            VStack(spacing: 0) {
                switch selectedPage {
                case .home:
                    HomeView(modelContext: modelContext, aroundNetworkManager: aroundNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, locationManager: locationManager, errorManager: errorManager, user: authenticationManager.appUser, authenticationManager: authenticationManager)
                case .search:
                    SearchView(modelContext: modelContext, catalogNetworkManager: catalogNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, user: authenticationManager.appUser, authenticationManager: authenticationManager)
                case .user:
                    AppUserView(authenticationManager: authenticationManager)
                case .admin:
                    if let user = authenticationManager.appUser {
                        AdminView(viewModel: AdminViewModel(user: user, errorManager: errorManager, networkManager: AdminNetworkManager(errorManager: errorManager)))
                    } else {
                        EmptyView()
                    }
                }
                tabBar
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onAppear() {
                Task {
                    if let url = authenticationManager.appUser?.photo {
                        if let image = await ImageLoader.shared.loadImage(urlString: url) {
                            await MainActor.run {
                                self.userImage = image
                            }
                            
                        }
                    }
                }
            }
            .alert(isPresented: $locationManager.isAlertIfLocationDeniedDisplayed) {
                //TODO!!!! текст
                Alert(title: Text("Location access"),
                      message: Text("Go to Settings?"),
                      primaryButton: .default(Text("Settings"), action: {
                    selectedPage = .search
                    guard let url = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    UIApplication.shared.open(url)
                }),
                      secondaryButton: .default(Text("Cancel"), action: {
                    selectedPage = .search
                }))
            }
            .onChange(of: locationManager.authorizationStatus) { oldValue, newValue in
                switch newValue {
                case .loading, .authorized:
                    selectedPage = .home
                case .denied:
                    selectedPage = .search
                }
            }
            .onChange(of: authenticationManager.appUser?.photo) { oldValue, newValue in
                Task {
                    if let url = newValue {
                        if let image = await ImageLoader.shared.loadImage(urlString: url) {
                            await MainActor.run {
                                self.userImage = image
                            }
                            
                        }
                    }
                }
            }
            .environmentObject(authenticationManager)
       // }
    }
    
    
    private var tabBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 40) {
                if locationManager.authorizationStatus != .denied {
                    TabBarButtonView(selectedPage: $selectedPage,
                                     button: homeButton)
                }
                TabBarButtonView(selectedPage: $selectedPage,
                                 button: searchButton)
                
                if let img = userImage {
                    Button {
                        selectedPage = .user
                    } label: {
                        img
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .clipShape(Circle())
                            .padding(3)
                            .overlay(
                                Circle()
                                    .stroke(AppColors.lightGray5, lineWidth: 3)
                            )
                    }
                } else {
                    TabBarButtonView(selectedPage: $selectedPage,
                                     button: userButton)
                }
                
                if let user = authenticationManager.appUser, user.status == .admin {
                    TabBarButtonView(selectedPage: $selectedPage,
                                     button: adminButton)
                }
            }
            .padding(8)
        }
    }
}

//#Preview {
//    TabBarView(authenticationManager: AuthenticationManager(keychainManager: KeychainManager(), networkManager: AuthNetworkManager(appSettingsManager: AppSettingsManager()), errorManager: ErrorManager()), appSettingsManager: AppSettingsManager())
//}
