//
//  Sequence+Ext.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 18.12.23.
//

import Foundation

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
