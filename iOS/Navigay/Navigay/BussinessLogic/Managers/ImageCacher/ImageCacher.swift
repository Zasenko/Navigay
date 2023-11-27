//
//  ImageCacher.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI

final class ImageCacher {
    
    typealias CacheType = NSCache<NSString, NSData>
    
    //MARK: - Properties
    
    static let shared = ImageCacher()
    
    //MARK: - Private properties
    
    private lazy var cache: CacheType = {
        let cache = CacheType()
        cache.countLimit = 200
        cache.totalCostLimit = 100 * 1024 * 1024 // 5242800 Bytes > 100MB
        return cache
    }()
    
    //MARK: - Initialization
    
    private init() {}
}

extension ImageCacher {
    
    //MARK: - Functions
    
    func object(forKey key: String) -> Data? {
        return cache.object(forKey: key as NSString) as Data?
    }
    
    func set(object: Data, forKey key: String) {
        cache.setObject(object as NSData, forKey: key as NSString)
    }
}
