//
//  FidoNetworkManager.swift
//  MyMarketplace
//
//  Created by Avijit Nagare on 2026-05-08.
//

import Foundation
import Network

class FidoNetworkManager {
    static let shared = FidoNetworkManager()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "FidoNetworkMonitorQueue")
    private let lock = NSLock()
    private var _isConnected: Bool = false
    
    // Public, thread-safe snapshot of connectivity
    var isConnected: Bool {
        lock.lock(); defer { lock.unlock() }
        return _isConnected
    }
    
    // Optional callback when connectivity changes (called on main queue)
    var onStatusChange: ((Bool) -> Void)?
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let connected = path.status == .satisfied
            self.lock.lock()
            let changed = connected != self._isConnected
            self._isConnected = connected
            self.lock.unlock()
            
            if changed {
                DispatchQueue.main.async {
                    self.onStatusChange?(connected)
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    // Convenience method if you prefer a function call
    func isInternetAvailable() -> Bool {
        return isConnected
    }
}
