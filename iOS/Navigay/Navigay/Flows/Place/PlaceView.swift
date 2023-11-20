//
//  PlaceView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import MapKit

struct PlaceView: View {
    
    // MARK: - Properties
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    
    // MARK: - Private Properties
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    private let place: Place
    @State private var allPhotos: [String] = []
    private let networkManager: PlaceNetworkManagerProtocol
    private let errorManager: ErrorManagerProtocol
    
    @State private var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
    @State private var position: MapCameraPosition = .automatic
    
    // MARK: - Inits
    init(place: Place, networkManager: PlaceNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
        self.place = place
        self.networkManager = networkManager
        self.errorManager = errorManager
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Divider()
                    createList(width: geometry.size.width)
                }
                .navigationBarBackButtonHidden()
                .toolbarBackground(AppColors.background)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack(spacing: 0) {
                            Text(place.type.getName().uppercased())
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            Text(place.name)
                                .font(.headline)
                                .fontWeight(.black)
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
                            place.isLiked.toggle()
                        } label: {
                            Image(systemName: place.isLiked ? "heart.fill" : "heart")
                                .bold()
                                .frame(width: 30, height: 30, alignment: .leading)
                        }
                        .tint(place.isLiked ? .red :  .secondary)
                    }
                }
                .onAppear() {
                    allPhotos = place.getAllPhotos()
                    loadPlace()
                }
            }
        }
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private func createList(width: CGFloat) -> some View {
        List {
            if !allPhotos.isEmpty {
                PhotosTabView(allPhotos: $allPhotos, width: width)
                    .frame(width: width, height: (width / 4) * 5)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .padding(.bottom)
            }
            Section {
                HStack {
                    if let url = place.avatar {
                        ImageLoadingView(url: url, width: 80, height: 80, contentMode: .fill) {
                            Color.orange
                        }
                        .clipShape(Circle())
                        .padding()
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(place.name)
                            .font(.largeTitle).bold()
                            .foregroundColor(.primary)
                        Text(place.address)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            //ПАРТИ
            
            TagsView(tags: place.tags)
                .padding(.bottom)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            Section {
                ForEach(place.timetable.sorted(by: { $0.day.rawValue < $1.day.rawValue } )) { day in
                    HStack {
                        Text(day.day.getString())
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(day.open.formatted(date: .omitted, time: .shortened))
                        Text("—")
                        Text(day.close.formatted(date: .omitted, time: .shortened))
                    }
                    .font(.caption)
                }
                Text(place.otherInfo ?? "")
            }
            .padding()
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listSectionSeparator(.hidden)
            
            VStack(spacing: 10) {
                if let phone = place.phone {
                    Button {
                        call(phone: phone)
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
                    .foregroundColor(.black)
                    .background(AppColors.lightGray6)
                    .clipShape(Capsule(style: .continuous))
                    .buttonStyle(.borderless)
                }
                HStack {
                    if let www = place.www {
                        Button {
                            goToWebSite(url: www)
                        } label: {
                            HStack {
                                AppImages.iconGlobe
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25, alignment: .leading)
                                Text("Web page")
                                    .font(.caption)
                                    .bold()
                            }
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.black)
                        .padding()
                        .background(AppColors.lightGray6)
                        .clipShape(Capsule(style: .continuous))
                    }
                    if let facebook = place.facebook {
                        Button {
                            goToWebSite(url: facebook)
                        } label: {
                            AppImages.iconFacebook
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25, alignment: .leading)
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.black)
                        .padding()
                        .background(AppColors.lightGray6)
                        .clipShape(.circle)
                    }
                    
                    if let instagram = place.instagram {
                        Button {
                            goToWebSite(url: instagram)
                        } label: {
                            AppImages.iconInstagram
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25, alignment: .leading)
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.black)
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
            
            map
            
            Text(place.about ?? "")
                .font(.callout)
                .padding()
                .padding(.vertical, 40)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
            
            //фотографии должны открываться
            Section {
                LazyVGrid(columns: gridLayout, spacing: 2) {
                    ForEach(place.photos, id: \.self) { url in
                        ImageLoadingView(url: url, width: (width - 4) / 3, height: (width - 4) / 3, contentMode: .fill) {
                            AppColors.lightGray6 //TODO animation
                        }
                        .clipped()
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }
    
    private var map: some View {
        VStack {
            Map(position: $position, interactionModes: []) {
                Marker("", monogram: Text(place.type.getImage()), coordinate: place.coordinate)
                    .tint(place.type.getColor())
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .including([.publicTransport])))
            .mapControlVisibility(.hidden)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 0))
            .padding(.vertical)
            .onAppear {
                position = .camera(MapCamera(centerCoordinate: place.coordinate, distance: 500))
            }
            Text(place.address)
                .font(.caption)
                .foregroundColor(.secondary)
            Button {
                goToMaps(coordinate: place.coordinate)
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
            .foregroundColor(.black)
            .background(AppColors.lightGray6)
            .clipShape(Capsule(style: .continuous))
            .buttonStyle(.borderless)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    // MARK: - Private Functions
    
    private func loadPlace() {
        Task {
            if networkManager.loadedPlaces.contains(where: { $0 == place.id}) {
                return
            }
            let errorModel = ErrorModel(massage: "Something went wrong. The information has not been updated. Please try again later.", img: nil, color: nil)
            do {
                let decodedResult = try await networkManager.getPlace(id: place.id)
                guard decodedResult.result, let decodedPlace = decodedResult.place else {
                    debugPrint("ERROR - getAdminInfo API:", decodedResult.error?.message ?? "---")
                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                    return
                }
                networkManager.addToLoadedPlaces(id: decodedPlace.id)
                await MainActor.run {
                    updatePlace(decodedPlace: decodedPlace)
                    /// чтобы фотографии не загружались несколько раз
                    let newPhotosLinks = place.getAllPhotos()
                    for links in newPhotosLinks {
                        if !allPhotos.contains(where:  { $0 == links } ) {
                            allPhotos.append(links)
                        }
                    }
                }
            } catch {
                debugPrint("ERROR - get place: ", error)
                errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            }
        }
    }
    
    private func updatePlace(decodedPlace: DecodedPlace) {
        let lastUpdate = decodedPlace.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
        if place.lastUpdateComplite != lastUpdate {
            place.updatePlaceComplite(decodedPlace: decodedPlace)
            let timetable = place.timetable
            place.timetable.removeAll()
            timetable.forEach( { context.delete($0) })
            if let timetable = decodedPlace.timetable {
                for day in timetable {
                    let workingDay = WorkDay(workDay: day)
                    place.timetable.append(workingDay)
                }
            }
        }
    }
    
    private func call(phone: String) {
        let api = "tel://"
        let stringUrl = api + phone
        guard let url = URL(string: stringUrl) else { return }
        UIApplication.shared.open(url)
    }
    
    private func goToWebSite(url: String) {
        guard let url = URL(string: url) else { return }
        openURL(url)
    }
    private func goToMaps(coordinate: CLLocationCoordinate2D) {
        let stringUrl = "maps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)"
        guard let url = URL(string: stringUrl) else { return }
        openURL(url)
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

struct PhotosTabView: View {
    @Binding var allPhotos: [String]
    @State private var selectedPhotoIndex: Int = 0
    let width: CGFloat
    var body: some View {
        VStack {
            TabView(selection: $selectedPhotoIndex) {
                ForEach(allPhotos.indices, id: \.self) { index in
                    ImageLoadingView(url: allPhotos[index], width: width, height: (width / 4) * 5, contentMode: .fill) {
                        AppColors.lightGray6 // TODO: animation
                    }
                    .tag(index)
                    .clipped()
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(width: width, height: (width / 4) * 5)
            
            HStack(spacing: 10) {
                ForEach(0..<allPhotos.count, id: \.self) { index in
                    Circle()
                        .foregroundStyle(index == selectedPhotoIndex ? .gray : AppColors.lightGray6)
                        .frame(width: 6, height: 6)
                        .onTapGesture {
                            selectedPhotoIndex = index
                        }
                }
            }
            .padding(5)
            .frame(maxWidth: .infinity)
        }
    }
}

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
                item(tag: tag, color: color)
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
    
    private func item(tag: Tag, color: Color) -> some View {
        Text(tag.getString())
            .font(.caption)
            .bold()
            .foregroundColor(.primary)
            .modifier(CapsuleSmall(background: color, foreground: .primary))
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
