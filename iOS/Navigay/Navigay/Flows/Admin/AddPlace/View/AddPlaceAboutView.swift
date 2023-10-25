//
//  AddPlaceAboutView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 25.10.23.
//

import SwiftUI

struct AddPlaceAboutView: View {
    
    private enum FocusedField {
        case textEditor
    }
    
    //MARK: - Properties
    
    var onSave: (PlaceAbout) -> Void
    
    //MARK: - Private Properties
    
    private let language: Language
    @State private var text: String = ""
    private let characterLimit: Int = 3000
    @FocusState private var focusedField: FocusedField?
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - Inits
    
    init(language: Language, text: String, onSave: @escaping (PlaceAbout) -> Void) {
        self.language = language
        self._text = State(initialValue: text)
        self.onSave = onSave
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Divider()
                TextEditor(text: $text)
                    .font(.body)
                    .lineSpacing(5)
                    .focused($focusedField, equals: .textEditor)
                    .onChange(of: text, initial: true) { oldValue, newValue in
                        text = String(newValue.prefix(characterLimit))
                    }
                HStack {
                    Spacer()
                    Text(String(characterLimit - text.count))
                        .foregroundStyle(.secondary)
                        
                }.padding(.horizontal)
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Information: \(language.getFlag()) \(language.getName())")
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
                        let about = PlaceAbout(language: language, about: text)
                        onSave(about)
                        dismiss()
                    }
                    .bold()
                    .disabled(text.isEmpty)
                }
            }
            .onAppear {
                focusedField = .textEditor
            }
        }
    }
}

#Preview {
    AddPlaceAboutView(language: .de, text: "We and our partners store and/or access information on a device, such as cookies and process personal data, such as unique identifiers and standard information sent by a device for personalised ads and content, ad and content measurement, and audience insights, as well as to develop and improve products. With your permission we and our partners may use precise geolocation data and identification through device scanning.\n\n🔥🔥🔥 You may click to consent to our and our partners’ processing as described above. Alternatively you may access more detailed information and change your preferences before consenting or to refuse consenting. Please note that some processing of your personal data may not require your consent, but you have a right to object to such processing. Your preferences will apply to this website only. You can change your preferences at any time by returning to this site or visit our privacy policy.") { placeAbout in
        
    }
}
