//
//  NetworkMonitorManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 21.02.24.
//

import Foundation
import Network

protocol NetworkMonitorManagerProtocol {
    var isConnected: Bool { get }
    var notify: ((Bool) -> Void)? { get set }
}

final class NetworkMonitorManager: NetworkMonitorManagerProtocol {
    
    // MARK: - Properties
    
    var notify: ((Bool) -> Void)?
    var isConnected = false {
        didSet {
            notify?(isConnected)
        }
    }
    
    // MARK: - Private Properties
    
    private var errorManager: ErrorManagerProtocol
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    // MARK: - Init
    
    init(errorManager: ErrorManagerProtocol) {
        self.errorManager = errorManager
        startMonitoring()
    }
}

extension NetworkMonitorManager {
    
    // MARK: - Private Functions
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            if path.status == .satisfied {
                DispatchQueue.main.async {
//                    if self.isConnected != true {
//                        self.errorManager.showNetworkConnected()
//                    }
                    self.isConnected = true
                }
            } else {
                DispatchQueue.main.async {
//                    if self.isConnected != false {
//                        self.errorManager.showNetworkNoConnected()
//                    }
                    self.isConnected = false
                }
            }
        }
        monitor.start(queue: queue)
    }
}
