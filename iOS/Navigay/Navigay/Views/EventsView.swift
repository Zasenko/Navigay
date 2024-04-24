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
    
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @Binding var selectedDate: Date?
    @Binding var displayedEvents: [Event]
    @Binding var actualEvents: [Event]
    @Binding var todayEvents: [Event]
    @Binding var upcomingEvents: [Event]
    @Binding var eventsDates: [Date]
    
    @State private var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20, alignment: .top), count: 2)
    @Binding var showCalendar: Bool
    @Namespace private var animation
    
    let size: CGSize
    let eventDataManager: EventDataManagerProtocol
    let placeDataManager: PlaceDataManagerProtocol
    let eventNetworkManager: EventNetworkManagerProtocol
    let placeNetworkManager: PlaceNetworkManagerProtocol
    let errorManager: ErrorManagerProtocol
    
    @State private var selectedEvent: Event?
    
    @State var columns: Int = 2
    
    var body: some View {
        Section {
            if todayEvents.count > 0 {
                Text("Today")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom)
                    .padding(.top)
                if todayEvents.count == 1 {
                    ForEach(todayEvents) { event in
                        Button {
                            selectedEvent = event
                        } label: {
                            EventCell(event: event, showCountryCity: false, showStartDayInfo: false, showStartTimeInfo: true)
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
                            EventCell(event: event, showCountryCity: false, showStartDayInfo: false, showStartTimeInfo: false)
                                .matchedGeometryEffect(id: "TodayEv\(event.id)", in: animation)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom)
                }
            }
            if upcomingEvents.count > 0 {
                HStack(alignment: .firstTextBaseline) {
                    Text("Upcoming Events")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: (actualEvents.count - todayEvents.count - displayedEvents.count) > 0 ? .leading : .center)
                    if (actualEvents.count - todayEvents.count - displayedEvents.count) > 0 {
                        Button {
                            showCalendar = true
                        } label: {
                            VStack(spacing: 4) {
                                HStack {
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
                                Text("\(actualEvents.count - todayEvents.count - displayedEvents.count) more events")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom)
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
                            EventCell(event: event, showCountryCity: false, showStartDayInfo: true, showStartTimeInfo: false)
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
                            EventCell(event: event, showCountryCity: false, showStartDayInfo: true, showStartTimeInfo: false)
                                .matchedGeometryEffect(id: "DisplayedEv\(event.id)", in: animation)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom)
                }
            }
        }
        .fullScreenCover(item: $selectedEvent) { event in
            EventView(viewModel: EventView.EventViewModel.init(event: event, modelContext: modelContext, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, placeDataManager: placeDataManager, eventDataManager: eventDataManager))
        }
        .onChange(of: selectedDate, initial: false) { oldValue, newValue in
            showCalendar = false
            if let date = newValue {
                getEvents(for: date)
            } else {
                showUpcomingEvents()
            }
            
        }
        .sheet(isPresented:  $showCalendar) {} content: {
            CalendarView(selectedDate: $selectedDate, eventsDates: $eventsDates)
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(25)
        }
    }
    
    private func getEvents(for date: Date) {
        Task {
            let events = await eventDataManager.getEvents(for: date, events: actualEvents )
            await MainActor.run {
                self.displayedEvents = events
            }
        }
    }
    
    private func showUpcomingEvents() {
        displayedEvents = upcomingEvents
    }
}

//#Preview {
//    EventsView()
//}

/// Grid Layout

struct StaggeredGrid<Content: View, T: Identifiable>: View where T: Hashable {
    var content: (T) -> Content
    var list: [T]
    var columns: Int
    var showsIndicators: Bool
    var spacing: CGFloat
    
    @State private var size: CGSize = .zero
    
    init(columns: Int,
         showsIndicators: Bool,
         spacing: CGFloat,
         list: [T],
         content: @escaping (T) -> Content) {
        self.content = content
        self.list = list
        self.columns = columns
        self.showsIndicators = showsIndicators
        self.spacing = spacing
    }
    
    func setUpList() -> [[T]] {
        var gridArray: [[T]] = Array(repeating: [], count: columns)
        var currentIndex: Int = 0
        for object in list {
            gridArray[currentIndex].append(object)
            if currentIndex == (columns - 1) {
                currentIndex = 0
            } else {
                currentIndex += 1
            }
        }
        return gridArray
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/) {
            ForEach(setUpList(), id: \.self) { columnsData in
                LazyVStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: spacing) {
                    ForEach(columnsData) { object in
                        content(object)
                    }
                }
            }
        }
        .saveSize(in: $size)
    }
}


struct SizeCalculator: ViewModifier {
    
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            size = proxy.size
                        }
                }
            )
    }
}

extension View {
    func saveSize(in size: Binding<CGSize>) -> some View {
        modifier(SizeCalculator(size: size))
    }
}
