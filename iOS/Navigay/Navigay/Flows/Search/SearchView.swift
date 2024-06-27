//
//  SearchView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI

struct SearchView: View {
    
    // MARK: - PrivateProperties
    
    @State private var viewModel: SearchViewModel
    @EnvironmentObject private var authenticationManager: AuthenticationManager
    @FocusState private var focused: Bool
    //    @Namespace private var animation
    @Namespace private var animation

    // MARK: - Init
    
    init(viewModel: SearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                mainView
            }
            .background {
                ZStack(alignment: .center) {
                    Image("bg2")
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(CGSize(width: 2, height: 2))
                        .blur(radius: 100)
                        .saturation(3)
                    Rectangle()
                        .fill(.ultraThinMaterial)
                }
                .ignoresSafeArea()
                .opacity(focused ? 1 : 0)
                
            }
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Hunt for Locations and Events")
                            .foregroundStyle(.primary)
                            .bold()
                            .font(.headline)
                    }
            }
           // .toolbar(focused ? .hidden : .visible, for: .navigationBar)
            .onChange(of: viewModel.isSearching) { _, newValue in
                if newValue {
                    hideKeyboard()
                }
            }
            .onChange(of: viewModel.searchText, initial: false) { _, newValue in
                viewModel.textSubject.send(newValue.lowercased())
            }
            .fullScreenCover(item: $viewModel.selectedEvent) { event in
                EventView(viewModel: EventView.EventViewModel.init(event: event, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, commentsNetworkManager: viewModel.commentsNetworkManager, notificationsManager: viewModel.notificationsManager))
            }
            .animation(.default, value: focused)
        }
    }
    
    // MARK: - Views
    
    private var header: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    if viewModel.isSearching {
                        ProgressView()
                            .tint(.blue)
                            .frame(width: 40, height: 40)
                    } else {
                        AppImages.iconSearch
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .bold()
                            .frame(width: 40, height: 40)
                    }
                    TextField("Search...", text: $viewModel.searchText, onCommit: {
                        viewModel.search()
                    })
                   .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .focused($focused)
                    .submitLabel(.search)
                }
                .padding(.trailing, 10)
                .background(.ultraThickMaterial)
                .cornerRadius(16)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    focused = true
                }
                if focused {
                    Button("Cancel") {
                        focused = false
                        viewModel.searchText = ""
                    }
                    .bold()
                    .padding(.leading)
                    .transition(.move(edge: .trailing).combined(with: .opacity).animation(.default))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity)
            .animation(.default, value: viewModel.searchText.isEmpty)
            if !focused, !viewModel.categories.isEmpty {
                menuView
                    .transition(.move(edge: .top).combined(with: .opacity).animation(.default))
            }
        }
    }
    
    private var mainView: some View {
        GeometryReader { proxy in
            if focused || viewModel.searchText.count < 3 {
                List {
                    lastSearchResultsSection
                        .listRowBackground(Color.clear)
                    Color.clear
                        .frame(height: 50)
                        .listRowBackground(Color.clear)
                        .listSectionSeparator(.hidden)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .listSectionSeparator(.hidden)
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .buttonStyle(PlainButtonStyle())
                .onTapGesture {
                    focused = false
                }
                .transition(.move(edge: .bottom).combined(with: .opacity).animation(.default))
            } else {
                if viewModel.notFound {
                    List {
                        notFoundView
                        Color.clear
                            .frame(height: 50)
                            .listRowBackground(Color.clear)
                            .listSectionSeparator(.hidden)
                    }
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    .listSectionSeparator(.hidden)
                    .listStyle(.plain)
                    .scrollIndicators(.hidden)
                    .buttonStyle(PlainButtonStyle())
                }
                if !viewModel.categories.isEmpty {
                    tabView(size: proxy.size)
                }
            }
        }
    }
    
    private var lastSearchResultsSection: some View {
        Section {
            ForEach(viewModel.searchedKeys, id: \.self) { key in
                Button {
                    hideKeyboard()
                    viewModel.getSearchedResult(key: key)
                } label: {
                    HStack(alignment: .firstTextBaseline) {
                        AppImages.iconClock
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.primary)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(key)
                                .font(.body)
                                .bold()
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if let result = viewModel.catalogNetworkManager.loadedSearchText[key] {
                                HStack {
                                    if result.eventsCount == 0 && result.placeCount == 0 {
                                        Text("No results found")
                                    }  else {
                                        if result.eventsCount > 0 {
                                            Text(String(result.eventsCount))
                                            + Text(result.eventsCount > 1 ? " events" : " event")
                                        }
                                        if ((result.eventsCount > 0) && (result.placeCount > 0)) {
                                            Text("•")
                                        }
                                        if result.placeCount > 0 {
                                            Text(String(result.placeCount)) + Text(result.placeCount > 1 ? " places" : " place")
                                        }
                                    }
                                }
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        AppImages.iconArrowDownLeft
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
            }
        }
        .listSectionSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
        
    private var notFoundView: some View {
        Section {
            VStack {
                AppImages.iconSearchLocation
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .foregroundStyle(.secondary)
                    .padding()
                    .padding(.top)
                Group {
                    Text("Oops! No matches found.")
                        .font(.title2)
                    Text("Looks like our gay radar needs a caffeine boost! How about we try again?\n\nNavigay at your service!")
                        .font(.callout)
                }
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .textSelection(.enabled)
                .padding()
            }
            .listRowBackground(Color.clear)
            .frame(maxWidth: .infinity)
        }
        .listRowBackground(Color.clear)
        .listSectionSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    private var menuView: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [GridItem(.flexible(minimum: 100, maximum: 150))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, pinnedViews: []) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Button {
                                withAnimation(.easeIn) {
                                    viewModel.selectedCategory = category
                                }
                            } label: {
                                Text(category.getName())
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(.primary)
                                    .padding(5)
                                    .padding(.horizontal, 5)
                                    .background(viewModel.selectedCategory == category ? AppColors.lightGray6 : .clear)
                                    .clipShape(.capsule)
                            }
                            .padding(.leading)
                            .id(category)
                        }
                    }
                    .padding(.trailing)
                }
                .frame(height: 40)
                .onChange(of: viewModel.selectedCategory, initial: true) { oldValue, newValue in
                    withAnimation {
                        scrollProxy.scrollTo(newValue, anchor: .leading)
                    }
                }
            }
            Divider()
        }
    }
    
    private func tabView(size: CGSize) -> some View {
        TabView(selection: $viewModel.selectedCategory) {
            ForEach(viewModel.categories, id: \.self) { category in
                categoryView(category: category, size: size)
                    .tag(category)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(width: .infinity, height: .infinity)
    }
    
    private func categoryView(category: SortingCategory, size: CGSize) -> some View {
        List {
            switch category {
            case .events:
                eventsSection(size: size)
            default:
                placesSection(category: category)
            }
            Color.clear
                .frame(height: 50)
                .listSectionSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .listSectionSeparator(.hidden)
        .background(Color.clear)
        .listStyle(.plain)
        .buttonStyle(PlainButtonStyle())
    }
    
    private func eventsSection(size: CGSize) -> some View {
        ForEach(viewModel.searchEvents) { item in
            Section {
                Text("\(item.country.flagEmoji) \(item.country.name)")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.primary)
                    .offset(x: 70)
                    .padding(.vertical)
                    .listRowBackground(Color.clear)
                if item.events.count == 1 {
                    ForEach(item.events) { event in
                        Button {
                            viewModel.selectedEvent = event
                        } label: {
                            EventCell(event: event, showCountryCity: true, showStartDayInfo: true, showStartTimeInfo: false, showLike: true, showLocation: true)
                                .matchedGeometryEffect(id: "\(item.id)\(event.id)", in: animation)
                        }
                        .frame(maxWidth: size.width / 2)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                        .listRowBackground(Color.clear)
                    }
                } else {
                    StaggeredGrid(columns: 2, showsIndicators: false, spacing: 10, list: item.events) { event in
                        Button {
                            viewModel.selectedEvent = event
                        } label: {
                            EventCell(event: event, showCountryCity: true, showStartDayInfo: true, showStartTimeInfo: false, showLike: true, showLocation: true)
                                .matchedGeometryEffect(id: "\(item.id)\(event.id)", in: animation)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom)
                    .listRowBackground(Color.clear)
                }
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            .background(Color.clear)
            .listRowBackground(Color.clear)
            
        }
    }
    
    private func placesSection(category: SortingCategory) -> some View {
        ForEach(viewModel.searchPlaces) { typeItems in
            if typeItems.type == category {
                ForEach(viewModel.getPlaces(category: category)) { item in
                    
                    Section {
                        Text("\(item.country.flagEmoji) \(item.country.name)")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.primary)
                        // .offset(x: 70)
                            .padding(.vertical)
                            .listRowBackground(Color.clear)
                        ForEach(item.places) { place in
                            placeCell(place: place)
                                .listRowBackground(Color.clear)
                        }
                        
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowSeparator(.hidden)
                    .background(Color.clear)
                    .listRowBackground(Color.clear)
                    
                }
            }
        }
    }
    
    private func placeCell(place: Place) -> some View {
        NavigationLink(destination: PlaceView(viewModel: PlaceView.PlaceViewModel(
            place: place,
            modelContext: viewModel.modelContext,
            placeNetworkManager: viewModel.placeNetworkManager,
            eventNetworkManager: viewModel.eventNetworkManager,
            errorManager: viewModel.errorManager,
            placeDataManager: viewModel.placeDataManager,
            eventDataManager: viewModel.eventDataManager, 
            commentsNetworkManager: viewModel.commentsNetworkManager, 
            notificationsManager: viewModel.notificationsManager,
            showOpenInfo: false
        ))) {
            PlaceCell(
                place: place,
                showOpenInfo: false,
                showDistance: false,
                showCountryCity: true,
                showLike: true
            )
        }
    }
}
