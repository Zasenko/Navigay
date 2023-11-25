//
//  String+Ext.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 19.09.23.
//

import Foundation

extension String {
    
    /// format example: "HH:mm"
    func dateFromString(format: String) -> Date? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format // Adjust the date format according to your needs
            return dateFormatter.date(from: self)
        }
    
    func parseHTML() -> String {
        if let decodedText = self.removingPercentEncoding {
            return decodedText
        } else {
            return self
        }
    }
}
