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
    
    @State private var image: Image? = nil

    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            imgView
            infoView
        }
        .background(AppColors.lightGray5)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
    
    private var imgView: some View {
        ZStack(alignment: .topTrailing) {
            image?
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Rectangle())
                .overlay(Rectangle().stroke(AppColors.lightGray5, lineWidth: 1))
                .transition(.scale.animation(.easeInOut))
            HStack(spacing: 0) {
                if event.isLiked {
                    AppImages.iconHeartFill
                        .font(.footnote)
                        .bold()
                        .foregroundColor(.white)
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
                        .padding(5)
                        .padding(.horizontal, 5)
                        .background(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
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
                EventInfoRow(iconName: "clock", infoText: timeString)
            }
            
            if let location = event.location {
                EventInfoRow(iconName: "location.fill", infoText: location)
            }
            
            if showCountryCity {
                EventInfoRow(infoText: "\(event.city?.name ?? "") • \(event.city?.region?.country?.name ?? "")")
            }
        }
    }
    
    //TODO: сократить
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
                            return "закончилось в " + finishTime.formatted(date: .omitted, time: .shortened)//.format("HH:mm")
                        } else if finishTime.isSameHour(as: now) {
                            if finishTime.isFutureMinutes(as: now) {
                                return "скоро закончится"
                            } else {
                                return "закончилось"
                            }
                        } else {
                            return "закончится в " + finishTime.formatted(date: .omitted, time: .shortened)//.format("HH:mm")
                        }
                    } else {
                        return nil
                    }
                } else {
                    return "идет до " + finishDate.formatted(date: .abbreviated, time: .omitted)//.format("dd-MM")
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
                                    return "закончилось в " + finishTime.formatted(date: .omitted, time: .shortened)//.format("HH:mm")
                                } else if finishTime.isSameHour(as: now) {
                                    if finishTime.isFutureMinutes(as: now) {
                                        return "скоро закончится"
                                    } else {
                                        return "закончилось"
                                    }
                                } else {
                                    return "закончится в " + finishTime.formatted(date: .omitted, time: .shortened)//.format("HH:mm")
                                }
                            } else {
                                return nil
                            }
                        } else {
                            return "идет до " + finishDate.formatted(date: .abbreviated, time: .omitted)//.format("dd-MM")
                        }
                    } else {
                        return "началось в " + startTime.formatted(date: .omitted, time: .shortened)//.format("HH:mm")
                    }
                } else if startTime.isSameHour(as: now) {
                    if startTime.isFutureMinutes(as: now) {
                        return "скоро начнется"
                    } else {
                        return "началось"
                    }
                } else {
                    return "начнется в " + startTime.formatted(date: .omitted, time: .shortened)//.format("HH:mm")
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
    let eventNetworkManager = EventNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
    let decodedEvent = DecodedEvent(id: 0, name: "HARD ON party", type: .party, startDate: "2024-04-23", startTime: "13:34:00", finishDate: "2024-04-24", finishTime: "19:20:00", address: "", latitude: 16.25566, longitude: 48.655885, poster: "https://www.navigay.me/images/events/AT/12/1700152341132_227.jpg", smallPoster: "https://www.navigay.me/images/events/AT/12/1700152341132_684.jpg", isFree: true, tags: nil, location: "Cafe Savoy", lastUpdate: "2023-11-16 17:26:12", about: nil, fee: nil, tickets: nil, www: nil, facebook: nil, instagram: nil, phone: nil, place: nil, owner: nil, city: nil, cityId: nil)
    let event = Event(decodedEvent: decodedEvent)
    event.isLiked = true
    return EventCell(event: event, showCountryCity: false, showStartDayInfo: true, showStartTimeInfo: true)
}

// Компонент для отображения строки информации с иконкой
struct EventInfoRow: View {
    let iconName: String?
    let infoText: String
    
    init(iconName: String? = nil, infoText: String) {
        self.iconName = iconName
        self.infoText = infoText
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            if let iconName = iconName {
                Image(systemName: iconName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(infoText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
