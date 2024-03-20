//
//  PlaceAdditionalFieldsView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 31.10.23.
//

import SwiftUI

struct PlaceAdditionalFieldsView: View {
    
    //MARK: - Properties
    
    //@ObservedObject var viewModel: AddNewPlaceViewModel
    @Binding var isoCountryCode: String
    @Binding var email: String
    @Binding var phone: String
    @Binding var www: String
    @Binding var facebook: String
    @Binding var instagram: String
    @Binding var about: String
    @Binding var timetable: [NewWorkingDay]
    @Binding var otherInfo: String
    @Binding var tags: [Tag]
    //MARK: - Body
    
    var body: some View {
        NavigationStack {

                LazyVStack(spacing: 0) {
                    VStack(spacing: 0) {
                        NavigationLink {
                            EditEmailView(email: email) { string in
                                email = string.lowercased()
                            }
                        } label: {
                            EditField(title: "Email", text: $email, emptyFieldColor: .secondary)
                        }
                        Divider()
                            .padding(.horizontal)
                        NavigationLink {
                            EditPhoneView(isoCountryCode: isoCountryCode) { string in
                                phone = string
                            }
                        } label: {
                            EditField(title: "Phone", text: $phone, emptyFieldColor: .secondary)
                        }
                        Divider()
                            .padding(.horizontal)
                        NavigationLink {
                            EditTextFieldView(text: www, characterLimit: 255, minHaracters: 0, title: "Web page", placeholder: "www") { string in
                                www = string
                            }
                        } label: {
                            EditField(title: "www", text: $www, emptyFieldColor: .secondary)
                        }
                        Divider()
                            .padding(.horizontal)
                        NavigationLink {
                            EditTextFieldView(text: facebook, characterLimit: 255, minHaracters: 0, title: "Facebook", placeholder: "Facebook") { string in
                                facebook = string
                            }
                        } label: {
                            EditField(title: "Facebook", text: $facebook, emptyFieldColor: .secondary)
                        }
                        Divider()
                            .padding(.horizontal)
                        NavigationLink {
                            EditTextFieldView(text: instagram, characterLimit: 255, minHaracters: 0, title: "Instagram", placeholder: "Instagram") { string in
                                instagram = string
                            }
                        } label: {
                            EditField(title: "Instagram", text: $instagram, emptyFieldColor: .secondary)
                        }
                    }
                    .background(AppColors.lightGray6)
                    .cornerRadius(10)
                    .padding(.bottom, 40)

                    NavigationLink {
                        EditTextEditorView(title: "About", text: about, characterLimit: 3000, onSave: { string in
                            about = string
                        })
                    } label: {
                        EditField(title: "About", text: $about, emptyFieldColor: .secondary)
                    }
                    
                    tagsView
                    
                    NavigationLink {
                        EditTimetableView(timetable: timetable) { newTimetable in
                            timetable = newTimetable
                        }
                    } label: {
                        timetableView
                    }
                    if !timetable.isEmpty {
                        workdays
                    }
                    
                    NavigationLink {
                        EditTextEditorView(title: "Other information", text: otherInfo, characterLimit: 255) { string in
                            otherInfo = string
                        }
                    } label: {
                        EditField(title: "Other information", text: $otherInfo, emptyFieldColor: .secondary)
                            .padding(.bottom, 40)
                            .padding(.top, 40)
                    }
                }
                .padding(.horizontal)
        }
    }
    
    //MARK: - Views

    private var tagsView: some View {
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
    
    private var timetableView: some View {
        HStack {
                Text("Timetable")
                    .font(.callout)
                    .foregroundStyle(timetable.isEmpty ? Color.secondary : Color.green)

            .frame(maxWidth: .infinity, alignment: .leading)
            AppImages.iconRight
                .foregroundStyle(.quaternary)
        }
        .padding()
        .background(AppColors.lightGray6, in: RoundedRectangle(cornerRadius: 10))
    }
    
    private var workdays: some View {
        VStack(spacing: 10) {
            ForEach(timetable) { day in
                HStack {
                    Text(day.day.getString())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(day.opening.formatted(date: .omitted, time: .shortened))
                    Text("—")
                    Text(day.closing.formatted(date: .omitted, time: .shortened))
                }
            }
        }
        .padding()
        .padding(.bottom)
    }
}

//#Preview {
//    let decodetUser = DecodedAppUser(id: 0, name: "Test", email: "test@test.com", status: .admin, bio: nil, photo: nil, instagram: nil, likedPlacesId: nil)
//    let user = AppUser(decodedUser: decodetUser)
//    let errorManager = ErrorManager()
//    let appSettingsManager = AppSettingsManager()
//    let networkManage = PlaceNetworkManager(appSettingsManager: appSettingsManager)
//    return PlaceAdditionalFieldsView(viewModel: AddNewPlaceViewModel(user: user, networkManager: networkManage, errorManager: errorManager))
//}
