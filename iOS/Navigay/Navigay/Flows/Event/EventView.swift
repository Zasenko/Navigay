//
//  EventView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import SwiftData
import MapKit

struct EventView: View {
    
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    
    // MARK: - Private Properties
    
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var authenticationManager: AuthenticationManager
  //  @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(animation: .snappy)
    private var allPlaces: [Place]
    private let event: Event
    @State private var image: Image? = nil
    private let networkManager: EventNetworkManagerProtocol
    private let errorManager: ErrorManagerProtocol
    private let placeNetworkManager: PlaceNetworkManagerProtocol //??
    @State private var position: MapCameraPosition = .automatic
    @State private var isShowPlace: Bool = true
    @State private var place: Place? = nil
   // let namespace: Namespace.ID
    
    // MARK: - Inits
    init(isPresented: Binding<Bool>, event: Event, networkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol, placeNetworkManager: PlaceNetworkManagerProtocol) {
        print("init event view id: \(event.id)")
        _isPresented = isPresented
        self.event = event
        self.networkManager = networkManager
        self.errorManager = errorManager
        self.placeNetworkManager = placeNetworkManager
        self.image = event.image
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
               // VStack(spacing: 0) {
                    //  Divider()
                    createList(width: geometry.size.width)
                      //     }
                .toolbar(.hidden, for: .navigationBar)
                .onAppear() {
                    loadEvent()
                }
            }
        }
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private func createList(width: CGFloat) -> some View {
        List {
            ZStack(alignment: .topTrailing) {
                if let image = image  {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: width)
                        .clipped()
                } else {
                    Color.red
                        .frame(width: width, height: (width / 4) * 3)
                }
                Button {
                    isPresented.toggle()
                } label: {
                    AppImages.iconX
                        .bold()
                        .foregroundStyle(.secondary)
                        .padding(5)
                        .background(.ultraThinMaterial)
                        .clipShape(.circle)
                }
                .padding()
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .ignoresSafeArea(.all, edges: .top)
            .listRowSeparator(.hidden)
            .onAppear() {
                Task {
                    if let url = event.poster {
                        if let image = await ImageLoader.shared.loadImage(urlString: url) {
                            await MainActor.run {
                                self.image = image
                                self.event.image = image
                            }
                        }
                    }
                }
            }
                
            Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.name)
                            .font(.largeTitle).bold()
                            .foregroundColor(.primary)
                        Text(event.address)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Start")
                        .font(.title2)
                        .bold()
                        .offset(x: 30)
                    HStack(spacing: 10) {
                        AppImages.iconCalendar
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(AppColors.lightGray5)
                            .frame(width: 20, height: 20, alignment: .leading)
                        Text(event.startDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.callout)
                    }
                    if let startTime = event.startTime {
                        HStack {
                            AppImages.iconClock
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(AppColors.lightGray5)
                                .frame(width: 20, height: 20, alignment: .leading)
                            Text(startTime.formatted(date: .omitted, time: .shortened))
                                .font(.callout)
                        }
                    }
                }
                .padding()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
                
                if let finishDate = event.finishDate {
                    VStack(alignment: .leading) {
                        Text("Finish")
                            .font(.title2)
                            .bold()
                            .offset(x: 30)
                        HStack(spacing: 10) {
                            AppImages.iconCalendar
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(AppColors.lightGray5)
                                .frame(width: 20, height: 20, alignment: .leading)
                            Text(finishDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.callout)
                        }
                        if let finishTime = event.finishTime {
                            HStack {
                                AppImages.iconClock
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(AppColors.lightGray5)
                                    .frame(width: 20, height: 20, alignment: .leading)
                                Text(finishTime.formatted(date: .omitted, time: .shortened))
                                    .font(.callout)
                            }
                        }
                    }
                    .padding()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding()
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            TagsView(tags: event.tags)
                .padding(.bottom)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            if let about = event.about {
                Text(about)
                    .font(.callout)
                    .padding()
                    .padding(.bottom, 40)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                //    .listRowSeparator(.hidden)
            }
            
            if event.isFree {
                //todo
                Text("Free event")
                    .padding()
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            } else {
                Section {
                    if let fee = event.fee {
                        Text(fee)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
            }
            
            VStack(spacing: 10) {
                if let phone = event.phone {
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
                    if let tickets = event.tickets {
                        Button {
                            goToWebSite(url: tickets)
                        } label: {
                            HStack {
                                AppImages.iconWallet
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25, alignment: .leading)
                                Text("By tickets")
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
                    if let www = event.www {
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
                    if let facebook = event.facebook {
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
                    
                    if let instagram = event.instagram {
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
           // .listRowBackground(Color.orange)
            
            if let place = event.place {
                    //DOTO!!!!!!!!!!
                NavigationLink(place.name, value: place)
                    VStack( alignment: .leading, spacing: 0) {
                        Text("Location:")
                            .bold()
                            .foregroundStyle(.secondary)
                            .offset(x: 70)
                        HStack(spacing: 20) {
                            if let url = place.avatar {
                                ImageLoadingView(url: url, width: 50, height: 50, contentMode: .fill) {
                                    Color.orange
                                }
                                .background(.regularMaterial)
                                .mask(Circle())
                            } else {
                                Text(place.type.getImage())
                                    .frame(width: 50, height: 50)
                                    .background(.regularMaterial)
                                    .mask(Circle())
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    if place.isLiked {
                                        AppImages.iconHeartFill
                                            .font(.body)
                                            .foregroundColor(.red)
                                    }
                                    Text(place.name)
                                        .multilineTextAlignment(.leading)
                                        .font(.body)
                                        .bold()
                                        .foregroundColor(.primary)
                                        
                                    
                                }
                                Text(place.type.getName())
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                .padding()
                .frame(maxWidth: .infinity)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
//                .onTapGesture {
//                    self.place = place
//                }
                
            }
            
            map
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }
    
    private var map: some View {
        VStack {
            Map(position: $position, interactionModes: []) {
                Marker("", monogram: Text("🎉"), coordinate: event.coordinate)
                    .tint(.red)
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .including([.publicTransport])))
            .mapControlVisibility(.hidden)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 0))
            .onAppear {
                position = .camera(MapCamera(centerCoordinate: event.coordinate, distance: 500))
            }
            Text(event.address)
                .font(.caption)
                .foregroundColor(.secondary)
            Button {
                goToMaps(coordinate: event.coordinate)
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
            .padding(.bottom, 40)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    // MARK: - Private Functions
    
    private func loadEvent() {
        Task {
            if networkManager.loadedEvents.contains(where: { $0 == event.id}) {
                return
            }
            let errorModel = ErrorModel(massage: "Something went wrong. The information has not been updated. Please try again later.", img: nil, color: nil)
            do {
                let decodedResult = try await networkManager.fetchEvent(id: event.id)
                guard decodedResult.result, let decodedEvent = decodedResult.event else {
                    debugPrint("ERROR - getAdminInfo API:", decodedResult.error?.message ?? "---")
                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                    return
                }
                networkManager.addToLoadedEvents(id: decodedEvent.id)
                await MainActor.run {
                    updateEvent(decodedEvent: decodedEvent)
                }
            } catch {
                debugPrint("ERROR - get place: ", error)
                errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            }
        }
    }

    private func updateEvent(decodedEvent: DecodedEvent) {
        let lastUpdate = decodedEvent.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
        if event.lastUpdateComplite != lastUpdate {
            event.updateEventComplete(decodedEvent: decodedEvent)
        }
        if let decodePlace = decodedEvent.place {
            var newPlace: Place?
            if let place = allPlaces.first(where: { $0.id == decodePlace.id} ) {
                place.updatePlaceIncomplete(decodedPlace: decodePlace)
                newPlace = place
            } else if decodePlace.isActive {
                let place = Place(decodedPlace: decodePlace)
                newPlace = place
            }
            event.place = newPlace
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
//    EventView()
//}

private struct OffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

struct ScrollViewOffset<Content: View>: View {
  let content: () -> Content

  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  var body: some View {
    ScrollView {
      offsetReader
      content()
    }
    .coordinateSpace(name: "frameLayer")
  }

  var offsetReader: some View {
    GeometryReader { proxy in
      Color.clear
        .preference(
          key: OffsetPreferenceKey.self,
          value: proxy.frame(in: .named("frameLayer")).minY
        )
    }
    .frame(height: 0) // 👈🏻 make sure that the reader doesn't affect the content height
  }
}
