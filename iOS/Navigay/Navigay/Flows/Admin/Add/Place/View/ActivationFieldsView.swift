//
//  ActivationFieldsView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 01.11.23.
//

import SwiftUI

struct ActivationFieldsView: View {
    
    //MARK: - Properties
    
    @Binding var isActive: Bool
    @Binding var isChecked: Bool
    
    //MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            EditToggleField(toggle: $isActive, text: "Active")
                .padding(.bottom)
            EditToggleField(toggle: $isChecked, text: "Checked")
        }
    }
}

#Preview {
    ActivationFieldsView(isActive: .constant(false), isChecked: .constant(false))
}
