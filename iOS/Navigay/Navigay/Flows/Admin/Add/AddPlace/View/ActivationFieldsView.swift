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
            active
                .padding(.top)
                .padding(.vertical)
            check
                .padding(.bottom)
        }
        .padding(.horizontal)
    }
    
    //MARK: - Views
    
    private var active: some View {
        HStack {
            Text("Active".uppercased())
                .font(.caption)
                .bold()
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("", isOn: $isActive)
        }
        
    }
    private var check: some View {
        HStack {
            Text("Check".uppercased())
                .font(.caption)
                .bold()
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("", isOn: $isChecked)
        }
    }
}

#Preview {
    ActivationFieldsView(isActive: .constant(false), isChecked: .constant(false))
}
