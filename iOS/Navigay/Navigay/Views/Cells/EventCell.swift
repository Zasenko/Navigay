//
//  EventCell.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.10.23.
//

import SwiftUI
import SwiftData

struct EventCell: View {
    
    
    // MARK: - Private Properties
    
    let event: Event
    let showCountryCity: Bool
    let showStartDayInfo: Bool
    let showStartTimeInfo: Bool
    
    @State private var image: Image? = nil
    
    private var formattedDate: AttributedString {
        var formattedDate: AttributedString = event.startDate.formatted(Date.FormatStyle().month(.abbreviated).day().weekday(.wide).attributed)
      //  let dayOfWeek = AttributeContainer.dateField(.weekday)
       // let color = AttributeContainer.foregroundColor(event.startDate.isWeekend ? .blue : .blue)
      //  formattedDate.replaceAttributes(dayOfWeek, with: color)
        return formattedDate
    }

    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                    ZStack {
                            image?
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Rectangle())
                                .overlay(Rectangle().stroke(AppColors.lightGray5, lineWidth: 1))
                                .transition(.scale.animation(.easeInOut))
                    }
                    .onAppear() {
                        Task {
                            guard let url = event.smallPoster else { return } 
                            if let image = await ImageLoader.shared.loadImage(urlString: url) {
                                await MainActor.run {
                                    self.image = image
                                    self.event.image = image
                                }
                            }
                        }
                    }
                    .onChange(of: event.smallPoster) { oldValue, newValue in
                        Task {
                            guard let url = newValue else {
                                return
                            }
                            
                            if let image = await ImageLoader.shared.loadImage(urlString: url) {
                                await MainActor.run {
                                    self.image = image
                                  //  self.event.image = image
                                }
                            }
                        }
                    }

                if event.isFree {
                    Text("free")
                        .font(.footnote)
                        .bold()
                        .foregroundColor(AppColors.background)
                        .padding(5)
                        .padding(.horizontal, 5)
                        .background(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            VStack(spacing: 0) {
                Text(event.name)
                    .font(.footnote)
                    .bold()
                    .foregroundColor(.primary)
                    .lineSpacing(-10)
                    .multilineTextAlignment(.center)
                   // .lineLimit(1)
                
                if (showStartDayInfo || event.location != nil || showCountryCity) {
                    Color.clear
                        .frame(height: 5)
                }
                
                if showStartDayInfo {
                    Text(formattedDate)
                        .bold()
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineSpacing(-10)
                        .multilineTextAlignment(.center)
                      //  .lineLimit(1)
                }
//                if showStartTimeInfo {
//                    Text(stringForToday())
//                        .foregroundStyle(.secondary)
//                        .lineLimit(1)
//                }
                if let location = event.location {
                    Text(location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineSpacing(-10)
                        .multilineTextAlignment(.center)
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
            .padding(.vertical, 10)
        }
        .background(AppColors.lightGray6)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))        
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
