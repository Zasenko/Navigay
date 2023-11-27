//
//  EventAdditionalFieldsView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.11.23.
//

import SwiftUI

struct EventAdditionalFieldsView: View {

    ///about?
    ///place_id?
    ///placeName?

    @Binding var languages: [Language]
    @Binding var about: [NewPlaceAbout]
    @Binding var tags: [Tag]
    @Binding var isoCountryCode: String
    @Binding var phone: String
    @Binding var email: String
    @Binding var www: String
    @Binding var facebook: String
    @Binding var instagram: String
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    AboutEditView(languages: $languages, about: $about)
                    TagsView
                    VStack(spacing: 0) {
                        NavigationLink {
                            EditEmailView(email: email) { email in
                                self.email = email.lowercased()
                            }
                        } label: {
                            EditField(title: "Email", text: $email, emptyFieldColor: .secondary)
                        }
                        Divider()
                            .padding(.horizontal)
                        NavigationLink {
                            EditPhoneView(isoCountryCode: isoCountryCode) { phone in
                                self.phone = phone
                            }
                        } label: {
                            EditField(title: "Phone", text: $phone, emptyFieldColor: .secondary)
                        }
                        Divider()
                            .padding(.horizontal)
                        NavigationLink {
                            EditTextFieldView(text: www, characterLimit: 100, minHaracters: 0, title: "Web page", placeholder: "www") { string in
                                www = string
                            }
                        } label: {
                            EditField(title: "www", text: $www, emptyFieldColor: .secondary)
                        }
                        Divider()
                            .padding(.horizontal)
                        NavigationLink {
                            EditTextFieldView(text: facebook, characterLimit: 50, minHaracters: 0, title: "Facebook", placeholder: "Facebook") { string in
                                facebook = string
                            }
                        } label: {
                            EditField(title: "Facebook", text: $facebook, emptyFieldColor: .secondary)
                        }
                        Divider()
                            .padding(.horizontal)
                        NavigationLink {
                            EditTextFieldView(text: instagram, characterLimit: 50, minHaracters: 0, title: "Instagram", placeholder: "Instagram") { instagram in
                                self.instagram = instagram
                            }
                        } label: {
                            EditField(title: "Instagram", text: $instagram, emptyFieldColor: .secondary)
                        }
                    }
                    .background(AppColors.lightGray6)
                    .cornerRadius(10)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal)
            
            }
        }
    }

    private var TagsView: some View {
        VStack {
            Text("Tags")
                .font(.callout)
                .foregroundStyle(tags.isEmpty ? Color.secondary : Color.green)
                .frame(maxWidth: .infinity, alignment: .leading)
            EditTagsView(tags: $tags)
            
        }
        .padding()
        .padding(.bottom, 40)
    }
}

#Preview {
    EventAdditionalFieldsView(languages: .constant([]), about: .constant([]), tags: .constant([]), isoCountryCode: .constant(""), phone: .constant(""), email: .constant(""), www: .constant(""), facebook: .constant(""), instagram: .constant(""))
}
