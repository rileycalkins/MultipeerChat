//
//  MessageSender.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 3/24/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

import MultipeerConnectivity

class GroupMessageSender {
    private var companionPeers: [MCPeerID]
    weak var sessionDelegate: MCSessionDelegate?
    
    init(companionPeers: [MCPeerID], sessionDelegate: MCSessionDelegate? = nil) {
        self.companionPeers = companionPeers
        self.sessionDelegate = sessionDelegate
    }
    
    lazy var userAsCompanion: CompanionMP? = {
        guard let userPeer = UserMP.shared.peerID, let userID = UserMP.shared.id else { return nil }
        let userAsCompanion = CompanionMP(mcPeerID: userPeer, picture: UserMP.shared.profilePicture, id: userID)
        return userAsCompanion
    }()
    
    var session: MCSession? {
        let session = SessionManager.shared.getMutualSession(with: companionPeers)
        session?.delegate = sessionDelegate
        return session
    }
    
    @discardableResult
    func sendSelfInfo() -> Bool {
        guard let encodedVal = try? JSONEncoder().encode(userAsCompanion) else {
            print("Error in encoding companion object")
            return false
        }
        guard let session = session else {
            print("nil session")
            return false
        }
        do {
            for peer in companionPeers {
                try session.send(encodedVal, toPeers:[peer], with: .reliable)
                print("Self info has been sent to peer \(peer.displayName)")
            }
            
            return true
        } catch {
            print("Error in sending message to the peer")
            print(error)
            return false
        }
    }
    
    @discardableResult
    func sendMessage(message: MultipeerFrameworkMessage) -> Bool {
        do {
            guard let encodedMessage = encodeMessage(message: message) else {
                return false
            }
            guard let session = session else {
                print("nil session")
                return false
            }
            for peer in companionPeers {
                try session.send(encodedMessage, toPeers: [peer], with: .reliable)
                print("Message sent to \(peer.displayName)")
            }
        } catch {
            print("Error in sending the message")
            print(error)
            return false
        }
        return true
    }
    
    private func encodeMessage(message: MultipeerFrameworkMessage) -> Data? {
        return try? JSONEncoder().encode(message)
    }
}

class MessageSender {
    
    private let companionPeer: MCPeerID?
    var companionPeers: [MCPeerID]?
    weak var sessionDelegate: MCSessionDelegate?
    
    init(companionPeer: MCPeerID, sessionDelegate: MCSessionDelegate? = nil) {
        self.companionPeer = companionPeer
        self.sessionDelegate = sessionDelegate
    }
    
    init(companionPeers: [MCPeerID]?, sessionDelegate: MCSessionDelegate? = nil) {
        self.companionPeers = companionPeers
        self.sessionDelegate = sessionDelegate
    }
    
    lazy var userAsCompanion: CompanionMP? = {
        guard let userPeer = UserMP.shared.peerID, let userID = UserMP.shared.id else { return nil }
        let userAsCompanion = CompanionMP(mcPeerID: userPeer, picture: UserMP.shared.profilePicture, id: userID)
        return userAsCompanion
    }()
    
    var session: MCSession? {
        if let companionPeer = companionPeer {
            let session = SessionManager.shared.getMutualSession(with: companionPeer)
            session?.delegate = sessionDelegate
            return session
        } else if let companionPeers = companionPeers {
            let session = SessionManager.shared.getMutualSession(with: companionPeers)
            session?.delegate = sessionDelegate
            return session
        }
    }
    
    @discardableResult
    func sendSelfInfo() -> Bool {
        guard let encodedVal = try? JSONEncoder().encode(userAsCompanion) else {
            print("Error in encoding companion object")
            return false
        }
        guard let session = session else {
            print("nil session")
            return false
        }
        do {
            if let companionPeers {
                for peer in companionPeers {
                    try session.send(encodedVal, toPeers: [peer], with: .reliable)
                }
            }
            if let companionPeer = companionPeer {
                try session.send(encodedVal, toPeers: [companionPeer], with: .reliable)
            }
            
            print("Self info has been sent")
            return true
        } catch {
            print("Error in sending message to the peer")
            print(error)
            return false
        }
    }
    
//    @discardableResult
//    func sendMessage(text: String) -> Bool {
//        let message = MultipeerFrameworkMessage(data: Data(text.utf8), contentType: .text, commuType: .user)
//        return sendMessage(message: message)
//    }
//
//    @discardableResult
//    func sendMessage(image: UIImage) -> Bool {
//        let message = MultipeerFrameworkMessage(data: image.pngData(), contentType: .image, commuType: .user)
//        return sendMessage(message: message)
//    }

    @discardableResult
    func sendMessage(message: MultipeerFrameworkMessage) -> Bool {
        do {
            guard let encodedMessage = encodeMessage(message: message) else {
                return false
            }
            guard let session = session else {
                print("nil session")
                return false
            }
            if let companionPeer = companionPeer {
                try session.send(encodedMessage, toPeers: [companionPeer], with: .reliable)
            }
            if let companionPeers = companionPeers {
                for peer in companionPeers {
                    try session.send(encodedMessage, toPeers: [peer], with: .reliable)
                }
            }
            print("Message sent")
        } catch {
            print("Error in sending the message")
            print(error)
            return false
        }
        return true
    }
    
    private func encodeMessage(message: MultipeerFrameworkMessage) -> Data? {
        return try? JSONEncoder().encode(message)
    }
}
