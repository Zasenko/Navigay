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
    
    let size: CGSize
    let eventDataManager: EventDataManagerProtocol
    let eventNetworkManager: EventNetworkManagerProtocol
    let placeNetworkManager: PlaceNetworkManagerProtocol
    let errorManager: ErrorManagerProtocol
    
    @State private var selectedEvent: Event?
    @State private var showEvent: Bool = false
    
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
                    LazyVGrid(columns: gridLayout, spacing: 20) {
                        ForEach(todayEvents) { event in
                            Button {
                                selectedEvent = event
                                showEvent = true
                            } label: {
                                EventCell(event: event, showCountryCity: false, showStartDayInfo: true, showStartTimeInfo: false, width: (size.width / 2) - 30)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
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
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                    LazyVGrid(columns: gridLayout, spacing: 20) {
                        ForEach(displayedEvents) { event in
                            //                    NavigationLink {
                            //                        EventView(isEventViewPresented: <#T##Binding<Bool>#>, event: event, modelContext: modelContext, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, authenticationManager: authenticationManager)
                            //                    } label: {
//                            EventCell(event: event, width: (size.width / 2) - 30, modelContext: modelContext, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, showCountryCity: false, authenticationManager: authenticationManager, showStartDayInfo: true, showStartTimeInfo: false)
                            //  }
                                                        
                            Button {
                                selectedEvent = event
                                showEvent = true
                            } label: {
                                EventCell(event: event, showCountryCity: false, showStartDayInfo: true, showStartTimeInfo: false, width: (size.width / 2) - 30)
                            }
                            
                        }
                    }
                    .padding(.horizontal, 20)
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
            .fullScreenCover(item: $selectedEvent) {
                selectedEvent = nil
            } content: { event in
                EventView(event: event, modelContext: modelContext, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, authenticationManager: authenticationManager)
                   // .presentationDragIndicator(.visible)
                  //  .presentationDetents([.large])
                  //  .presentationBackground(.red)
                    .presentationCornerRadius(50)
            }
//            .sheet(item: $selectedEvent) {
//                selectedEvent = nil
//            } content: { event in
//                EventView(event: event, modelContext: modelContext, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, authenticationManager: authenticationManager)
//                                        .presentationDragIndicator(.hidden)
//                                        .presentationDetents([.large])
//                                        .presentationCornerRadius(25)
//            }

//            .sheet(isPresented: $showEvent) {
//                showEvent = false
//                selectedEvent = nil
//            } content: {
//                if let selectedEvent {
//                    EventView(isEventViewPresented: $showEvent, event: selectedEvent, modelContext: modelContext, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, authenticationManager: authenticationManager)
//                        .presentationDragIndicator(.hidden)
//                        .presentationDetents([.large])
//                        .presentationCornerRadius(25)
//                } else {
//                    EmptyView()
//                }
//            }
//            .navigationDestination(isPresented: $showEvent) {
//                if let selectedEvent {
//                    EventView(isEventViewPresented: $showEvent, event: selectedEvent, modelContext: modelContext, placeNetworkManager: placeNetworkManager, eventNetworkManager: eventNetworkManager, errorManager: errorManager, authenticationManager: authenticationManager)
//                } else {
//                    EmptyView()
//                }
//            }
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
