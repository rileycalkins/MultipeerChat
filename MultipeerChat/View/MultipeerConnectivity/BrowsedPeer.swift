//
//  BrowsedPeer.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 7/26/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

import MultipeerConnectivity
import SwiftUI

struct BrowsedPeer: Identifiable, Equatable {
    
    static func == (rhs: BrowsedPeer, lhs: BrowsedPeer) -> Bool {
        return rhs.currentStatus == lhs.currentStatus
        && rhs.peerID == lhs.peerID
        && rhs.description == lhs.description
        && rhs.id == lhs.id
    }
    
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
                return "person.wave.2"
            case .connecting:
                return "person.line.dotted.person"
            case .available:
                return "person.badge.plus"
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
