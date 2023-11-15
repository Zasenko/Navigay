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
                                AddAboutPlaceView(language: language, text: "") { placeAbout in
                                    about.append(placeAbout)
                                    languages.removeAll(where: { $0 == placeAbout.language})
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
                    let info = about[index]
                    HStack(spacing: 20) {
                        Button {
                            if let existingIndex = about.firstIndex(where: { $0.id == info.id }) {
                                let removedLanguage = about.remove(at: existingIndex).language
                                languages.append(removedLanguage)
                            }
                        } label: {
                            AppImages.iconTrash
                                .foregroundStyle(.red)
                                .padding(.leading)
                        }
                        NavigationLink {
                            AddAboutPlaceView(language: info.language, text: info.about) { placeAbout in
                                if let existingIndex = about.firstIndex(where: { $0.id == info.id }) {
                                    about[existingIndex] = placeAbout
                                }
                            }
                        } label: {
                            Text("\(info.language.getFlag()) \(info.about)")
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
