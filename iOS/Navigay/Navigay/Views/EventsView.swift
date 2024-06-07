//
//  EventsView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 28.01.24.
//

import SwiftUI
import SwiftData

struct EventsView: View {
    
    var modelContext: ModelContext
    
    @Binding var selectedDate: Date?
    @Binding var displayedEvents: [Event]
  //  @Binding var actualEvents: [Event]
    @Binding var eventsCount: Int
    @Binding var todayEvents: [Event]
    @Binding var upcomingEvents: [Event]
    @Binding var eventsDates: [Date]
    @Binding var selectedEvent: Event?
    
   // @State private var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20, alignment: .top), count: 2)
    @Binding var showCalendar: Bool
    @Namespace private var animation
    
    let size: CGSize
    @State private var columns: Int = 2
    
    var body: some View {
        Section {
            if todayEvents.count > 0 {
                Text("Today")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
                if todayEvents.count == 1 {
                    ForEach(todayEvents) { event in
                        Button {
                            selectedEvent = event
                        } label: {
                            EventCell(event: event, showCountryCity: false, showStartDayInfo: false, showStartTimeInfo: true, showLike: true)
                                .matchedGeometryEffect(id: "TodayEv\(event.id)", in: animation)
                        }
                        .frame(maxWidth: size.width / 2)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                    }
                } else {
                    StaggeredGrid(columns: 2, showsIndicators: false, spacing: 10, list: todayEvents) { event in
                        Button {
                            selectedEvent = event
                        } label: {
                            EventCell(event: event, showCountryCity: false, showStartDayInfo: false, showStartTimeInfo: true, showLike: true)
                                .matchedGeometryEffect(id: "TodayEv\(event.id)", in: animation)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom)
                }
            }
            if upcomingEvents.count > 0 {
                    Text("Upcoming Events")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .id("UpcomingEvents")
                        .padding()
                        .frame(maxWidth: .infinity)
                if selectedDate != nil {
                    Text(selectedDate?.formatted(date: .long, time: .omitted) ?? "")
                        .font(.title3).bold()
                        .foregroundStyle(.primary)
                        .animation(.default, value: selectedDate)
                        .frame(maxWidth: .infinity)
                }
                if displayedEvents.count == 1 {
                    ForEach(displayedEvents) { event in
                        Button {
                            selectedEvent = event
                        } label: {
                            EventCell(event: event, showCountryCity: false, showStartDayInfo: true, showStartTimeInfo: false, showLike: true)
                                .matchedGeometryEffect(id: "DisplayedEv\(event.id)", in: animation)
                        }
                        .frame(maxWidth: size.width / 2)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                    }
                } else {
                    StaggeredGrid(columns: 2, showsIndicators: false, spacing: 10, list: displayedEvents) { event in
                        Button {
                            selectedEvent = event
                        } label: {
                            EventCell(event: event, showCountryCity: false, showStartDayInfo: true, showStartTimeInfo: false, showLike: true)
                                .matchedGeometryEffect(id: "DisplayedEv\(event.id)", in: animation)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom)
                }
                
                if (eventsCount - todayEvents.count - displayedEvents.count) > 0 {
                    VStack(spacing: 4) {
                        Text("\(eventsCount - todayEvents.count - displayedEvents.count) more events")
                            .font(.headline)
                            .bold()
                        Button {
                            showCalendar.toggle()
                        } label: {
                            HStack(spacing: 4) {
                                AppImages.iconCalendar
                                    .font(.headline)
                                
                                Text("show calendar")
                                    .font(.caption)
                                    .bold()
                            }
                            .foregroundStyle(.blue)
                            .padding()
                            .background(AppColors.lightGray6)
                            .clipShape(Capsule(style: .continuous))
                        }
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

//#Preview {
//    EventsView()
//}
