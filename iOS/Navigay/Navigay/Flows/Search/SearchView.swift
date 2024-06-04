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
        //    .toolbar(.hidden, for: .navigationBar)
            .onChange(of: viewModel.isSearching) { _, newValue in
                if newValue {
                    hideKeyboard()
                }
            }
            .onChange(of: viewModel.searchText, initial: false) { _, newValue in
                viewModel.notFound = false
                viewModel.textSubject.send(newValue.lowercased())
            }
            .fullScreenCover(item: $viewModel.selectedEvent) { event in
                EventView(viewModel: EventView.EventViewModel.init(event: event, modelContext: viewModel.modelContext, placeNetworkManager: viewModel.placeNetworkManager, eventNetworkManager: viewModel.eventNetworkManager, errorManager: viewModel.errorManager, placeDataManager: viewModel.placeDataManager, eventDataManager: viewModel.eventDataManager, commentsNetworkManager: viewModel.commentsNetworkManager))
            }
            .animation(.easeInOut, value: focused)
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
                    TextField("Search...", text: $viewModel.searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .focused($focused)
                }
                .padding(.trailing, 10)
                .background(AppColors.lightGray6)
                .cornerRadius(16)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    focused = true
                }
                if focused {
                    Button("Cancel") {
                        focused = false
                    }
                    .padding(.leading)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity)
            .animation(.interactiveSpring, value: viewModel.searchText.isEmpty)
            if !focused {
                menuView
            }
        }
    }
    
    private var mainView: some View {
        GeometryReader { proxy in
            ZStack {
                if focused || viewModel.searchText.isEmpty {
                    List {
                        lastSearchResultsView
                            .listRowBackground(Color.clear)
                    }
                    .scrollContentBackground(.hidden)
                    .listSectionSeparator(.hidden)
                    .listStyle(.plain)
                    .scrollIndicators(.hidden)
                    .buttonStyle(PlainButtonStyle())
                    .onTapGesture {
                        focused = false
                    }
                } else {
                    if viewModel.notFound {
                        List {
                            notFoundView
                        }
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
    }
    
    private var lastSearchResultsView: some View {
        Section {
            ForEach(viewModel.catalogNetworkManager.loadedSearchText.keys.uniqued(), id: \.self) { key in
                Button {
                    hideKeyboard()
                    viewModel.searchText = key
                    viewModel.search(text: key)
                } label: {
                    HStack(alignment: .firstTextBaseline) {
                        AppImages.iconArrowUpRight
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.blue)
                        Text(key)
                            .font(.body)
                            .padding(.vertical)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
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
            .frame(maxWidth: .infinity)
        }
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
    
    func categoryView(category: SortingCategory, size: CGSize) -> some View {
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
        }
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .listSectionSeparator(.hidden)
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
                if item.events.count == 1 {
                    ForEach(item.events) { event in
                        Button {
                            viewModel.selectedEvent = event
                        } label: {
                            EventCell(event: event, showCountryCity: true, showStartDayInfo: true, showStartTimeInfo: false)
                                .matchedGeometryEffect(id: "\(item.id)\(event.id)", in: animation)
                        }
                        .frame(maxWidth: size.width / 2)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                    }
                } else {
                    StaggeredGrid(columns: 2, showsIndicators: false, spacing: 10, list: item.events) { event in
                        Button {
                            viewModel.selectedEvent = event
                        } label: {
                            EventCell(event: event, showCountryCity: true, showStartDayInfo: true, showStartTimeInfo: false)
                                .matchedGeometryEffect(id: "\(item.id)\(event.id)", in: animation)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom)
                    
                }
            }
            
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            
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
                        ForEach(item.places) { place in
                            placeCell(place: place)
                        }
                        
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowSeparator(.hidden)
                    
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
