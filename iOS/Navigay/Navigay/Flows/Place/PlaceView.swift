//
//  PlaceView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import SwiftData
import MapKit

//TODO: сообщить об ошибке (место закрыто, неправильная информация)
// рейтинг заведения

struct PlaceView: View {
    
    // MARK: - Private Properties
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PlaceViewModel
    @ObservedObject private var authenticationManager: AuthenticationManager // TODO: убрать юзера из вью модели так как он в authenticationManager
    // MARK: - Inits
    
    init(place: Place,
         modelContext: ModelContext,
         placeNetworkManager: PlaceNetworkManagerProtocol,
         eventNetworkManager: EventNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol,
         authenticationManager: AuthenticationManager,
         placeDataManager: PlaceDataManagerProtocol,
         eventDataManager: EventDataManagerProtocol,
         showOpenInfo: Bool) {
        let viewModel = PlaceViewModel(place: place, modelContext: modelContext, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager, showOpenInfo: showOpenInfo)
        _viewModel = State(wrappedValue: viewModel)
        self.authenticationManager = authenticationManager
    }
        
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            GeometryReader { outsideProxy in
            VStack(spacing: 0) {
                Divider()
                        createList(outsideProxy: outsideProxy)
                    }
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.showHeaderTitle {
                    ToolbarItem(placement: .principal) {
                        VStack(spacing: 0) {
                            Text(viewModel.place.type.getName().uppercased())
                                .font(.caption).bold()
                                .foregroundStyle(.secondary)
                            Text(viewModel.place.name)
                                .font(.headline).bold()
                        }
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
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            viewModel.place.isLiked.toggle()
                            guard let user = authenticationManager.appUser else { return }
                            
                            if let index = user.likedPlaces.firstIndex(where: {$0 == viewModel.place.id} ) {
                                user.likedPlaces.remove(at: index)
                            } else {
                                user.likedPlaces.append(viewModel.place.id)
                            }
                        } label: {
                            Image(systemName: viewModel.place.isLiked ? "heart.fill" : "heart")
                                .bold()
                                .frame(width: 30, height: 30, alignment: .leading)
                        }
                        .tint(viewModel.place.isLiked ? .red :  .secondary)
                        if let user = authenticationManager.appUser, user.status == .admin {
                            Menu {
                                Button("Edit") {
                                    viewModel.showEditView = true
                                }
                                Button("Add Event") {
                                    viewModel.showAddEventView = true
                                }
                            } label: {
                                AppImages.iconSettings
                                    .bold()
                                    .frame(width: 30, height: 30, alignment: .leading)
                            }
                        }
                    }
                }
            }
            .onAppear() {
                viewModel.allPhotos = viewModel.place.getAllPhotos()
                viewModel.fetchPlace()
            }
            .navigationDestination(isPresented: $viewModel.showAddEventView) {
                if let user = authenticationManager.appUser, user.status == .admin {
                    NewEventView(viewModel: NewEventViewModel(place: viewModel.place, copy: nil, networkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager), authenticationManager: authenticationManager)
                } else {
                    //TODO: - вью ошибки и переход назад
                    EmptyView()
                }
            }
            .fullScreenCover(isPresented: $viewModel.showEditView) {
                viewModel.showEditView = false
            } content: {
                EditPlaceView(viewModel: EditPlaceViewModel(place: viewModel.place, networkManager: AdminNetworkManager(errorManager: viewModel.errorManager)))
            }
        }
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private func createList(outsideProxy: GeometryProxy) -> some View {
        List {
            headerView
            headerSection(width: outsideProxy.size.width)
            
            TagsView(tags: viewModel.place.tags)
                .padding(.bottom)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            
            createMap(size: outsideProxy.size)
            
            if !viewModel.place.timetable.isEmpty {
                TimetableView(place: viewModel.place, showOpenInfo: viewModel.showOpenInfo)
            }
            
            
            if let otherInfo = viewModel.place.otherInfo {
                Text(otherInfo)
                    //.font(.caption)
                    .foregroundStyle(.secondary)
                    .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 50, trailing: 20))
                    .listSectionSeparator(.hidden)
            }
            
            
            ContactInfoView(phone: viewModel.place.phone, www: viewModel.place.www, facebook: viewModel.place.facebook, instagram: viewModel.place.instagram)
                .listRowInsets(EdgeInsets(top: 50, leading: 20, bottom: 50, trailing: 20))
                .listSectionSeparator(.hidden)
            
            if viewModel.actualEvents.count > 0 {
                EventsView(modelContext: viewModel.modelContext, authenticationManager: authenticationManager, selectedDate: $viewModel.selectedDate, displayedEvents: $viewModel.displayedEvents, actualEvents: $viewModel.actualEvents, todayEvents: $viewModel.todayEvents, upcomingEvents: $viewModel.upcomingEvents, eventsDates: $viewModel.eventsDates, size: outsideProxy.size, eventDataManager: viewModel.eventDataManager, eventNetworkManager: viewModel.eventNetworkManager, placeNetworkManager: viewModel.placeNetworkManager, errorManager: viewModel.errorManager)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            
            if let about = viewModel.place.about {
                    Text(about)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 50, leading: 20, bottom: 50, trailing: 20))
            }
            
            if viewModel.place.photos.count > 0 {
                //todo фотографии должны открываться
                    LazyVGrid(columns: viewModel.gridLayoutPhotos, spacing: 2) {
                        ForEach(viewModel.place.photos, id: \.self) { url in
                            ImageLoadingView(url: url, width: (outsideProxy.size.width - 4) / 3, height: (outsideProxy.size.width - 4) / 3, contentMode: .fill) {
                                AppColors.lightGray6 //TODO animation
                            }
                            .clipped()
                        }
                    }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 50, leading: 0, bottom: 50, trailing: 0))
            }
            
            Section {
                HStack {
                    Text("Reviews")
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let user = authenticationManager.appUser, user.status != .blocked {
                        //TODO: Add review designe
                        ZStack {
                            NavigationLink {
                                AddCommentView(text: "", characterLimit: 1000, placeId: viewModel.place.id, placeNetworkManager: viewModel.placeNetworkManager, authenticationManager: authenticationManager)
                            } label: {
                                EmptyView()
                            }
                            Text("Add review")
                                .font(.callout.bold())
                                .padding()
                                .foregroundStyle(.blue)
                        }
                        
                    } else {
                        Button {
                            viewModel.showRegistrationView = true
                        } label: {
                            Text("Log in to write a review")
                                .font(.callout.bold())
                                .padding()
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.blue)
                        }
                        .fullScreenCover(isPresented: $viewModel.showRegistrationView) {
                            RegistrationView(authenticationManager: authenticationManager, errorManager: authenticationManager.errorManager) {
                                viewModel.showRegistrationView = false
                            }
                        }
                    }
                }
                .padding(.top, 50)
                .padding(.bottom, 10)
                .padding(.horizontal)
                
                if viewModel.comments.isEmpty {
                    //TODO: No comments
                    Text("No comments")
                } else {
                    ForEach(viewModel.comments) { comment in
                        VStack(spacing: 0) {
                            VStack(spacing: 10) {
                                if comment.rating != 0 {
                                    HStack {
                                        ForEach(1..<6) { int in
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(int <= comment.rating ? .yellow : .secondary)
                                        }
                                    }
                                }
                                if let comment = comment.comment {
                                    Text(comment)
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical)
                                }
                                if let photos = comment.photos {
                                    HStack {
                                        ForEach(photos, id: \.self) { photo in
                                            ImageLoadingView(url: photo, width: outsideProxy.size.width / 4, height: outsideProxy.size.width / 4, contentMode: .fill) {
                                                Color.orange
                                            }
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppColors.lightGray5, lineWidth: 1))
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(AppColors.lightGray6)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            HStack {
                                if let user = comment.user {
                                    if let url = user.photo {
                                        ImageLoadingView(url: url, width: 50, height: 50, contentMode: .fill) {
                                            AppColors.lightGray6 // TODO: animation in ImageLoadingView
                                        }
                                        .clipped()
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    } else {
                                        AppImages.iconPerson
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                    }
                                    Text(user.name)
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Text(comment.createdAt)
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                        .padding()
                        .padding(.vertical)
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .onAppear {
                viewModel.fetchComments()
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .buttonStyle(PlainButtonStyle())
    }
    
    private var headerView: some View {
        HStack(spacing: 20) {
            if let url = viewModel.place.avatar {
                ImageLoadingView(url: url, width: 60, height: 60, contentMode: .fill) {
                    Color.orange
                }
                .clipShape(Circle())
                .overlay(Circle().stroke(AppColors.lightGray5, lineWidth: 1))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.place.name)
                    .font(.title2).bold()
                    .foregroundColor(.primary)
                Text(viewModel.place.address)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
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
    
    @ViewBuilder
    private func createMap(size: CGSize) -> some View {
        VStack {
            Map(position: $viewModel.position, interactionModes: [], selection: $viewModel.selectedTag) {
                Marker(viewModel.place.address, monogram: Text(viewModel.place.type.getImage()), coordinate: viewModel.place.coordinate)
                    .tint(viewModel.place.type.getColor())
                    .tag(viewModel.place.tag)
                    .annotationTitles(.hidden)
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .including([.publicTransport])))
            .mapControlVisibility(.hidden)
            .frame(height: size.width)
            .clipShape(RoundedRectangle(cornerRadius: 0))
            .onAppear {
                viewModel.position = .camera(MapCamera(centerCoordinate: viewModel.place.coordinate, distance: 1500))
            }
//            Text(viewModel.place.address)
//                .font(.callout)
//                .foregroundColor(.secondary)
//                .padding()
            Button {
                viewModel.goToMaps()
            } label: {
                HStack {
                    AppImages.iconLocation
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25, alignment: .leading)
                    Text("Open in Maps")
                        .font(.caption)
                        .bold()
                }
            }
            .padding()
            .foregroundColor(.primary)
            .background(AppColors.lightGray6)
            .clipShape(Capsule(style: .continuous))
            .buttonStyle(.borderless)
            .padding(.bottom, 40)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

//#Preview {
//    let decodedPlace = DecodedPlace(id: 0, name: "HardOn", type: .bar, address: "bla bla", latitude: 48.19611791448819, longitude: 16.357055501725107, isActive: true, lastUpdate: "2023-11-19 08:00:45", avatar: nil, mainPhoto: nil, photos: nil, tags: nil, timetable: nil, otherInfo: nil, about: nil, www: nil, facebook: nil, instagram: nil, phone: nil, countryId: nil, regionId: <#T##Int?#>, cityId: nil, events: nil)
//    let appSettingsManager = AppSettingsManager()
//    let networkManager = PlaceNetworkManager(appSettingsManager: appSettingsManager)
//    let errorManager = ErrorManager()
//    let place = Place(decodedPlace: decodedPlace)
//    return PlaceView(place: place, networkManager: networkManager, errorManager: errorManager)
//      //  .modelContainer(for: [Place.self], inMemory: false)
//}

struct TagsView: View {
    
    //MARK: - Properties
    
    //MARK: - Private Properties
    
    let tags: [Tag]
    
    @State private var totalHeight: CGFloat = .zero
    
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - Inits
    
    init(tags: [Tag]) {
        self.tags = tags
    }
    
    //MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                GeometryReader { geometry in
                    self.generateContent(for: tags, color: .red, in: geometry, totalHeight: $totalHeight)
                }
            }
            .frame(height: totalHeight)
            .padding(.vertical)
        }
    }
    
    //MARK: - Private functions
    
    private func generateContent(for tags: [Tag], color: Color, in g: GeometryProxy, totalHeight: Binding<CGFloat>) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(tags, id: \.self) { tag in
                item(tag: tag)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == tags.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tag == tags.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader(totalHeight))
    }
    
    private func item(tag: Tag) -> some View {
        Text(tag.getString())
            .font(.caption)
            .bold()
            .foregroundColor(tag.getColor())
            .modifier(CapsuleSmall(foreground: .primary))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
