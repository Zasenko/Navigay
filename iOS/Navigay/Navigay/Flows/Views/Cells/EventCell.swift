//
//  EventCell.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.10.23.
//

import SwiftUI
import SwiftData

struct EventCell: View {
    
    @ObservedObject var authenticationManager: AuthenticationManager
    
    // MARK: - Private Properties
    
    private let event: Event
    private let showCountryCity: Bool
    private let showStartDayInfo: Bool
    private let showStartTimeInfo: Bool
    
    @State private var image: Image? = nil
    @State private var isShowEvent: Bool = false

    private let width: CGFloat
    
    private var formattedDate: AttributedString {
        var formattedDate: AttributedString = event.startDate.formatted(Date.FormatStyle().month(.abbreviated).day().weekday(.wide).attributed)
      //  let dayOfWeek = AttributeContainer.dateField(.weekday)
       // let color = AttributeContainer.foregroundColor(event.startDate.isWeekend ? .blue : .blue)
      //  formattedDate.replaceAttributes(dayOfWeek, with: color)
        return formattedDate
    }
    
    private var modelContext: ModelContext
    private let placeNetworkManager: PlaceNetworkManagerProtocol
    private let eventNetworkManager: EventNetworkManagerProtocol
    private let errorManager: ErrorManagerProtocol
    
    // MARK: - Init
    
    init(event: Event, width: CGFloat, modelContext: ModelContext, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol, showCountryCity: Bool, authenticationManager: AuthenticationManager, showStartDayInfo: Bool, showStartTimeInfo: Bool) {
        self.event = event
        self.width = width
        self.modelContext = modelContext
        self.eventNetworkManager = eventNetworkManager
        self.placeNetworkManager = placeNetworkManager
        self.errorManager = errorManager
        self.showCountryCity = showCountryCity
        self.authenticationManager = authenticationManager
        self.showStartDayInfo = showStartDayInfo
        self.showStartTimeInfo = showStartTimeInfo
    }
    
    // MARK: - Body
    
    var body: some View {
        Button {
            isShowEvent = true
        } label: {
            eventPosterLable
        }
        .sheet(isPresented: $isShowEvent) {
            isShowEvent = false
        } content: {
            EventView(isEventViewPresented: $isShowEvent, event: event, modelContext: modelContext, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, authenticationManager: authenticationManager)
                .presentationDragIndicator(.hidden)
                .presentationDetents([.large])
                .presentationCornerRadius(25)
        }
    }
    
    // MARK: - Views
    
    private var eventPosterLable: some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                if let url = event.smallPoster {
                    Group {
                        if let image = image  {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: width, height: width)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(AppColors.lightGray5, lineWidth: 1))
                        } else {
                            AppColors.lightGray6
                                .frame(width: width, height: width)
                        }
                    }
                    .onAppear() {
                        Task {
                            if let image = await ImageLoader.shared.loadImage(urlString: url) {
                                await MainActor.run {
                                    self.image = image
                                    self.event.image = image
                                }
                            }
                        }
                    }
                }
                if event.isFree {
                    Text("free")
                        .font(.footnote)
                        .bold()
                        .foregroundColor(.white)
                        .padding(5)
                        .padding(.horizontal, 5)
                        .foregroundColor(.white)
                        .background(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            VStack(spacing: 0) {
                Text(event.name)
                    .font(.footnote)
                    .bold()
                    .foregroundColor(.primary)
                    .lineLimit(1)
                if showStartDayInfo {
                    Text(formattedDate)
                        .bold()
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
//                if showStartTimeInfo {
//                    Text(stringForToday())
//                        .foregroundStyle(.secondary)
//                        .lineLimit(1)
//                }
                if let location = event.location {
                    Text(location)
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
                if showCountryCity {
                    HStack(spacing: 5) {
                        Text(event.city?.name ?? "")
                            .bold()
                        Text("•")
                        Text(event.city?.region?.country?.name ?? "")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .padding(.top, 5)
        }
    }
    
    //TODO: неправильная сортировка!
//    private func stringForToday() -> String {
//        //let startDate = event.startDate
//       // let finishDate = event.finishDate
//        
//        let startTime = event.startTime
//        let finishTime = event.finishTime
//                
//        guard let startTime else {
//            return "today"
//        }
//        if startTime.isPastHour(of: Date()) {
//            return "going now"
//        } else {
//            return "at \(startTime.formatted(date: .omitted, time: .shortened))"
//        }
//    }
}

//#Preview {
//    let appSettingsManager = AppSettingsManager()
//    let eventNetworkManager = EventNetworkManager(appSettingsManager: appSettingsManager)
//    let errorManager = ErrorManager()
//    let decodedEvent = DecodedEvent(id: 0, name: "HARD ON party", type: .party, startDate: "2023-12-02", startTime: "00:00:00", finishDate: "2023-12-03", finishTime: "06:00:00", address: "", latitude: 16.25566, longitude: 48.655885, poster: "https://www.navigay.me/images/events/AT/12/1700152341132_227.jpg", smallPoster: "https://www.navigay.me/images/events/AT/12/1700152341132_684.jpg", isFree: true, tags: nil, isActive: true, location: nil, lastUpdate: "2023-11-16 17:26:12", about: nil, fee: nil, tickets: nil, www: nil, facebook: nil, instagram: nil, phone: nil, place: nil)
//    let event = Event(decodedEvent: decodedEvent)
//    return EventCell(event: event, width: 200, networkManager: eventNetworkManager, errorManager: errorManager)
//}
