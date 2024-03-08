//
//  ChatroomViewModel.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 3/28/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

import MultipeerConnectivity
import Observation
import PhotosUI

@Observable
class ChatroomViewModel: NSObject {
    
    var shouldScrollToBottom: Bool = false
    var authorizationStatus: PHAuthorizationStatus = .notDetermined
    let companion: CompanionMP?
    var companions: [CompanionMP]?
    var messages = [MPMessage]()
    var errorAlertShown = false
    var messageText = ""
    var errorMessage = ""
    var currentPage = 0
    var messageSender : MessageSender
    
    init(peer: CompanionMP) {
        self.companion = peer
        messageSender = MessageSender(companionPeer: peer.mcPeerID)
        super.init()
        MPMessage.delegate = self
        messageSender.sessionDelegate = self
    }
    
    init(peers: [CompanionMP]) {
        self.companions = peers
        messageSender = MessageSender(companionPeer: <#T##MCPeerID#>)
    }
    
    func loadInitialMessages() {
        guard currentPage == 0 else {
            return
        }
        getMoreMutualMessages()
    }
    
    private func getMoreMutualMessages() {
        guard let id = UserMP.shared.id else {
            print("No id for this user...")
            return
        }
        print("Loading messages")
        let userMessages = MPMessage.getMutualMessages(between: companion.id, and: id, paging: currentPage)
        if userMessages.count > 0 {
            messages.insert(contentsOf: userMessages, at: currentPage)
            currentPage += 1
        }
    }
    
    
    func sendGroupMessage(message: String, using session: MCSession) {
        guard let data = message.data(using: .utf8) else { return }
        if !session.connectedPeers.isEmpty {
            do {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print("Error sending message to all peers: \(error.localizedDescription)")
            }
            
        }
    }
    
    func sendTextMessage() {
        let frameworkMessage = MultipeerFrameworkMessage(data: Data(messageText.utf8), contentType: .text, commuType: .user)
        let isSent = messageSender.sendMessage(message: frameworkMessage)
        if isSent {
            messageText = ""
            UserMessageSaver.messageSent(to: companion, decodedMessage: frameworkMessage)
        }
        shouldScrollToBottom.toggle()
    }
    
    func sendImageMessage(image: UIImage) {
        let frameworkMessage = MultipeerFrameworkMessage(data: image.pngData(), contentType: .text, commuType: .user)
        let isSent = messageSender.sendMessage(message: frameworkMessage)
        if isSent {
            UserMessageSaver.messageSent(to: companion, decodedMessage: frameworkMessage)
        }
        shouldScrollToBottom.toggle()
    }
    
    func isCurrentUser(message: MPMessage) -> Bool {
        return message.senderPeerID == UserMP.shared.id
    }
}

extension ChatroomViewModel: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let companion = (CompanionMP.getAll().first {
            $0.mcPeerID == peerID }) {
            ReceivedMessageHandler.handleReceivedUserMessage(messageData: data, from: companion)
            shouldScrollToBottom.toggle()
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}

extension ChatroomViewModel : MessageOperations {
    func added(message: MPMessage) {
        DispatchQueue.main.async { [weak self] in
            if (message.senderPeerID == UserMP.shared.id 
                && message.receiverPeerID == self?.companion.id) 
                || (message.receiverPeerID == UserMP.shared.id
                && message.senderPeerID == self?.companion.id) {
                self?.messages.append(message)
            }
        }
    }
}
