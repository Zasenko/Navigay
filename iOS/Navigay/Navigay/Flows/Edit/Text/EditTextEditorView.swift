//
//  AddAboutPlaceView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 25.10.23.
//

import SwiftUI

struct EditTextEditorView: View {
    
    //MARK: - Properties
    
    var onSave: (String) -> Void
    
    //MARK: - Private Properties
    
    @State private var text: String
    private let title: String
    private let characterLimit: Int
    @FocusState private var focused: Bool
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - Inits

    init(title: String, text: String?, characterLimit: Int, onSave: @escaping (String) -> Void) {
        _text = State(initialValue: text ?? "")
        self.characterLimit = characterLimit
        self.title = title
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
                    .padding(.horizontal, 10)
                    .focused($focused)
                    .onChange(of: text, initial: true) { oldValue, newValue in
                        text = String(newValue.prefix(characterLimit))
                    }
                Text(String(characterLimit - text.count))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)
                    .padding(.bottom)
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
                    Button("Done") {
                        onSave(text)
                        dismiss()
                    }
                    .bold()
                }
            }
            .onAppear {
                focused = true
            }
        }
    }
}

#Preview {
    EditTextEditorView(title: "New Text", text: "We and our partners store and/or access information on a device, such as cookies and process personal data, such as unique identifiers and standard information sent by a device for personalised ads and content, ad and content measurement, and audience insights, as well as to develop and improve products. With your permission we and our partners may use precise geolocation data and identification through device scanning.\n\n🔥🔥🔥 You may click to consent to our and our partners’ processing as described above. Alternatively you may access more detailed information and change your preferences before consenting or to refuse consenting. Please note that some processing of your personal data may not require your consent, but you have a right to object to such processing. Your preferences will apply to this website only. You can change your preferences at any time by returning to this site or visit our privacy policy.", characterLimit: 255) { string in
        debugPrint(string)
    }
}
