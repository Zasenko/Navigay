//
//  AddNewPlaceView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 19.10.23.
//

import SwiftUI

struct AddNewPlaceView: View {
    
    @State private var name: String = ""
    @State private var type: PlaceType = .other
    
    @State private var selectedTags: [Tag] = []
    @State private var showTagsView: Bool = false
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
                    showTagsView.toggle()
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
                TextField("Place name", text: $name)
            }
            
            Section("about") {
                TextField("Place name", text: $name)
            }
            
            Section("E-mail") {
                TextField("Place name", text: $name)
            }
            Section("Www page") {
                TextField("Place name", text: $name)
            }
            Section("Facebook") {
                TextField("Place name", text: $name)
            }
            Section("Instagram") {
                TextField("Place name", text: $name)
            }
            Section("Phone") {
                TextField("Place name", text: $name)
            }
            Section("Is active") {
                TextField("Place name", text: $name)
            }
            Section("Is checked") {
                TextField("Place name", text: $name)
            }
        }
    }
}

#Preview {
    AddNewPlaceView()
}

extension AddNewPlaceView {
    

    
}
