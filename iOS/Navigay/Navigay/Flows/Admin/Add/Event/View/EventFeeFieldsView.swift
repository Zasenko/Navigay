//
//  EventFeeFieldsView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.11.23.
//

import SwiftUI

struct EventFeeFieldsView: View {
    
    @Binding var isFree: Bool
    @Binding var fee: String
    @Binding var tickets: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                IsFreeView
                    .padding(.bottom)
                if !isFree {
                    VStack(spacing: 0) {
                        NavigationLink {
                            EditTextFieldView(text: fee, characterLimit: 255, minHaracters: 0, title: "Fee information", placeholder: "Fee information") { fee in
                                self.fee = fee
                            }
                        } label: {
                            EditField(title: "Fee information", text: $fee, emptyFieldColor: .secondary)
                        }
                        Divider()
                            .padding(.horizontal)
                        NavigationLink {
                            EditTextFieldView(text: tickets, characterLimit: 255, minHaracters: 0, title: "Tickets", placeholder: "Link") { tickets in
                                self.tickets = tickets
                            }
                        } label: {
                            EditField(title: "Link to tickets", text: $tickets, emptyFieldColor: .secondary)
                        }
                    }
                    .background(AppColors.lightGray6)
                    .cornerRadius(10)
                }
                
                
            }
            .padding(.horizontal)
        }
    }
    
    private var IsFreeView: some View {
        HStack {
            Text("Is this a event free?")
                .font(.callout)
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("", isOn: $isFree)
        }
        .padding(.horizontal)
    }
}

#Preview {
    EventFeeFieldsView(isFree: .constant(false), fee: .constant(""), tickets: .constant(""))
}
