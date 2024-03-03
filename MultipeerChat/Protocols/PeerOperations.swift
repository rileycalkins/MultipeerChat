//
//  PeerAdded.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 6/1/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

protocol PeerOperations: AnyObject {
    func added(peer: CompanionMP)
    func removeAllPeers()
    func peerRemoved(at index: Int)
}

