//
//  EventCell.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.10.23.
//

import SwiftUI

struct EventCell: View {
    
    let event: Event
    
    @State private var image: Image? = nil
    
    var formattedDate: AttributedString {
        var formattedDate: AttributedString = event.startDate.formatted(Date.FormatStyle().day().month(.wide).weekday(.wide).attributed)
        let weekday = AttributeContainer.dateField(.weekday)
        let color = AttributeContainer.foregroundColor(event.startDate.isWeekend ? .red : .blue)
        formattedDate.replaceAttributes(weekday, with: color)
        return formattedDate
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(formattedDate)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
            
            
            
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 170, height: 220)
                    .mask(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                    )
                    .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 3)
                    .shadow(color: Color.gray.opacity(0.3), radius: 30, x: 0, y: 30)
            } else {
                Color.black
                    .frame(width: 170, height: 220)
                    .mask(RoundedRectangle(cornerRadius: 20))
            }
            Text(event.name)
                .font(.subheadline)
                .bold()
                .foregroundColor(.primary)
                        //     .matchedGeometryEffect(id: "name", in: namespace)
                .lineLimit(1)
                .padding(.top)
                .padding(.bottom, 8)
            Text("free event")
                .font(.caption)
                .bold()
                .foregroundColor(.white)
                .modifier(CapsuleSmall(background: .green, foreground: .white))
                .opacity(event.isFree ? 1 : 0)
                .padding(.bottom)
        }
        .frame(width: 170)
        .onAppear() {
            if let url = event.smallPoster {
                Task {
                    if let image = await ImageLoader.shared.loadImage(urlString: url) {
                        await MainActor.run {
                            self.image = image
                        }
                    }
                }
            }
        }
    }
}
//
//#Preview {
//    EventCell(event: Event(decodedEvent: DecodedEvent(id: 1, name: "CoNNect", type: .party, startDate: "2023-11-17", startTime: "", finishDate: "", finishTime: "", address: "", latitude: 16.5875, longitude: 26.5786, isHorizontal: true, cover: "https://img.freepik.com/free-vector/valentines-day-party-invitation-poster-template-with-lettering-text-love-purple-hearts_333792-7.jpg", isFree: true, tags: [.dj, .menOnly, .goGoShow], isActive: true, placeName: "Opera club", about: nil, www: nil, fb: nil, insta: nil, tickets: nil, ownerPlace: nil, ownerUser: nil)))
//}
