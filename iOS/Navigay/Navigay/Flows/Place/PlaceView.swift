//
//  PlaceView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import SwiftData
import MapKit

struct PlaceView: View {
    
    // MARK: - Private Properties
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PlaceViewModel
    @ObservedObject var authenticationManager: AuthenticationManager // TODO: убрать юзера из вью модели так как он в authenticationManager
    // MARK: - Inits
    
    init(place: Place, modelContext: ModelContext, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol, authenticationManager: AuthenticationManager) {
        let viewModel = PlaceViewModel(place: place, modelContext: modelContext, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager)
        _viewModel = State(wrappedValue: viewModel)
        _authenticationManager = ObservedObject(wrappedValue: authenticationManager)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            NavigationStack {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        Divider()
                        createList(width: geometry.size.width, geometry: geometry.size)
                    }
                    .navigationBarBackButtonHidden()
                    .toolbarBackground(AppColors.background)
                    .toolbarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            VStack(spacing: 0) {
                                Text(viewModel.place.type.getName().uppercased())
                                    .font(.caption).bold()
                                    .foregroundStyle(.secondary)
                                Text(viewModel.place.name)
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
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                viewModel.place.isLiked.toggle()
                            } label: {
                                Image(systemName: viewModel.place.isLiked ? "heart.fill" : "heart")
                                    .bold()
                                    .frame(width: 30, height: 30, alignment: .leading)
                            }
                            .tint(viewModel.place.isLiked ? .red :  .secondary)
                        }
                    }
                    .onAppear() {
                        viewModel.allPhotos = viewModel.place.getAllPhotos()
                        viewModel.loadPlace()
                    }
                }
            }
        }
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private func createList(width: CGFloat, geometry: CGSize) -> some View {
        List {
            if !viewModel.allPhotos.isEmpty {
                PhotosTabView(allPhotos: $viewModel.allPhotos, width: width)
                    .frame(width: width, height: (width / 4) * 5)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .padding(.bottom)
            }
            
            Section {
                HStack {
                    if let url = viewModel.place.avatar {
                        ImageLoadingView(url: url, width: 70, height: 70, contentMode: .fill) {
                            Color.orange
                        }
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppColors.lightGray5, lineWidth: 1))
                        .padding(.trailing)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.place.name)
                            .font(.title2).bold()
                            .foregroundColor(.primary)
                        Text(viewModel.place.address)
                            .font(.body)
                            .foregroundColor(.secondary)
                        //.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            TagsView(tags: viewModel.place.tags)
                .padding(.bottom)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            Section {
                ForEach(viewModel.place.timetable.sorted(by: { $0.day.rawValue < $1.day.rawValue } )) { day in
                    let dayOfWeek = Date().dayOfWeek
                    HStack {
                        Text(day.day.getString())
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if dayOfWeek == day.day {
                            if viewModel.place.isOpenNow() {
                                Text("open now")
                                    .font(.footnote).bold()
                                    .foregroundColor(.green)
                                    .padding(.trailing)
                            }
                        }
                        Text(day.open.formatted(date: .omitted, time: .shortened))
                        Text("—")
                        Text(day.close.formatted(date: .omitted, time: .shortened))
                    }
                    .font(.caption)
                    .listRowBackground(dayOfWeek == day.day ? AppColors.lightGray6 : AppColors.background)
                }
                Text(viewModel.place.otherInfo ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 40)
            }
            .padding()
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listSectionSeparator(.hidden)
            
            VStack(spacing: 10) {
                if let phone = viewModel.place.phone {
                    Button {
                        viewModel.call(phone: phone)
                    } label: {
                        HStack {
                            AppImages.iconPhoneFill
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25, alignment: .leading)
                            Text(phone)
                                .font(.title2)
                                .bold()
                        }
                    }
                    .padding()
                    .foregroundColor(.primary)
                    .background(AppColors.lightGray6)
                    .clipShape(Capsule(style: .continuous))
                    .buttonStyle(.borderless)
                }
                HStack {
                    if let www = viewModel.place.www {
                        Button {
                            viewModel.goToWebSite(url: www)
                        } label: {
                            HStack {
                                AppImages.iconGlobe
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25, alignment: .leading)
                                Text("Web")
                                    .font(.caption)
                                    .bold()
                            }
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.primary)
                        .padding()
                        .background(AppColors.lightGray6)
                        .clipShape(Capsule(style: .continuous))
                    }
                    if let facebook = viewModel.place.facebook {
                        Button {
                            viewModel.goToWebSite(url: facebook)
                        } label: {
                            AppImages.iconFacebook
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25, alignment: .leading)
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.primary)
                        .padding()
                        .background(AppColors.lightGray6)
                        .clipShape(.circle)
                    }
                    
                    if let instagram = viewModel.place.instagram {
                        Button {
                            viewModel.goToWebSite(url: instagram)
                        } label: {
                            AppImages.iconInstagram
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25, alignment: .leading)
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.primary)
                        .padding()
                        .background(AppColors.lightGray6)
                        .clipShape(.circle)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listSectionSeparator(.hidden)
            
            createMap(geometry: geometry)
            
            if !viewModel.place.events.isEmpty {
                Section {
                    Text("Upcoming events")//.uppercased())
                        .font(.title3).bold()
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 30)
                    LazyVGrid(columns: viewModel.gridLayoutEvents, spacing: 20) {
                        ForEach(viewModel.place.events.sorted(by: { $0.startDate < $1.startDate } )) { event in
                            EventCell(event: event, width: (width / 2) - 30, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, showCountryCity: false)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                }
                .listRowSeparator(.hidden)
                .frame(maxWidth: .infinity)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
            }
            
            Section {
                if let about = viewModel.place.about {
                    Text(about)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 50)
                        .listRowSeparator(.hidden)
                }
            }
            
            //todo фотографии должны открываться
            Section {
                LazyVGrid(columns: viewModel.gridLayoutPhotos, spacing: 2) {
                    ForEach(viewModel.place.photos, id: \.self) { url in
                        ImageLoadingView(url: url, width: (width - 4) / 3, height: (width - 4) / 3, contentMode: .fill) {
                            AppColors.lightGray6 //TODO animation
                        }
                        .clipped()
                    }
                }
                .padding(.vertical, 50)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            Section {
                
                HStack {
                    Text("Reviews")
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let user = authenticationManager.appUser, user.status != .blocked {
                        NavigationLink {
                            AddCommentView(text: "", characterLimit: 1000, placeId: viewModel.place.id, placeNetworkManager: viewModel.placeNetworkManager, authenticationManager: authenticationManager)
                        } label: {
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
                            RegistrationView(authenticationManager: authenticationManager) {
                                viewModel.showRegistrationView = false
                            }
                        }
                    }
                }
                .padding(.top, 50)
                .padding(.bottom, 10)
                .padding(.horizontal)
              //  .offset(x: 70)
                
                if viewModel.comments.isEmpty {
                    Text("No comments")
                } else {
                    ForEach(viewModel.comments) { comment in
                        VStack(spacing: 0) {
                            VStack(spacing: 10) {
                                if let rating = comment.rating {
                                    HStack {
                                        ForEach(1..<6) { int in
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(int <= rating ? .yellow : .secondary)
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
                                            ImageLoadingView(url: photo, width: width / 4, height: width / 4, contentMode: .fill) {
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
                                if let url = comment.user.photo {
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
                                Text(comment.user.name)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
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
    
    @ViewBuilder
    private func createMap(geometry: CGSize) -> some View {
        VStack {
            Map(position: $viewModel.position, interactionModes: [], selection: $viewModel.selectedTag) {
                Marker(viewModel.place.name, monogram: Text(viewModel.place.type.getImage()), coordinate: viewModel.place.coordinate)
                    .tint(viewModel.place.type.getColor())
                    .tag(viewModel.place.tag)
                    .annotationTitles(.hidden)
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .including([.publicTransport])))
            .mapControlVisibility(.hidden)
            .frame(height: geometry.width)
            .clipShape(RoundedRectangle(cornerRadius: 0))
            .onAppear {
                viewModel.position = .camera(MapCamera(centerCoordinate: viewModel.place.coordinate, distance: 500))
            }
            Text(viewModel.place.address)
                .font(.callout)
                .foregroundColor(.secondary)
                .padding()
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
            .foregroundColor(.primary)
            .modifier(CapsuleSmall(background: AppColors.lightGray6, foreground: .primary))
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
