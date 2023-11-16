//
//  EditField.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 11.11.23.
//

import SwiftUI

struct EditField: View {
    
    @Binding var text: String
    
    private let title: String
    private let emptyFieldColor: Color
    
    init(title: String, text: Binding<String>, emptyFieldColor: Color) {
        _text = text
        self.title = title
        self.emptyFieldColor = emptyFieldColor
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.callout)
                    .foregroundStyle(text.isEmpty ? emptyFieldColor : .green)
                if !text.isEmpty {
                    Text(text)
                        .multilineTextAlignment(.leading)
                        .tint(.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            AppImages.iconRight
                .foregroundStyle(.quaternary)
        }
        .padding()
        .background(AppColors.lightGray6, in: RoundedRectangle(cornerRadius: 10))
        
    }
}

#Preview {
    EditField(title: "Address", text: .constant("Bla bla"), emptyFieldColor: .red)
}
