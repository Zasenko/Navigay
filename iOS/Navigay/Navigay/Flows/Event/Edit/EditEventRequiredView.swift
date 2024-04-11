//
//  EditEventRequiredView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 27.02.24.
//

import SwiftUI

//struct EditEventRequiredView: View {
//    
////MARK: - Properties
//@EnvironmentObject var vm: EditEventViewModel
////        var onSave: (String) -> Void
//
////MARK: - Private Properties
//
//@State private var isLoading: Bool = false
//@Environment(\.dismiss) private var dismiss
//
//    //MARK: - Body
//    
//    var body: some View {
//        NavigationStack {
//            VStack(alignment: .leading) {
//                Divider()
//                ScrollView {
//                 //   EventRequiredFieldsView(name: $vm.name, type: $vm.type, isoCountryCode: $vm.isoCountryCode, countryOrigin: $vm.countryOrigin, countryEnglish: $vm.cityEnglish, regionOrigin: $vm.regionOrigin, regionEnglish: $vm.regionEnglish, cityOrigin: $vm.cityOrigin, cityEnglish: $vm.cityEnglish, addressOrigin: $vm.address, latitude: $vm.latitude, longitude: $vm.longitude)
//                 //   EventTimeFieldsView(startDate: $vm.startDate, startTime: $vm.startTime, finishDate: $vm.finishDate, finishTime: $vm.finishTime)
//                    
//                    
////                    if let user = authManager.appUser, user.status == .admin {
////                        
////                        Text(viewModel.ownerId)
////                        Text(viewModel.placeId)
////                        //    let countryId: Int
////                        //   let regionId: Int?
////                        //   let cityId: Int?
////                        //   let latitude: Double?
////                        // let longitude: Double?
////                        
////                    }
//                }
//                .scrollIndicators(.hidden)
//            }
//            .navigationBarBackButtonHidden()
//            .toolbarBackground(AppColors.background)
//            .toolbarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                        Text("Required Information")
//                            .font(.headline.bold())
//                }
//                ToolbarItem(placement: .topBarLeading) {
//                    Button {
//                        dismiss()
//                    } label: {
//                        AppImages.iconLeft
//                            .bold()
//                            .frame(width: 30, height: 30, alignment: .leading)
//                    }
//                    .tint(.primary)
//                }
//                ToolbarItem(placement: .topBarTrailing) {
//                    if isLoading {
//                        ProgressView()
//                            .tint(.blue)
//                    } else {
//                        Button("Save") {
//                          //  update()
//                        }
//                        .bold()
//                     //   .disabled(text.isEmpty || text.count < 5)
//                    }
//                }
//            }
//        }
//    }
//    
////        func update() {
////            isLoading = true
////            Task {
////                let decodedResult = await networkManager.updateEventAbout(id: eventId, about: text)
////                await MainActor.run {
////                    isLoading = false
////                    if decodedResult {
////                        onSave(text)
////                        dismiss()
////                    }
////                }
////            }
////        }
//}

//#Preview {
//    EditEventRequiredView()
//}
