//
//  EventCell.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.10.23.
//

import SwiftUI

struct ImageLoadingView2<Content: View>: View {
    
    //MARK: - Properties
    
    let loadView: () -> Content  //загрузка
   // let namespace: Namespace.ID
    
    @State private var image: Image?
    let url: String
    let width: CGFloat
    let height: CGFloat
    let contentMode: ContentMode
    
    init(url: String, width: CGFloat, height: CGFloat, contentMode: ContentMode, @ViewBuilder content: @escaping () -> Content) {
        self.loadView = content
        self.url = url
        self.width = width
        self.height = height
        self.contentMode = contentMode
      //  self.namespace = namespace
    }
    
    var body: some View {
        Group {
            if let image = image  {
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                 //   .matchedGeometryEffect(id: "img", in: namespace)
            } else {
                loadView()
                    .onAppear() {
                        Task {
                            if let image = await ImageLoader.shared.loadImage(urlString: url) {
                                self.image = image
                            }
                        }
                    }
            }
        }
        .frame(width: width, height: height)
    }
}



struct EventCell: View {
    
    let event: Event
    @State private var image: Image? = nil
    let width: CGFloat
    var formattedDate: AttributedString {
        var formattedDate: AttributedString = event.startDate.formatted(Date.FormatStyle().day().month(.wide).weekday(.wide).attributed)
        let weekday = AttributeContainer.dateField(.weekday)
        let color = AttributeContainer.foregroundColor(event.startDate.isWeekend ? .red : .blue)
        formattedDate.replaceAttributes(weekday, with: color)
        return formattedDate
    }
    
    var onTap: (Image?) -> Void
    
    init(event: Event, image: Image? = nil, width: CGFloat, onTap: @escaping (Image?) -> Void) {
        self.event = event
        self.image = image
        self.width = width
        self.onTap = onTap
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("free event")
                .font(.caption)
                .bold()
                .foregroundColor(.white)
                .modifier(CapsuleSmall(background: .green, foreground: .white))
            //.opacity(event.isFree ? 1 : 0)
                .padding(.bottom, 8)
            Text(formattedDate)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
            VStack(spacing: 0) {
                if let url = event.smallPoster {
                    Group {
                        if let image = image  {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: width, height: (width / 4) * 3)
                                .clipped()
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
                                .frame(width: width, height: (width / 4) * 3)
                        }
                    }
                    .onAppear() {
                        Task {
                            if let image = await ImageLoader.shared.loadImage(urlString: url) {
                                self.image = image
                            }
                        }
                    }
                   // .padding(10)
                    .clipped()
//                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    //                    .padding()
                    //                    .mask(
                    //                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                    //                    )
                    .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 3)
                    .shadow(color: Color.gray.opacity(0.3), radius: 30, x: 0, y: 30)
                    //     .frame(maxHeight: .infinity, alignment: .top)
                    
                }
                Text(event.name)
                    .font(.callout)
                    .bold()
                    .foregroundColor(.primary)
                //     .matchedGeometryEffect(id: "name", in: namespace)
                    .lineLimit(2)
                    .padding(4)
                //.padding(.bottom, 8)
                    .frame(height: 80)
            }
            .background(.indigo)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            Spacer()
            }
        .background(.gray)
            .frame(width: width,
                   height: (width / 4) * 8)
        .background(.red)
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
