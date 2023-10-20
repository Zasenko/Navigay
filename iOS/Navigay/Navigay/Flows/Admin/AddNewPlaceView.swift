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
                
                TextField("Address", text: $name)
                TextField("Latitude", text: $name)
                TextField("Longitude", text: $name)
            }.listRowBackground(Color.pink)
            
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
            }
            .sheet(isPresented: $showTagsView) {
                AddTagsView(selectedTags: $selectedTags)
                    .padding(.top)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(25)
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
            }
            .sheet(isPresented: $showWorkDaysView) {
                AddWorkDaysView(workDays: $workDays)
                    .padding(.top)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(25)
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
