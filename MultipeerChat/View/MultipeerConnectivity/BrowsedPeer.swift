//
//  BrowsedPeer.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 7/26/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

import MultipeerConnectivity
import SwiftUI

struct BrowsedPeer: Identifiable {
    
    enum Status: String {
        case connected
        case connecting
        case available
        
        var description: String {
            switch self {
            case .connected:
                return "Connected"
            case .connecting:
                return "Connecting..."
            case .available:
                return "Available"
            }
        }
        
        var textColor: Color {
            switch self {
            case .connected:
                return.green
            case .connecting:
                return .cyan
            case .available:
                return .yellow
            }
        }
        
        var imageString: String {
            switch self {
            case .connected:
                return "checkmark.circle"
            case .connecting:
                return "point.3.filled.connected.trianglepath.dotted"
            case .available:
                return "point.3.connected.trianglepath.dotted"
            }
        }
    }
    
    let peerID: MCPeerID
    var currentStatus : Status = .available {
        willSet {
            // workaround for a bug in SwiftUI for not updating rows content because of ID
            id = UUID()
        }
    }
    private(set) var id = UUID()
    
    init(peerID: MCPeerID) {
        self.peerID = peerID
    }
}

extension BrowsedPeer: CustomStringConvertible {
    var description: String {
        return "Peer: \(peerID.displayName), status: \(currentStatus)"
    }
}
