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
    
    @ObservedObject var authenticationManager: AuthenticationManager
    @Binding var selectedDate: Date?
    @Binding var displayedEvents: [Event]
    @Binding var actualEvents: [Event]
    @Binding var todayEvents: [Event]
    @Binding var upcomingEvents: [Event]
    @Binding var eventsDates: [Date]
    
    @State private var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20, alignment: .top), count: 2)
    @State private var showCalendar: Bool = false
    
    @Namespace var animation
    
    let size: CGSize
    let eventDataManager: EventDataManagerProtocol
    let eventNetworkManager: EventNetworkManagerProtocol
    let placeNetworkManager: PlaceNetworkManagerProtocol
    let errorManager: ErrorManagerProtocol
    
    @State private var selectedEvent: Event?
    @State private var showEvent: Bool = false
    
    @State var columns: Int = 3
    
    var body: some View {
        NavigationStack {
            Section {
                if todayEvents.count > 0 {
                    Text("Today's Events")
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    //    .padding(.horizontal, 20)
                        .offset(x: 70)
                        .padding(.top, 30)
                        .padding(.bottom, 10)
                    StaggeredGrid(columns: 2, showsIndicators: false, spacing: 10, list: todayEvents) { event in
                        Button {
                            selectedEvent = event
                            showEvent = true
                        } label: {
                            EventCell(event: event, showCountryCity: false, showStartDayInfo: false, showStartTimeInfo: false)
                                .matchedGeometryEffect(id: "TE\(event.id)", in: animation)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                }
                
                if upcomingEvents.count > 0 {
                    HStack {
                        Text(selectedDate?.formatted(date: .long, time: .omitted) ?? "Upcoming Events")
                            .font(.title2).bold()
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Button {
                            showCalendar = true
                        } label: {
                            HStack {
                                AppImages.iconCalendar
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                Text("Select date")
                                    .font(.caption)
                                    .multilineTextAlignment(.trailing)
                                    .lineSpacing(-10)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    StaggeredGrid(columns: columns, showsIndicators: false, spacing: 10, list: displayedEvents) { event in
                        Button {
                            selectedEvent = event
                            showEvent = true
                        } label: {
                            EventCell(event: event, showCountryCity: false, showStartDayInfo: true, showStartTimeInfo: false)
                                .matchedGeometryEffect(id: "DE\(event.id)", in: animation)
                        }
                    }
                    .padding(.horizontal, 10)
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
                            .presentationDragIndicator(.visible)
                            .presentationCornerRadius(25)
                    }
                    //                if selectedDate == nil {
                    //                    let count = actualEvents.count - todayEvents.count - displayedEvents.count
                    //                    if count > 0 {
                    //                        Text("and \(count) more...")
                    //                            .frame(maxWidth: .infinity)
                    //                            .font(.caption)
                    //                            .foregroundStyle(.secondary)
                    //                    }
                    //                }
                }
            }
           // .fullScreenCover(item: $selectedEvent) {
            .sheet(item: $selectedEvent) {
                //selectedEvent = nil
            } content: { event in
                EventView(event: event, modelContext: modelContext, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, authenticationManager: authenticationManager)
                    .presentationDragIndicator(.hidden)
                    .presentationDetents([.large])
                    //.presentationCornerRadius(25)
            }
        }
    }
    
    private func getEvents(for date: Date) {
        Task {
            let events = await eventDataManager.getEvents(for: date, events: actualEvents )
            await MainActor.run {
                displayedEvents = events
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

struct SizeCalculator: ViewModifier {
    
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear // we just want the reader to get triggered, so let's use an empty color
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
     //   ScrollView(.vertical) {
            HStack(alignment: .top, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/) {
                ForEach(setUpList(), id: \.self) { columnsData in
                    LazyVStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: spacing) {
                        ForEach(columnsData) { object in
                           content(object)
                        }
                    }
                }
            }
            .padding(.vertical)
            .saveSize(in: $size)
            
     //   .scrollIndicators(showsIndicators ? .visible : .hidden )
    }
}
