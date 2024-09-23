//
//  OrganizerView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 22.09.24.
//

import SwiftUI

import SwiftUI
import SwiftData

//TODO: сообщить об ошибке (место закрыто, неправильная информация)
// рейтинг заведения

struct OrganizerView: View {
    
    // MARK: - Private Properties
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: OrganizerViewModel
    
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Init
    
    init(viewModel: OrganizerViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
        
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                listView
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.showHeaderTitle {
                    ToolbarItem(placement: .principal) {
                        Text(viewModel.organizer.name)
                                .font(.headline).bold()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation {
                            dismiss()
                        }
                    } label: {
                        AppImages.iconLeft
                            .bold()
                            .frame(width: 30, height: 30, alignment: .leading)
                    }
                    .tint(.primary)
                }
//                ToolbarItem(placement: .topBarTrailing) {
//                    HStack {
//                        Button  label: {
//                            Image(systemName: viewModel.place.isLiked ? "heart.fill" : "heart")
//                                .bold()
//                                .frame(width: 30, height: 30, alignment: .leading)
//                        }
//                        .tint(.red)
//                        if let user = authenticationManager.appUser, (user.status == .admin || user.status == .moderator) {
//                            Menu {
//                                NavigationLink("Edit Place") {
//                                    EditPlaceView(viewModel: EditPlaceViewModel(id: viewModel.place.id, place: viewModel.place, user: user, networkManager: EditPlaceNetworkManager(networkManager: authenticationManager.networkManager), errorManager: viewModel.errorManager))
//                                }
//                                NavigationLink("Add Event") {
//                                    NewEventView(viewModel: NewEventViewModel(user: user, place: viewModel.place, copy: nil, networkManager: EditEventNetworkManager(networkManager: authenticationManager.networkManager), errorManager: viewModel.errorManager))
//                                }
//                            } label: {
//                                AppImages.iconSettings
//                                    .bold()
//                                    .foregroundStyle(.blue)
//                            }
//                        }
//                    }
//                }
            }
            .onAppear() {
                viewModel.getEventsFromDB()
            }
            .onChange(of: viewModel.selectedDate, initial: false) { oldValue, newValue in
                viewModel.showCalendar = false
                if let date = newValue {
                    viewModel.getEvents(for: date)
                } else {
                    viewModel.showUpcomingEvents()
                }
            }
            .sheet(isPresented:  $viewModel.showCalendar) {} content: {
                CalendarView(selectedDate: $viewModel.selectedDate, eventsDates: $viewModel.eventsDates)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(25)
            }
//            .sheet(isPresented: $viewModel.showAddCommentView) {
//                AddCommentView(viewModel: AddCommentViewModel(placeId: viewModel.place.id, networkManager: viewModel.commentsNetworkManager, errorManager: viewModel.errorManager))
//            }
            .fullScreenCover(item: $viewModel.selectedEvent) { event in
                EventView(viewModel: EventView.EventViewModel.init(event: event, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, commentsNetworkManager: viewModel.commentsNetworkManager, notificationsManager: viewModel.notificationsManager))
            }
            .fullScreenCover(isPresented: $viewModel.showLoginView) {
                LoginView(viewModel: LoginViewModel(isPresented: $viewModel.showLoginView))
            }
            .fullScreenCover(isPresented: $viewModel.showRegistrationView) {
                RegistrationView(viewModel: RegistrationViewModel(isPresented: $viewModel.showRegistrationView))
            }
        }
    }
    
    // MARK: - Views
    
    private var listView: some View {
        GeometryReader { proxy in
            ScrollViewReader { scrollProxy in
                List {
                    headerView
                    headerSection(width: proxy.size.width)
                    
                    Text("Information")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 50)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    
                    if let otherInfo = viewModel.organizer.otherInfo {
                        Text(otherInfo)
                            .foregroundStyle(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 50, trailing: 20))
                            .listSectionSeparator(.hidden)
                    }
                    
                    ContactInfoView(phone: $viewModel.organizer.phone, www: $viewModel.organizer.www, facebook: $viewModel.organizer.facebook, instagram: $viewModel.organizer.instagram)
                        .listRowInsets(EdgeInsets(top: 50, leading: 20, bottom: 50, trailing: 20))
                        .listSectionSeparator(.hidden)
                    
                    if viewModel.eventsCount > 0 {
                        EventsView(modelContext: viewModel.modelContext, selectedDate: $viewModel.selectedDate, displayedEvents: $viewModel.displayedEvents, eventsCount: $viewModel.eventsCount, todayEvents: $viewModel.todayEvents, upcomingEvents: $viewModel.upcomingEvents, eventsDates: $viewModel.eventsDates, selectedEvent: $viewModel.selectedEvent, showCalendar: $viewModel.showCalendar, size: proxy.size, showLocation: false)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    
                    if let about = viewModel.organizer.about {
                        Text(about)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 50, leading: 20, bottom: 50, trailing: 20))
                    }
                    
                    if viewModel.organizer.photos.count > 0 {
                        //todo фотографии должны открываться
                        LazyVGrid(columns: viewModel.gridLayoutPhotos, spacing: 2) {
                            ForEach(viewModel.organizer.photos, id: \.self) { url in
                                ImageLoadingView(url: url, width: (proxy.size.width - 4) / 3, height: (proxy.size.width - 4) / 3, contentMode: .fill) {
                                    AppColors.lightGray6 //TODO animation
                                }
                                .clipped()
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 50, leading: 0, bottom: 50, trailing: 0))
                    }
//                    CommentsView(comments: $viewModel.comments, isLoading: $viewModel.isCommentsLoading, showAddReviewView: $viewModel.showAddCommentView, showRegistrationView: $viewModel.showRegistrationView, showLoginView: $viewModel.showLoginView, size: proxy.size, place: viewModel.place, errorManager: viewModel.errorManager, deleteComment: { id in
//                        viewModel.deleteComment(id: id)
//                    })
//                        .listRowSeparator(.hidden)
//                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                        .onAppear {
//                            viewModel.fetchComments()
//                        }
                    Color.clear
                        .frame(height: 50)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .buttonStyle(PlainButtonStyle())
                .onChange(of: viewModel.selectedDate, initial: false) { oldValue, newValue in
                    withAnimation {
                        scrollProxy.scrollTo("UpcomingEvents", anchor: .top)
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 20) {
            if let url = viewModel.organizer.avatarUrl {
                ImageLoadingView(url: url, width: 50, height: 50, contentMode: .fill) {
                    ImageFetchingView()
                }
                .clipShape(Circle())
                .overlay(Circle().stroke(AppColors.lightGray5, lineWidth: 1))
                .padding(8)
            }
            Text(viewModel.organizer.name)
                .font(.title2).bold()
                .foregroundColor(.primary)
                .baselineOffset(0)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .onAppear {
            viewModel.showHeaderTitle = false
        }
        .onDisappear {
            viewModel.showHeaderTitle = true
        }
    }
    
    @ViewBuilder
    private func headerSection(width: CGFloat) -> some View {
        ZStack {
            if !viewModel.allPhotos.isEmpty {
                PhotosTabView(allPhotos: $viewModel.allPhotos, width: width)
                    .frame(width: width, height: ((width / 4) * 5) + 20)///20 is spase after tabview for circls
            }
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}
//
//#Preview {
//    OrganizerView()
//}
