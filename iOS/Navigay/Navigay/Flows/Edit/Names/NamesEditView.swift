//
//  NamesEditView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 15.11.23.
//

import SwiftUI

struct NamesEditView: View {
    
    //MARK: - Properties
    
    @Binding var nameOrigin: String
    @Binding var nameEn: String
    
    //MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            EditField(title: "🏳️‍🌈 Original name", text: $nameOrigin, emptyFieldColor: .red)
            Divider()
                .padding(.horizontal)
            NavigationLink {
                EditTextFieldView(text: nameEn, characterLimit: 30, minHaracters: 2, title: "🇬🇧 English name", placeholder: "Name") { string in
                    nameEn = string
                }
            } label: {
                EditField(title: "🇬🇧 English name", text: $nameEn, emptyFieldColor: .red)
            }
        }
        .background(AppColors.lightGray6)
        .cornerRadius(10)
    }
}
