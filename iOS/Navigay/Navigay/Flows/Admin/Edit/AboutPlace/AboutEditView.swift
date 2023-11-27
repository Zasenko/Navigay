//
//  AboutEditView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 15.11.23.
//

import SwiftUI

struct AboutEditView: View {
    
    //MARK: - Properties
    
    @Binding var languages: [Language]
    @Binding var about: [NewPlaceAbout]
    
    //MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("About")
                    .font(.callout)
                    .foregroundStyle(about.isEmpty ? Color.secondary : .green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !languages.isEmpty {
                    Menu("Add information") {
                        ForEach(languages, id: \.self) { language in
                            NavigationLink {
                                EditTextEditorView(title: "\(language.getFlag()) \(language.getName())", text: "", characterLimit: 3000) { string in
                                    let newPlaceAbout = NewPlaceAbout(language: language, about: string)
                                    self.about.append(newPlaceAbout)
                                    self.languages.removeAll(where: { $0 == newPlaceAbout.language})
                                }
                            } label: {
                                Text("\(language.getFlag()) \(language.getName())")
                            }
                        }
                    }
                }
            }
            .padding()
            VStack {
                ForEach(about.indices, id: \.self) { index in
                    let placeAbout = about[index]
                    HStack(spacing: 20) {
                        Button {
                            if let existingIndex = about.firstIndex(where: { $0.id == placeAbout.id }) {
                                let removedLanguage = about.remove(at: existingIndex).language
                                languages.append(removedLanguage)
                            }
                        } label: {
                            AppImages.iconTrash
                                .foregroundStyle(.red)
                                .padding(.leading)
                        }
                        NavigationLink {
                            EditTextEditorView(title: "\(placeAbout.language.getFlag()) \(placeAbout.language.getName())", text: placeAbout.about, characterLimit: 3000) { string in
                                if let existingIndex = self.about.firstIndex(where: { $0.id == placeAbout.id }) {
                                    let newPlaceAbout = NewPlaceAbout(language: placeAbout.language, about: string)
                                    self.about[existingIndex] = newPlaceAbout
                                }
                            }
                        } label: {
                            Text("\(placeAbout.language.getFlag()) \(placeAbout.about)")
                                .lineLimit(1)
                                .tint(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            AppImages.iconRight
                                .foregroundStyle(.quaternary)
                        }
                        .padding()
                        .background(AppColors.lightGray6, in: RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }
}
