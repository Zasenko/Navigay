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
            activationField
                .padding(.top)
                .padding(.vertical)
            checkField
                .padding(.bottom)
        }
        .padding(.horizontal)
        .padding(.horizontal)
    }
    
    //MARK: - Views
    
    private var activationField: some View {
        HStack {
            Text("Place is Active")
                .font(.callout)
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("", isOn: $isActive)
        }
    }
    private var checkField: some View {
        HStack {
            Text("Place is checked")
                .font(.callout)
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("", isOn: $isChecked)
        }
    }
}

#Preview {
    ActivationFieldsView(isActive: .constant(false), isChecked: .constant(false))
}
