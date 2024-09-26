//
//  OrganizerView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 22.09.24.
//

import SwiftUI

import SwiftUI
import SwiftData

//TODO: сообщить об ошибке (место закрыто, неправильная информация)
// рейтинг заведения

struct OrganizerView: View {
    
    // MARK: - Private Properties
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: OrganizerViewModel
    
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Init
    
    init(viewModel: OrganizerViewModel) {
        _viewModel = State(initialValue: viewModel)
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
                if viewModel.showHeaderTitle {
                    ToolbarItem(placement: .principal) {
                        Text(viewModel.organizer.name)
                                .font(.headline).bold()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation {
                            dismiss()
                        }
                    } label: {
                        AppImages.iconLeft
                            .bold()
                            .frame(width: 30, height: 30, alignment: .leading)
                    }
                    .tint(.primary)
                }
//                ToolbarItem(placement: .topBarTrailing) {
//                    HStack {
//                        Button  label: {
//                            Image(systemName: viewModel.place.isLiked ? "heart.fill" : "heart")
//                                .bold()
//                                .frame(width: 30, height: 30, alignment: .leading)
//                        }
//                        .tint(.red)
//                        if let user = authenticationManager.appUser, (user.status == .admin || user.status == .moderator) {
//                            Menu {
//                                NavigationLink("Edit Place") {
//                                    EditPlaceView(viewModel: EditPlaceViewModel(id: viewModel.place.id, place: viewModel.place, user: user, networkManager: EditPlaceNetworkManager(networkManager: authenticationManager.networkManager), errorManager: viewModel.errorManager))
//                                }
//                                NavigationLink("Add Event") {
//                                    NewEventView(viewModel: NewEventViewModel(user: user, place: viewModel.place, copy: nil, networkManager: EditEventNetworkManager(networkManager: authenticationManager.networkManager), errorManager: viewModel.errorManager))
//                                }
//                            } label: {
//                                AppImages.iconSettings
//                                    .bold()
//                                    .foregroundStyle(.blue)
//                            }
//                        }
//                    }
//                }
            }
            .onAppear() {
                viewModel.getEventsFromDB()
            }
            .onChange(of: viewModel.selectedDate, initial: false) { oldValue, newValue in
                viewModel.showCalendar = false
                if let date = newValue {
                    viewModel.getEvents(for: date)
                } else {
                    viewModel.showUpcomingEvents()
                }
            }
            .sheet(isPresented:  $viewModel.showCalendar) {} content: {
                CalendarView(selectedDate: $viewModel.selectedDate, eventsDates: $viewModel.eventsDates)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(25)
            }
            .sheet(isPresented: $viewModel.showAddCommentView) {
                AddCommentView(viewModel: AddCommentViewModel(item: .organizer, id: viewModel.organizer.id, networkManager: viewModel.commentsNetworkManager, errorManager: viewModel.errorManager))
            }
            .fullScreenCover(item: $viewModel.selectedEvent) { event in
                EventView(viewModel: EventView.EventViewModel.init(event: event, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, commentsNetworkManager: viewModel.commentsNetworkManager, notificationsManager: viewModel.notificationsManager))
            }
            .fullScreenCover(isPresented: $viewModel.showLoginView) {
                LoginView(viewModel: LoginViewModel(isPresented: $viewModel.showLoginView))
            }
            .fullScreenCover(isPresented: $viewModel.showRegistrationView) {
                RegistrationView(viewModel: RegistrationViewModel(isPresented: $viewModel.showRegistrationView))
            }
        }
    }
    
    // MARK: - Views
    
    private var listView: some View {
        GeometryReader { proxy in
            ScrollViewReader { scrollProxy in
                List {
                    headerView
                    headerSection(width: proxy.size.width)
                    if let about = viewModel.organizer.about {
                        Text("Information")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowSeparator(.hidden)
                        Text(about)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 50, leading: 20, bottom: 50, trailing: 20))
                    }
                    if let otherInfo = viewModel.organizer.otherInfo {
                        Text(otherInfo)
                            .foregroundStyle(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 50, trailing: 20))
                            .listSectionSeparator(.hidden)
                    }
                    
//                    Text("Details")
//                        .font(.title2).bold()
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                        .listRowSeparator(.hidden)
//                    
                    ContactInfoView(phone: $viewModel.organizer.phone, www: $viewModel.organizer.www, facebook: $viewModel.organizer.facebook, instagram: $viewModel.organizer.instagram)
                        .listRowInsets(EdgeInsets(top: 50, leading: 20, bottom: 50, trailing: 20))
                        .listSectionSeparator(.hidden)
                    
                    if viewModel.eventsCount > 0 {
                        EventsView(modelContext: viewModel.modelContext, selectedDate: $viewModel.selectedDate, displayedEvents: $viewModel.displayedEvents, eventsCount: $viewModel.eventsCount, todayEvents: $viewModel.todayEvents, upcomingEvents: $viewModel.upcomingEvents, eventsDates: $viewModel.eventsDates, selectedEvent: $viewModel.selectedEvent, showCalendar: $viewModel.showCalendar, size: proxy.size, showLocation: false)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    
                    if viewModel.organizer.photos.count > 0 {
                        //todo фотографии должны открываться
                        LazyVGrid(columns: viewModel.gridLayoutPhotos, spacing: 2) {
                            ForEach(viewModel.organizer.photos, id: \.self) { url in
                                ImageLoadingView(url: url, width: (proxy.size.width - 4) / 3, height: (proxy.size.width - 4) / 3, contentMode: .fill) {
                                    AppColors.lightGray6 //TODO animation
                                }
                                .clipped()
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 50, leading: 0, bottom: 50, trailing: 0))
                    }
                    CommentsView(comments: $viewModel.comments, isLoading: $viewModel.isCommentsLoading, showAddReviewView: $viewModel.showAddCommentView, showRegistrationView: $viewModel.showRegistrationView, showLoginView: $viewModel.showLoginView, size: proxy.size, errorManager: viewModel.errorManager, deleteComment: { id in
                        //viewModel.deleteComment(id: id)
                    })
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .onAppear {
                       // viewModel.fetchComments()
                    }
                    Color.clear
                        .frame(height: 50)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .buttonStyle(PlainButtonStyle())
                .onChange(of: viewModel.selectedDate, initial: false) { oldValue, newValue in
                    withAnimation {
                        scrollProxy.scrollTo("UpcomingEvents", anchor: .top)
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 20) {
            if let url = viewModel.organizer.avatarUrl {
                ImageLoadingView(url: url, width: 50, height: 50, contentMode: .fill) {
                    ImageFetchingView()
                }
                .clipShape(Circle())
                .overlay(Circle().stroke(AppColors.lightGray5, lineWidth: 1))
                .padding(8)
            }
            Text(viewModel.organizer.name)
                .font(.title2).bold()
                .foregroundColor(.primary)
                .baselineOffset(0)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .onAppear {
            viewModel.showHeaderTitle = false
        }
        .onDisappear {
            viewModel.showHeaderTitle = true
        }
    }
    
    @ViewBuilder
    private func headerSection(width: CGFloat) -> some View {
        ZStack {
            if !viewModel.allPhotos.isEmpty {
                PhotosTabView(allPhotos: $viewModel.allPhotos, width: width)
                    .frame(width: width, height: ((width / 4) * 5) + 20)///20 is spase after tabview for circls
            }
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}
//
//#Preview {
//    OrganizerView()
//}

#Preview {
//    let decodedPlace = DecodedPlace(id: 0, name: "HardOn", type: .bar, address: "Seyringer Strasse, 13", latitude: 48.19611791448819, longitude: 16.357055501725107, lastUpdate: "2023-11-19 08:00:45", avatar: "https://esx.bigo.sg/eu_live/2u4/1D4hHo.jpg", mainPhoto: nil, photos: nil, tags: nil, timetable: nil, otherInfo: nil, about: nil, www: nil, facebook: nil, instagram: nil, phone: nil, city: nil, cityId: nil, events: nil)
//    let place = Place(decodedPlace: decodedPlace)
//    place.mainPhotoUrl = "https://i0.wp.com/avatars.dzeninfra.ru/get-zen_doc/758638/pub_5de772c30a451800b17484b0_5de7747416ef9000ae6548f6/scale_1200?resize=768%2C1024&ssl=1"
    let appSettingsManager = AppSettingsManager()
    let errorManager = ErrorManager()
    let keychainManager = KeychainManager()
    let networkMonitorManager = NetworkMonitorManager(errorManager: errorManager)
    let networkManager = NetworkManager(session: URLSession.shared, networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager, keychainManager: keychainManager)
    let placeNetworkManager = PlaceNetworkManager(networkManager: networkManager)
    let eventNetworkManager = EventNetworkManager(networkManager: networkManager)
    let commentsNetworkManager = CommentsNetworkManager(networkManager: networkManager)
    let placeDataManager = PlaceDataManager()
    let eventDataManager = EventDataManager()
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AppUser.self, Country.self, Region.self, City.self, Event.self, Place.self, User.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    let authNetworkManager = AuthNetworkManager(networkManager: networkManager)
    let authenticationManager = AuthenticationManager(keychainManager: keychainManager, networkMonitorManager: networkMonitorManager, networkManager: networkManager, authNetworkManager: authNetworkManager, errorManager: errorManager)
    let notificationsManager = NotificationsManager()
    
    let decodedOrganizer = DecodedOrganizer(id: 0, name: "Ken Club", lastUpdate: "2023-12-02 12:00:00", avatar: "https://api.adi19.ru/uploads/news/77030/poster.jpg", mainPhoto: nil, photos: nil, otherInfo: nil, about: nil, www: nil, facebook: nil, instagram: nil, phone: nil, city: nil, cityId: nil, events: nil)
    let organizer = Organizer(decodedOrganizer: decodedOrganizer)
    organizer.mainPhotoUrl = "https://api.adi19.ru/uploads/news/77030/poster.jpg"
    organizer.www = "www.kenclub.ru"
    organizer.facebook = "facebook.com/kenclub"
    organizer.instagram = "instagram.com/kenclub"
    organizer.phone = "+79111234567"
    organizer.about = "You should know the differences between aptitude and apt, or what SELinux or AppArmor is.\n\nA SSH service will be running on the mandatory port 4242 in your virtual machine. For security reasons, it must not be possible to connect using SSH as root."
    let organizerNetworkManager = OrganizerNetworkManager(networkManager: networkManager)
    let organizerDataManager = OrganizerDataManager()
    return OrganizerView(viewModel: OrganizerView.OrganizerViewModel.init(organizer: organizer, modelContext: sharedModelContainer.mainContext, organizerNetworkManager: organizerNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, organizerDataManager: organizerDataManager, eventDataManager: eventDataManager, commentsNetworkManager: commentsNetworkManager, notificationsManager: notificationsManager, placeNetworkManager: placeNetworkManager, placeDataManager: placeDataManager))
    .environmentObject(authenticationManager)
}
