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
    @Binding var nameFr: String
    @Binding var nameDe: String
    @Binding var nameRu: String
    @Binding var nameIt: String
    @Binding var nameEs: String
    @Binding var namePt: String
    
    //MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationLink {
                EditTextFieldView(text: nameOrigin, characterLimit: 30, minHaracters: 2, title: "🏳️‍🌈 Original name", placeholder: "Name") { string in
                    nameOrigin = string
                }
            } label: {
                EditField(title: "🏳️‍🌈 Original name", text: $nameOrigin, emptyFieldColor: .red)
            }
            Divider()
                .padding(.horizontal)
            NavigationLink {
                EditTextFieldView(text: nameEn, characterLimit: 30, minHaracters: 2, title: "🇬🇧 English name", placeholder: "Name") { string in
                    nameEn = string
                }
            } label: {
                EditField(title: "🇬🇧 English name", text: $nameEn, emptyFieldColor: .red)
            }
            Divider()
                .padding(.horizontal)
            NavigationLink {
                EditTextFieldView(text: nameFr, characterLimit: 30, minHaracters: 2, title: "🇫🇷 Français name", placeholder: "Name") { string in
                    nameFr = string
                }
            } label: {
                EditField(title: "🇫🇷 Français name", text: $nameFr, emptyFieldColor: .red)
            }
            Divider()
                .padding(.horizontal)
            NavigationLink {
                EditTextFieldView(text: nameDe, characterLimit: 30, minHaracters: 2, title: "🇩🇪 Deutsch name", placeholder: "Name") { string in
                    nameDe = string
                }
            } label: {
                EditField(title: "🇩🇪 Deutsch name", text: $nameDe, emptyFieldColor: .red)
            }
            Divider()
                .padding(.horizontal)
            NavigationLink {
                EditTextFieldView(text: nameRu, characterLimit: 30, minHaracters: 2, title: "🇷🇺 Русский name", placeholder: "Name") { string in
                    nameRu = string
                }
            } label: {
                EditField(title: "🇷🇺 Русский name", text: $nameRu, emptyFieldColor: .red)
            }
            Divider()
                .padding(.horizontal)
            NavigationLink {
                EditTextFieldView(text: nameIt, characterLimit: 30, minHaracters: 2, title: "🇮🇹 Italiano name", placeholder: "Name") { string in
                    nameIt = string
                }
            } label: {
                EditField(title: "🇮🇹 Italiano name", text: $nameIt, emptyFieldColor: .red)
            }
            Divider()
                .padding(.horizontal)
            NavigationLink {
                EditTextFieldView(text: nameEs, characterLimit: 30, minHaracters: 2, title: "🇪🇸 Español name", placeholder: "Name") { string in
                    nameEs = string
                }
            } label: {
                EditField(title: "🇪🇸 Español name", text: $nameEs, emptyFieldColor: .red)
            }
            Divider()
                .padding(.horizontal)
            NavigationLink {
                EditTextFieldView(text: namePt, characterLimit: 30, minHaracters: 2, title: "🇵🇹 Português name", placeholder: "Name") { string in
                    namePt = string
                }
            } label: {
                EditField(title: "🇵🇹 Português name", text: $namePt, emptyFieldColor: .red)
            }
        }
        .background(AppColors.lightGray6)
        .cornerRadius(10)
    }
}
