//
//  EditPhoneView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 25.10.23.
//

import SwiftUI
import Combine

struct EditPhoneView: View {
    
    //MARK: - Properties
    
    var onSave: (String) -> Void
    
    //MARK: - Private Properties
    
    private let title: String = "Phone number"
    private let info: String = "Confirm country code and enter phone number."
    private let placeholder: String = "Phone number"
    private let counrties: [CPData] = Bundle.main.decode("CountryNumbers.json")
    @State private var countryCode: String
    @State private var countryFlag: String
    @State private var mobPhoneNumber: String = ""
    @State private var presentSheet: Bool = false
    @State private var searchCountry: String = ""
    private var filteredResorts: [CPData] {
        if searchCountry.isEmpty {
            return counrties
        } else {
            return counrties.filter { $0.name.contains(searchCountry) }
        }
    }
    @FocusState private var keyIsFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - Inits
    
    init(isoCountryCode: String?, onSave: @escaping (String) -> Void) {
        self.onSave = onSave
        if let isoCountryCode,
           !isoCountryCode.isEmpty,
           let country = counrties.first(where: { $0.code == isoCountryCode} ) {
            _countryFlag = State(initialValue: country.flag)
            _countryCode = State(initialValue: country.dial_code)
        } else {
            _countryFlag = State(initialValue: "🇺🇸")
            _countryCode = State(initialValue: "+1")
        }
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                Text(info)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                HStack(spacing: 10) {
                    Button {
                        keyIsFocused = false
                        presentSheet = true
                    } label: {
                        Text("\(countryFlag) \(countryCode)")
                            .foregroundColor(.primary)
                            .padding(10)
                            .background(AppColors.lightGray6, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    TextField(placeholder, text: $mobPhoneNumber)
                        .focused($keyIsFocused)
                        .keyboardType(.numberPad)
                        .padding(10)
                        .background(AppColors.lightGray6, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .padding(.horizontal)
                Spacer()
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
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
                    Button("Готово") {
                        onSave(mobPhoneNumber.isEmpty ? "" : "\(countryCode) \(mobPhoneNumber)")
                        dismiss()
                    }
                    .bold()
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .sheet(isPresented: $presentSheet) {
                NavigationView {
                    List(filteredResorts) { country in
                        HStack {
                            Text(country.flag)
                            Text(country.name)
                            Spacer()
                            Text(country.dial_code)
                                .foregroundColor(.secondary)
                        }
                        .onTapGesture {
                            searchCountry = ""
                            countryFlag = country.flag
                            countryCode = country.dial_code
                            presentSheet = false
                        }
                    }
                    .listStyle(.plain)
                    .navigationBarTitleDisplayMode(.inline)
                    .searchable(text: $searchCountry, prompt: "Country name")
                }
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium])
                .presentationCornerRadius(25)
            }
        }
    }
}

#Preview {
    EditPhoneView(isoCountryCode: "ES") { string in
        
    }
}
