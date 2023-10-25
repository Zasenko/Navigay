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
    var onDelete: (Language) -> Void
    
    //MARK: - Private Properties
    
    private let language: Language
    @State private var text: String = ""
    @State private var showAlert: Bool = false
    @FocusState private var focusedField: FocusedField?
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - Inits
    
    init(language: Language, text: String, onSave: @escaping (PlaceAbout) -> Void, onDelete: @escaping (Language) -> Void) {
        self.language = language
        self._text = State(initialValue: text)
        self.onSave = onSave
        self.onDelete = onDelete
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
                    .padding(.horizontal)
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
                        guard !text.isEmpty else {
                            showAlert.toggle()
                            return
                        }
                        let about = PlaceAbout(language: language, about: text)
                        onSave(about)
                        dismiss()
                    }
                    .bold()
                }
            }
            .onAppear {
                focusedField = .textEditor
            }
            .alert("Empty information", isPresented: $showAlert) {
                Button(role: .destructive) {
                    onDelete(language)
                    dismiss()
                } label: {
                    Text("Delete")
                }
            } message: {
                Text("Enter text or delete information in this language.")
            }
        }
    }
}

#Preview {
    AddPlaceAboutView(language: .de, text: "") { placeAbout in
        
    } onDelete: { language in
        
    }
}
