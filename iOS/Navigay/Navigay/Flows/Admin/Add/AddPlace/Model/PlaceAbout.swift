//
//  PlaceAbout.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 25.10.23.
//

import Foundation

struct PlaceAbout: Identifiable {
    
    //MARK: - Properties
    
    let id: UUID = UUID()
    let language: Language
    var about: String
    
    //MARK: - Inits
   
    init(language: Language, about: String) {
        self.language = language
        self.about = about
    }
}
