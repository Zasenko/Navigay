//
//  AddNewPlaceView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 19.10.23.
//

import SwiftUI

struct AddNewPlaceView: View {
    
    //MARK: - Private Properties
    
    @State private var name: String = ""
    @State private var type: PlaceType = .other
    
    @State private var isoCountryCode: String = ""
    @State private var countryOrigin: String = ""
    @State private var countryEnglish: String = ""
    @State private var regionOrigin: String = ""
    @State private var regionEnglish: String = ""
    @State private var cityOrigin: String = ""
    @State private var cityEnglish: String = ""
    @State private var addressOrigin: String = ""
    @State private var latitude: Double = 0
    @State private var longitude: Double = 0
    @State private var showMap: Bool = false
    
    @State private var selectedTags: [Tag] = []
    @State private var showTagsView: Bool = false
    
    @State private var workDays: [NewWorkingDay] = []
    @State private var showWorkDaysView: Bool = false
    
    @State private var email: String = ""
    @State private var www: String = ""
    @State private var facebook: String = ""
    @State private var instagram: String = ""
    
    @State private var isActive: Bool = false
    @State private var isChecked: Bool = false
    
    //MARK: - Body
    
    var body: some View {
        
        List {
            Section("Required fields") {
                TextField("Place name", text: $name)
                Picker("Place type", selection: $type) {
                    ForEach(PlaceType.allCases, id: \.self) { type in
                        Text("\(type.getImage()) \(type.getName())")
                    }
                }
                .pickerStyle(.menu)
            }.listRowBackground(Color.green)
            
            Section("Required fields") {
                Button {
                    showMap = true
                } label: {
                    Text("Search on map")
                }
                .fullScreenCover(isPresented: $showMap) {
                    AddLocationView(isoCountryCode: $isoCountryCode, countryOrigin: $countryOrigin, countryEnglish: $countryEnglish, regionOrigin: $regionOrigin, regionEnglish: $regionEnglish, cityOrigin: $cityOrigin, cityEnglish: $cityEnglish, addressOrigin: $addressOrigin, latitude: $latitude, longitude: $longitude)
                }
                Text("isoCountryCode: ").foregroundStyle(.secondary) + Text(String(isoCountryCode))
                Text("countryOrigin: ").foregroundStyle(.secondary) + Text(String(countryOrigin))
                Text("countryEnglish: ").foregroundStyle(.secondary) + Text(String(countryEnglish))
                Text("regionOrigin: ").foregroundStyle(.secondary) + Text(String(regionOrigin))
                Text("regionEnglish: ").foregroundStyle(.secondary) + Text(String(regionEnglish))
                Text("cityOrigin: ").foregroundStyle(.secondary) + Text(String(cityOrigin))
                Text("cityEnglish: ").foregroundStyle(.secondary) + Text(String(cityEnglish))
                Text("Address: ").foregroundStyle(.secondary) + Text(String(addressOrigin))
                Text("Latitude: ").foregroundStyle(.secondary) + Text(String(latitude))
                Text("Longitude: ").foregroundStyle(.secondary) + Text(String(longitude))
            }.listRowBackground(Color.green)
            
            Section("Photo") {
                TextField("Place name", text: $name)
            }
            
            Section("Tags") {
                if selectedTags.count > 0 {
                    LazyVStack {
                        ForEach(selectedTags, id: \.self) { tag in
                            Text(tag.getString())
                                .font(.caption)
                                .bold()
                                .foregroundColor(.white)
                                .modifier(CapsuleSmall(background: .red))
                        }
                    }
                }
                Button {
                    showTagsView = true
                } label: {
                    Text("+ Add tags")
                }
                .sheet(isPresented: $showTagsView) {
                    AddTagsView(selectedTags: $selectedTags)
                        .padding(.top)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(25)
                }
            }
            
            Section("Working time") {
                if workDays.count > 0 {
                    ForEach(workDays, id: \.self) { day in
                        HStack {
                            Text(day.day.getString())
                                .font(.caption)
                                .bold()
                                .foregroundColor(.white)
                                .modifier(CapsuleSmall(background: .red))
                            Text(day.opening.formatted(date: .omitted, time: .shortened))
                            Text("—")
                            Text(day.closing.formatted(date: .omitted, time: .shortened))
                        }
                    }
                }
                Button {
                    showWorkDaysView = true
                } label: {
                    Text(workDays.count > 0 ? "Change" : "+ Add work days")
                }
                .sheet(isPresented: $showWorkDaysView) {
                    AddWorkDaysView(workDays: $workDays)
                        .padding(.top)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(25)
                }
            }
            
            Section("about") {
                TextField("Place name", text: $name)
            }
            
            Section("E-mail") {
                TextField("E-mail", text: $email)
            }
            Section("Phone") {
                TextField("Place name", text: $name)
            }
            Section("Other information") {
                TextField("www", text: $www)
                TextField("Facebook", text: $facebook)
                TextField("Instagram", text: $instagram)
            }
            
            Section("Is active") {
                Toggle("Is active", isOn: $isActive)
                Toggle("Is checked", isOn: $isChecked)
            }
            
            Section("") {
                Button("Create") {
                    
                }
                .buttonStyle(.bordered)
            }
        }
        .listSectionSpacing(0)
    }
}

#Preview {
    AddNewPlaceView()
}
