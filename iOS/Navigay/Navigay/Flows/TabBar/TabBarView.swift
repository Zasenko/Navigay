//
//  TabBarView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 04.10.23.
//

import SwiftUI

enum TabBarRouter {
    case home, catalog, search, user, admin
}

struct TabBarView: View {
    
    @Environment(\.modelContext) var modelContext
    
    @State private var selectedPage: TabBarRouter = TabBarRouter.home
    
    private let homeButton = TabBarButton(title: "Around Me", img: AppImages.iconHome, page: .home)
    private let catalogButton = TabBarButton(title: "Catalog", img: AppImages.iconCatalog, page: .catalog)
    private let searchButton = TabBarButton(title: "Search", img: AppImages.iconSearch, page: .search)
    private let userButton = TabBarButton(title: "Around Me", img: AppImages.iconPerson, page: .user)
    private let adminButton = TabBarButton(title: "Admin Panel", img: AppImages.iconAdmin, page: .admin)
    
    @State private var userImage: Image? = nil

    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject private var authenticationManager: AuthenticationManager

    private let appSettingsManager: AppSettingsManagerProtocol
    private let errorManager: ErrorManagerProtocol
    private let networkMonitor: NetworkMonitorManagerProtocol
    
    private let aroundNetworkManager: AroundNetworkManagerProtocol
    private let catalogNetworkManager: CatalogNetworkManagerProtocol
    private let placeNetworkManager: PlaceNetworkManagerProtocol
    private let eventNetworkManager: EventNetworkManagerProtocol
    private let commentsNetworkManager: CommentsNetworkManagerProtocol

    private let placeDataManager: PlaceDataManagerProtocol
    private let eventDataManager: EventDataManagerProtocol
    private let catalogDataManager: CatalogDataManagerProtocol
    
    //MARK: - Init
    
    init(appSettingsManager: AppSettingsManagerProtocol,
         errorManager: ErrorManagerProtocol, networkMonitor: NetworkMonitorManagerProtocol) {
        self.errorManager = errorManager
        self.appSettingsManager = appSettingsManager
        self.networkMonitor = networkMonitor
        self.aroundNetworkManager = AroundNetworkManager(networkMonitorManager: networkMonitor, appSettingsManager: appSettingsManager)
        self.catalogNetworkManager = CatalogNetworkManager(networkMonitorManager: networkMonitor, appSettingsManager: appSettingsManager)
        self.eventNetworkManager = EventNetworkManager(networkMonitorManager: networkMonitor, appSettingsManager: appSettingsManager)
        self.placeNetworkManager = PlaceNetworkManager(networkMonitorManager: networkMonitor, appSettingsManager: appSettingsManager)
        self.commentsNetworkManager = CommentsNetworkManager(networkMonitorManager: networkMonitor, appSettingsManager: appSettingsManager)
        self.placeDataManager = PlaceDataManager()
        self.eventDataManager = EventDataManager()
        self.catalogDataManager = CatalogDataManager()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            switch selectedPage {
            case .home:
                HomeView2(modelContext: modelContext, aroundNetworkManager: aroundNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, catalogNetworkManager: catalogNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, catalogDataManager: catalogDataManager, commentsNetworkManager: commentsNetworkManager)
                    .environmentObject(locationManager)
            case .catalog:
                CatalogView(viewModel: CatalogView.CatalogViewModel(modelContext: modelContext, catalogNetworkManager: catalogNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, catalogDataManager: catalogDataManager, commentsNetworkManager: commentsNetworkManager))
            case .search:
                SearchView(viewModel: SearchView.SearchViewModel(modelContext: modelContext, catalogNetworkManager: catalogNetworkManager, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, catalogDataManager: catalogDataManager, commentsNetworkManager: commentsNetworkManager))
            case .user:
                AppUserView(modelContext: modelContext, userNetworkManager: UserNetworkManager(networkMonitorManager: networkMonitor, appSettingsManager: appSettingsManager), placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, commentsNetworkManager: commentsNetworkManager)
            case .admin:
                if let user = authenticationManager.appUser, (user.status == .admin || user.status == .moderator) {
                    AdminView(viewModel: AdminViewModel(user: user, errorManager: errorManager, networkManager: AdminNetworkManager(networkMonitorManager: networkMonitor, appSettingsManager: appSettingsManager)))
                } else {
                    EmptyView()
                }
            }
            tabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
//        .alert(isPresented: $locationManager.isAlertIfLocationDeniedDisplayed) {
//            Alert(title: Text("Location Access"),
//                  message: Text("To provide accurate search results, this app needs access to your location. Would you like to go to Settings to enable location access?"),
//                  primaryButton: .default(Text("Settings"), action: {
//                selectedPage = .search
//                guard let url = URL(string: UIApplication.openSettingsURLString) else {
//                    return
//                }
//                UIApplication.shared.open(url)
//            }),
//                  secondaryButton: .default(Text("Cancel"), action: {
//                selectedPage = .search
//            }))
//        }
//        .onChange(of: locationManager.authorizationStatus) { oldValue, newValue in
//            switch newValue {
//            case .loading, .authorized:
//                selectedPage = .home
//            case .denied:
//                selectedPage = .search
//            }
//        }
        .onChange(of: authenticationManager.appUser?.photo, initial: true) { oldValue, newValue in
            guard let url = newValue else {
                self.userImage = nil
                return
            }
            Task {
                if let image = await ImageLoader.shared.loadImage(urlString: url) {
                    await MainActor.run {
                        self.userImage = image
                    }
                }
            }
        }
    }

    private var tabBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 40) {
                TabBarButtonView(selectedPage: $selectedPage, button: homeButton)
                TabBarButtonView(selectedPage: $selectedPage, button: catalogButton)
                TabBarButtonView(selectedPage: $selectedPage, button: searchButton)
                if let img = userImage {
                    Button {
                        selectedPage = .user
                    } label: {
                        img
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .clipShape(Circle())
                            .padding(3)
                            .overlay(
                                Circle()
                                    .stroke(selectedPage == .user ? authenticationManager.isUserOnline ? .green : .red : AppColors.lightGray5, lineWidth: selectedPage == .user ? 3 : 2)
                            )
                    }
                } else {
                    Button {
                        selectedPage = .user
                    } label: {
                        userButton.img
                            .resizable()
                            .scaledToFit()
                            .frame(width: authenticationManager.appUser == nil ? 25 : 22, height: authenticationManager.appUser == nil ? 25 : 22)
                            .clipShape(Circle())
                            .foregroundColor(selectedPage == .user ? .primary : AppColors.lightGray5)
                            .bold()
                            .padding(authenticationManager.appUser == nil ? 0 : 3)
                            .overlay(
                                Circle()
                                    .stroke(authenticationManager.appUser == nil ? .clear : selectedPage == .user ? authenticationManager.isUserOnline ? .green : .red : AppColors.lightGray5, lineWidth: selectedPage == .user ? 3 : 2)
                            )
                    }
                }
                if let user = authenticationManager.appUser, (user.status == .admin || user.status == .moderator) {
                    TabBarButtonView(selectedPage: $selectedPage, button: adminButton)
                }
            }
            .padding(.top, 10)
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
    }
}

//#Preview {
//    TabBarView(authenticationManager: AuthenticationManager(keychainManager: KeychainManager(), networkManager: AuthNetworkManager(appSettingsManager: AppSettingsManager()), errorManager: ErrorManager()), appSettingsManager: AppSettingsManager())
//}
