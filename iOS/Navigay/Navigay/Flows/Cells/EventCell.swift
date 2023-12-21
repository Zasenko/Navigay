//
//  EventCell.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.10.23.
//

import SwiftUI

struct EventCell: View {
    
    private let event: Event
    
    @State private var image: Image?
    let width: CGFloat
    var formattedDate: AttributedString {
        var formattedDate: AttributedString = event.startDate.formatted(Date.FormatStyle().day().month(.abbreviated).weekday(.wide).attributed)
        let weekday = AttributeContainer.dateField(.weekday)
        let color = AttributeContainer.foregroundColor(event.startDate.isWeekend ? .red : .blue)
        formattedDate.replaceAttributes(weekday, with: color)
        return formattedDate
    }
    
    @State private var isShowEvent: Bool = false
    private let networkManager: EventNetworkManagerProtocol
    private let errorManager: ErrorManagerProtocol
   // private let placeNetworkManager: PlaceNetworkManagerProtocol
    
    init(event: Event, image: Image? = nil, width: CGFloat, networkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {//, placeNetworkManager: PlaceNetworkManagerProtocol) {
        self.event = event
        _image = State(initialValue: image)
        self.width = width
        self.networkManager = networkManager
        self.errorManager = errorManager
     //   self.placeNetworkManager = placeNetworkManager
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    if let url = event.smallPoster {
                        Group {
                            if let image = image  {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: width, height: width)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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
                            } else {
                                Color.red
                                    .frame(width: width, height: width)
                            }
                        }
                           .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 3)
                           .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 10)
                        .onAppear() {
                            Task {
                                if let image = await ImageLoader.shared.loadImage(urlString: url) {
                                    self.image = image
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
                Text(event.name)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .padding(.vertical, 5)
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                    
            }
        }
        .onAppear() {
            if let url = event.smallPoster {
                Task {
                    if let image = await ImageLoader.shared.loadImage(urlString: url) {
                        await MainActor.run {
                            self.event.image = image
                            self.image = image
                        }
                    }
                }
            }
        }
        .onTapGesture {
            withAnimation(.spring()) {
                isShowEvent = true
            }
        }
        .sheet(isPresented:  $isShowEvent) {
            
        } content: {
            EventView(isPresented: $isShowEvent, event: event, networkManager: networkManager, errorManager: errorManager)
                .presentationDragIndicator(.hidden)
                .presentationDetents([.large])
                .presentationCornerRadius(25)
            
        }
    }
}

//
#Preview {
    let appSettingsManager = AppSettingsManager()
    let eventNetworkManager = EventNetworkManager(appSettingsManager: appSettingsManager)
  //  let placeNetworkManager = PlaceNetworkManager(appSettingsManager: appSettingsManager)
    let errorManager = ErrorManager()
    let decodedEvent = DecodedEvent(id: 0, name: "HARD ON party", type: .party, startDate: "2023-12-02", startTime: "00:00:00", finishDate: "2023-12-03", finishTime: "06:00:00", address: "", latitude: 16.25566, longitude: 48.655885, poster: "https://www.navigay.me/images/events/AT/12/1700152341132_227.jpg", smallPoster: "https://www.navigay.me/images/events/AT/12/1700152341132_684.jpg", isFree: true, tags: nil, isActive: true, location: nil, lastUpdate: "2023-11-16 17:26:12", about: nil, fee: nil, tickets: nil, www: nil, facebook: nil, instagram: nil, phone: nil, place: nil)
    let event = Event(decodedEvent: decodedEvent)
    return EventCell(event: event, image: nil, width: 200, networkManager: eventNetworkManager, errorManager: errorManager)
}
