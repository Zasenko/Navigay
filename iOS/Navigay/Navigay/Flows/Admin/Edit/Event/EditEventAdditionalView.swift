//
//  EditEventAdditionalView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 27.02.24.
//

import SwiftUI

struct EditEventAdditionalView: View {
        
    //MARK: - Properties
    @EnvironmentObject var vm: EditEventViewModel
    //        var onSave: (String) -> Void

    //MARK: - Private Properties
    
    @State private var isLoading: Bool = false
    @Environment(\.dismiss) private var dismiss

        //MARK: - Body
        
        var body: some View {
            NavigationStack {
                VStack(alignment: .leading) {
                    Divider()
                    ScrollView {
//                        EventFeeFieldsView(isFree: $vm.isFree, fee: $vm.fee, tickets: $vm.tickets)
//                        EventAdditionalFieldsView(tags: $vm.tags, isoCountryCode: $vm.isoCountryCode, phone: $vm.phone, email: $vm.email, www: $vm.www, facebook: $vm.facebook, instagram: $vm.instagram)
                    }
                    .scrollIndicators(.hidden)
                }
                .navigationBarBackButtonHidden()
                .toolbarBackground(AppColors.background)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                            Text("Additional Information")
                                .font(.headline.bold())
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            AppImages.iconLeft
                                .bold()
                                .frame(width: 30, height: 30, alignment: .leading)
                        }
                        .tint(.primary)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        if isLoading {
                            ProgressView()
                                .tint(.blue)
                        } else {
                            Button("Save") {
                              //  update()
                            }
                            .bold()
                         //   .disabled(text.isEmpty || text.count < 5)
                            .disabled(isLoading)
                        }
                    }
                }
            }
        }
        
//        func update() {
//            isLoading = true
//            Task {
//                let decodedResult = await networkManager.updateEventAbout(id: eventId, about: text)
//                await MainActor.run {
//                    isLoading = false
//                    if decodedResult {
//                        onSave(text)
//                        dismiss()
//                    }
//                }
//            }
//        }
    }
//#Preview {
//    EditEventAdditionalView(startDate: .constant(.now), startTime: .constant(.now), finishDate: .constant(.now), finishTime: .constant(.now))
//}
