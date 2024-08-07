//
//  EventMapCell.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 07.08.24.
//

import SwiftUI

struct EventMapCell: View {
    
    let event: Event
    let showDistance: Bool
    let showCountryCity: Bool
    let showLike: Bool
    
   // @State private var image: Image? = nil
    
    var body: some View {
            HStack(spacing: 20) {
//                ZStack(alignment: .topTrailing) {
//                    image?
//                        .resizable()
//                        .scaledToFit()
//                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//                        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(AppColors.lightGray5, lineWidth: 1))
//                        .frame(maxWidth: 100, maxHeight: 100)
//                    if event.isFree {
//                        Text("free")
//                            .font(.footnote)
//                            .bold()
//                            .foregroundColor(AppColors.background)
//                            .frame(height: 16)
//                            .padding(5)
//                            .padding(.horizontal, 5)
//                            .background(.green)
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                    }
//                }
                VStack(spacing: 0) {
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
                    Text(event.name)
                        .font(.body)
                        .bold()
                        .tint(.primary)
     
                    if let location = event.location {
                        Text(location)
                            .font(.footnote)
                            .bold()
                            .tint(.secondary)
                    }
                    Text(event.address)
                        .font(.footnote)
                        .tint(.secondary)
                    
                    // todo тот же код в EventView
                    if let finishDate = event.finishDate {
                        if finishDate.isSameDayWithOtherDate(event.startDate) {
                            Text(event.startDate.formatted(date: .long, time: .omitted))
                                .font(.footnote)
                                .bold()
                                .tint(.primary)
                            HStack {
                                if let startTime = event.startTime {
                                    HStack(spacing: 5) {
                                        AppImages.iconClock
                                            .font(.caption)
                                        Text(startTime.formatted(date: .omitted, time: .shortened))
                                            .font(.caption)
                                    }
                                    .tint(.secondary)
                                }
                                if let finishTime = event.finishTime {
                                    Text("—")
                                        .tint(.secondary)
                                        .frame(width: 20, alignment: .center)
                                    HStack(spacing: 5) {
                                        AppImages.iconClock
                                            .font(.caption)
                                        Text(finishTime.formatted(date: .omitted, time: .shortened))
                                            .font(.caption)
                                    }
                                    .tint(.secondary)
                                }
                            }
                            
                        } else {
                            HStack(alignment: .top) {
                                VStack(spacing: 5) {
                                    Text(event.startDate.formatted(date: .long, time: .omitted))
                                        .font(.footnote)
                                        .bold()
                                        .tint(.primary)
                                    if let startTime = event.startTime {
                                        HStack(spacing: 5) {
                                            AppImages.iconClock
                                                .font(.caption)
                                            Text(startTime.formatted(date: .omitted, time: .shortened))
                                                .font(.caption)
                                        }
                                        .tint(.secondary)
                                    }
                                }
                                Text("—")
                                    .frame(width: 20, alignment: .center)
                                VStack(spacing: 5) {
                                    Text(finishDate.formatted(date: .long, time: .omitted))
                                        .font(.footnote)
                                        .bold()
                                        .tint(.primary)
                                    if let finishTime = event.finishTime {
                                        HStack(spacing: 5) {
                                            AppImages.iconClock
                                                .font(.caption)
                                            Text(finishTime.formatted(date: .omitted, time: .shortened))
                                                .font(.caption)
                                        }
                                        .tint(.secondary)
                                    }
                                }
                            }
                        }
                    } else {
                        Text(event.startDate.formatted(date: .long, time: .omitted))
                            .font(.footnote)
                            .bold()
                            .tint(.primary)
                        if let startTime = event.startTime {
                            HStack(spacing: 5) {
                                AppImages.iconClock
                                    .font(.caption)
                                Text(startTime.formatted(date: .omitted, time: .shortened))
                                    .font(.caption)
                            }
                            .tint(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
//                VStack(spacing: 10) {
//                    AppImages.iconInfoCircle
//                        .foregroundStyle(.secondary)
//                        .bold()
//                    if event.isLiked {
//                        AppImages.iconHeartFill
//                            .foregroundStyle(.red)
//                    }
//                   
//                }
                AppImages.iconRight
                    .foregroundStyle(.secondary)
                    .bold()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppColors.background)
//            .onAppear() {
//                Task(priority: .high) {
//                    if let img = event.smallPosterImg {
//                        await MainActor.run {
//                            self.image = img
//                        }
//                    } else {
//                        guard let url = event.smallPoster,
//                              let image = await ImageLoader.shared.loadImage(urlString: url)
//                        else {
//                            await MainActor.run {
//                                self.image = nil
//                            }
//                            return
//                        }
//                        await MainActor.run {
//                            self.image = image
//                            self.event.smallPosterImg = image
//                        }
//                    }
//                }
//            }
//            .onChange(of: event.smallPoster) { _, newValue in
//                Task {
//                    guard let url = newValue,
//                          let image = await ImageLoader.shared.loadImage(urlString: url)
//                    else {
//                        await MainActor.run {
//                            self.image = nil
//                        }
//                        return
//                    }
//                    await MainActor.run {
//                        self.image = image
//                    }
//                }
//            }
    }
}

#Preview {
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
                                    poster: "https://www.navigay.me/images/events/AT/12/1700152341132_227.jpg",
                                    smallPoster: "https://www.navigay.me/images/events/AT/12/1700152341132_684.jpg",
                                    isFree: true,
                                    tags: nil,
                                    location: "Cafe Savoy",
                                    lastUpdate: "2023-11-16 17:26:12",
                                    about: nil, fee: nil, tickets: nil, www: nil, facebook: nil, instagram: nil, phone: nil, place: nil, owner: nil, city: nil, cityId: nil)
    let event = Event(decodedEvent: decodedEvent)
    event.isLiked = true
    event.smallPosterImg = Image("13")
    return EventMapCell(event: event, showDistance: true, showCountryCity: false, showLike: true)
}
