//
//  EventView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI

struct EventView: View {
    
    let event: Event
    @Environment(\.modelContext) private var context
    let networkManager: EventNetworkManagerProtocol
    
    init(event: Event, networkManager: EventNetworkManagerProtocol) {
        self.event = event
        self.networkManager = networkManager
    }
    
    var body: some View {
        ScrollView {
            Section {
                Text(event.id.formatted())
                Text(event.name)
                Text(event.latitude.formatted())
                Text(event.longitude.formatted())
                Text(event.address)
                Text(event.startDate.formatted())
                Text(event.startTime?.formatted() ?? "")
                Text(event.finishDate?.formatted() ?? "")
                Text(event.finishTime?.formatted() ?? "")
                Text(event.cover ?? "")
                Text(event.placeName ?? "")
                Text(event.tickets ?? "")
                Text(event.www ?? "")
                Text(event.insta ?? "")
            }
            
            Section {
                ForEach(event.tags, id: \.self) { tag in
                    Text(tag.getString())
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

//#Preview {
//    EventView()
//}
