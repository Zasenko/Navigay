//
//  String+Ext.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 19.09.23.
//

import Foundation

extension String {

//    init?(htmlEncodedString: String) {
//        guard let data = htmlEncodedString.data(using: .utf8) else {
//            return nil
//        }
//        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
//            .documentType: NSAttributedString.DocumentType.html,
//            .characterEncoding: String.Encoding.utf8.rawValue
//        ]
//        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
//            return nil
//        }
//        self.init(attributedString.string)
//
//    }
}

extension String {
    
    /// format example: "HH:mm"
    func dateFromString(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}
