//
//  EditToggleField.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.11.23.
//

import SwiftUI

struct EditToggleField: View {
    
    //MARK: - Properties
    
    @Binding var toggle: Bool
    
    //MARK: - Private Properties
    
    private let text: String
    
    //MARK: - Inits
    
    init(toggle: Binding<Bool>, text: String) {
        _toggle = toggle
        self.text = text
    }
    
    //MARK: - Body
    var body: some View {
        HStack {
            Text(text)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("", isOn: $toggle)
        }
        .padding(.horizontal)
        .padding(.horizontal)
    }
}

#Preview {
    EditToggleField(toggle: .constant(true), text: "Example")
}
