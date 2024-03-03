//
//  ChatsViewModel.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 3/14/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

import SwiftUI
import MultipeerConnectivity
import Observation

@Observable
class ChatsViewModel {
    var peers = [CompanionMP]()
    init() {
        CompanionMP.delegate = self
    }
    
    func updatePeers() {
        peers = CompanionMP.getAll().filter { $0.mcPeerID != UserMP.shared.peerID }
        print(peers)
    }
}

extension ChatsViewModel: PeerOperations {
    func added(peer: CompanionMP) {
        DispatchQueue.main.async { [weak self] in
            self?.peers.append(peer)
            self?.updatePeers()
        }
    }
    
    func removeAllPeers() {
        DispatchQueue.main.async { [weak self] in
            CompanionMP.removeAll()
            self?.updatePeers()
        }
    }
    
    func peerRemoved(at index: Int) {
        DispatchQueue.main.async { [weak self] in
            CompanionMP.removePeer(at: index)
            self?.updatePeers()
        }
    }
}
