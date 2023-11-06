//
//  AdminView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 19.10.23.
//

import SwiftUI



struct AdminView: View {

    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Add new place") {
                        AddNewPlaceView()
                    }
                    NavigationLink("Add new event") {
                        Color.red
                    }
                }
            }
            .navigationTitle("Admin panel")
        }
    }
}

#Preview {
    AdminView()
}
