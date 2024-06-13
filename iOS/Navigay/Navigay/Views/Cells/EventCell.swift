//
//  EventCell.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.10.23.
//

import SwiftUI
import SwiftData

struct EventCell: View {
    
    
    // MARK: - Properties
    
    let event: Event
    let showCountryCity: Bool
    let showStartDayInfo: Bool
    let showStartTimeInfo: Bool
    let showLike: Bool
    let showLocation: Bool

    @State private var image: Image? = nil

    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            imgView
            infoView
        }
        .background(AppColors.lightGray5)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(AppColors.lightGray3, lineWidth: 1))
    }
    
    // MARK: - Views
    
    private var imgView: some View {
        ZStack(alignment: .topTrailing) {
            image?
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipped()
                .transition(.scale.animation(.easeInOut))
            HStack(alignment: .top, spacing: 0) {
                Spacer()
                if showLike && event.isLiked {
                    AppImages.iconHeartFill
                        .font(.footnote)
                        .bold()
                        .foregroundColor(.white)
                        .frame(height: 16)
                        .padding(5)
                        .padding(.horizontal, 5)
                        .padding(.trailing, event.isFree ? 15 : 0)
                        .background(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .offset(x: event.isFree ? 20 : 0)
                }
                if event.isFree {
                    Text("free")
                        .font(.footnote)
                        .bold()
                        .foregroundColor(AppColors.background)
                        .frame(height: 16)
                        .padding(5)
                        .padding(.horizontal, 5)
                        .background(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .onAppear() {
            Task(priority: .high) {
                if let img = event.smallPosterImg {
                    await MainActor.run {
                        self.image = img
                    }
                } else {
                    guard let url = event.smallPoster else { return }
                    if let image = await ImageLoader.shared.loadImage(urlString: url) {
                        await MainActor.run {
                            self.image = image
                            self.event.smallPosterImg = image
                        }
                    }
                }
            }
        }
        .onChange(of: event.smallPoster) { oldValue, newValue in
            Task {
                guard let url = newValue else { return }
                if let image = await ImageLoader.shared.loadImage(urlString: url) {
                    await MainActor.run {
                        self.image = image
                    }
                }
            }
        }
    }
    
    private var infoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.name)
                .font(.footnote)
                .bold()
                .foregroundColor(.primary)
            if showStartDayInfo {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    AppImages.iconCalendar
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(event.startDate.formatted(Date.FormatStyle().month(.abbreviated).day().weekday(.wide).attributed))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineSpacing(-10)
                        .multilineTextAlignment(.leading)
                }
            }
            if showStartTimeInfo, let timeString = stringForToday() {
                infoRow(icon: AppImages.iconClock, text: timeString)
            }
            if showLocation, let location = event.location {
                infoRow(icon: AppImages.iconLocationFill, text: location)
            }
            if showCountryCity {
                Text("\(event.city?.name ?? "") • \(event.city?.region?.country?.name ?? "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func infoRow(icon: Image, text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            icon
                .font(.caption)
                .foregroundColor(.secondary)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Private Functions
    
    private func stringForToday() -> String? {
        let startDate = event.startDate
        let startTime = event.startTime
        let finishDate = event.finishDate
        let finishTime = event.finishTime
        
        let now = Date()
        
        if startDate.isPastDate {
            if let finishDate {
                if finishDate.isToday {
                    if let finishTime {
                        if finishTime.isPastHour(of: now) {
                            return "ended at " + finishTime.formatted(date: .omitted, time: .shortened)
                        } else if finishTime.isSameHour(as: now) {
                            if finishTime.isFutureMinutes(as: now) {
                                return "ending soon"
                            } else {
                                return "ended"
                            }
                        } else {
                            return "ends at " + finishTime.formatted(date: .omitted, time: .shortened)
                        }
                    } else {
                        return nil
                    }
                } else {
                    let finishTimeString = finishTime?.formatted(date: .omitted, time: .shortened)
                    return "ongoing until "
                    + finishDate.formatted(Date.FormatStyle().month(.abbreviated).day())
                    + (finishTimeString != nil ? ", " : "")
                    + (finishTimeString ?? "")
                }
            } else {
                return nil
            }
        } else if startDate.isToday {
            if let startTime {
                if startTime.isPastHour(of: now) {
                    if let finishDate {
                        if finishDate.isToday {
                            if let finishTime {
                                if finishTime.isPastHour(of: now) {
                                    return "ended at " + finishTime.formatted(date: .omitted, time: .shortened)
                                } else if finishTime.isSameHour(as: now) {
                                    if finishTime.isFutureMinutes(as: now) {
                                        return "ending soon"
                                    } else {
                                        return "ended"
                                    }
                                } else {
                                    return "ends at " + finishTime.formatted(date: .omitted, time: .shortened)
                                }
                            } else {
                                return nil
                            }
                        } else {
                            let finishTimeString = finishTime?.formatted(date: .omitted, time: .shortened)
                            return "ongoing until "
                            + finishDate.formatted(Date.FormatStyle().month(.abbreviated).day())
                            + (finishTimeString != nil ? ", " : "")
                            + (finishTimeString ?? "")
                        }
                    } else {
                        return "started at " + startTime.formatted(date: .omitted, time: .shortened)
                    }
                } else if startTime.isSameHour(as: now) {
                    if startTime.isFutureMinutes(as: now) {
                        return "starting soon"
                    } else {
                        return "started"
                    }
                } else {
                    return "starts at " + startTime.formatted(date: .omitted, time: .shortened)
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

#Preview {
    let errorManager = ErrorManager()
    let appSettingsManager = AppSettingsManager()
    let  networkMonitorManager = NetworkMonitorManager(errorManager: errorManager)
  //  let eventNetworkManager = EventNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
    let decodedEvent = DecodedEvent(id: 0,
                                    name: "HARD ON party",
                                    type: .party,
                                    startDate: "2024-04-23",
                                    startTime: "13:34:00",
                                    finishDate: "2024-04-25",
                                    finishTime: "19:20:00",
                                    address: "",
                                    latitude: 16.25566,
                                    longitude: 48.655885,
                                    poster: nil,// "https://www.navigay.me/images/events/AT/12/1700152341132_227.jpg",
                                    smallPoster: "https://www.navigay.me/images/events/AT/12/1700152341132_684.jpg",
                                    isFree: true,
                                    tags: nil, 
                                    location: "Cafe Savoy",
                                    lastUpdate: "2023-11-16 17:26:12",
                                    about: nil, fee: nil, tickets: nil, www: nil, facebook: nil, instagram: nil, phone: nil, place: nil, owner: nil, city: nil, cityId: nil)
    let event = Event(decodedEvent: decodedEvent)
    event.isLiked = true
   // event.smallPosterImg = Image("13")
    return EventCell(event: event, showCountryCity: false, showStartDayInfo: true, showStartTimeInfo: true, showLike: true, showLocation: true)
}

