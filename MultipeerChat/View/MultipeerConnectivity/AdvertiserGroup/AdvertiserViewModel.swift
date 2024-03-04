////
////  AdvertiserViewModel.swift
////  MultipeerChat
////
////  Created by Hesham Salama on 3/20/20.
////  Copyright © 2020 Hesham Salama. All rights reserved.
////
//
//import MultipeerConnectivity
//import Observation
//
//@Observable
//class AdvertiserViewModel: NSObject {
//    var isCurrentlyAdvertising = false
//    var didNotStartAdvertising = false
//    var shouldShowConnectAlert = false
//    var showPeerConnectedAlert = false
//    var startErrorMessage = ""
//    var peerWantsToConnectMessage = ""
//    var peerConnectedSuccessfully = ""
//    private let advertiser: MCNearbyServiceAdvertiser
//    private var acceptRequest: (() -> ())?
//    private var declineRequest: (() -> ())?
//    
//    private var newSession: MCSession {
//        let session = SessionManager.shared.newSession
//        session.delegate = self
//        return session
//    }
//    
//    override init() {
//        guard let peerID = UserMP.shared.peerID else {
//            fatalError("No PeerID detected!")
//        }
//        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: MultipeerConstants.serviceType)
//        super.init()
//    }
//    
//    
//    func startAdvertising() {
//        print("Advertising has started")
//        advertiser.delegate = self
//        advertiser.startAdvertisingPeer()
//        isCurrentlyAdvertising = true
//    }
//    
//    func stopAdvertising() {
//        print("Advertising has stopped")
//        advertiser.delegate = nil
//        advertiser.stopAdvertisingPeer()
//        isCurrentlyAdvertising = false 
//    }
//    
//    func replyToRequest(isAccepted: Bool) {
//        isAccepted ? acceptRequest?() : declineRequest?()
//    }
//    
//    func handlePeerInvitation(_ peerID: MCPeerID, _ invitationHandler: @escaping (Bool, MCSession?) -> Void) {
//        acceptRequest = {
//            invitationHandler(true, self.newSession)
//            print("Accepted Request")
//        }
//        declineRequest = {
//            invitationHandler(false, nil)
//            print("Declined Request")
//        }
//        peerWantsToConnectMessage = "\(peerID.displayName) wants to chat with you."
//        shouldShowConnectAlert = true
//    }
//}
//
//extension AdvertiserViewModel: MCNearbyServiceAdvertiserDelegate {
//    
//    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
//        print("Received invitation from \(peerID.displayName)")
//        handlePeerInvitation(peerID, invitationHandler)
//    }
//    
//    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
//        startErrorMessage = error.localizedDescription
//        didNotStartAdvertising = true
//    }
//}
//
//extension AdvertiserViewModel: MCSessionDelegate {
//    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
//        switch state {
//        case .connected:
//            DispatchQueue.main.async { [weak self] in
//                let message = "\(peerID.displayName) is connected successfully."
//                self?.peerConnectedSuccessfully = message
//                self?.showPeerConnectedAlert = true
//                let messageSender = MessageSender(companionPeer: peerID, sessionDelegate: self)
//                messageSender.sendSelfInfo()
//            }
//            print("Connected: \(peerID.displayName)")
//        case .connecting:
//            
//            print("Connecting: \(peerID.displayName)")
//        case .notConnected:
//            print("Not Connected: \(peerID.displayName)")
//        default:
//            print("Unknown state received: \(peerID.displayName)")
//        }
//        
//        
//    }
//    
//    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
//        print("Advertiser - Received data from \(peerID.displayName)")
//        if let companion = (CompanionMP.getAll().first {
//            $0.mcPeerID == peerID }) {
//            ReceivedMessageHandler.handleReceivedUserMessage(messageData: data, from: companion)
//        } else if let companion = ReceivedMessageHandler.handleCompanionInfo(data: data) {
//            companion.saveLocally()
//        }
//    }
//    
//    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
//        
//    }
//    
//    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
//        
//    }
//    
//    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
//        
//    }
//}
