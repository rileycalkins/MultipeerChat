//
//  MultipeerSessionManager.swift
//  MultipeerChat
//
//  Created by Riley Calkins on 3/3/24.
//  Copyright © 2024 Hesham Salama. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import Observation

@Observable
class MultipeerSessionManager: NSObject {
    var isCurrentlyAdvertising = false
    var isCurrentlyBrowsing = false
    var didNotStartAdvertising = false
    var shouldShowConnectAlert = false
    var showPeerConnectedAlert = false
    var startErrorMessage = ""
    var peerWantsToConnectMessage = ""
    var peerConnectedSuccessfully = ""
    
    var browsedPeers = [BrowsedPeer]()
    var didNotStartBrowsing = false
    var couldntConnect = false
    var couldntConnectMessage = ""
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser
    private var acceptRequest: (() -> ())?
    private var declineRequest: (() -> ())?
    private let invitationTimeout: TimeInterval = 10.0
    
    private var session: MCSession {
        let session = MCSession(peer: UserMP.shared.peerID!, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }
    
    private var newSession: MCSession {
        let session = SessionManager.shared.newSession
        session.delegate = self
        return session
    }
    
    var availableAndConnectingPeers : [BrowsedPeer] {
        return browsedPeers.filter { $0.currentStatus == .available || $0.currentStatus == .connecting }
    }
    
    var connectedPeers : [BrowsedPeer] {
        return browsedPeers.filter { $0.currentStatus == .connected }
    }
    
    override init() {
        guard let peerID = UserMP.shared.peerID else {
            fatalError("No PeerID detected!")
        }
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: MultipeerConstants.serviceType)
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: MultipeerConstants.serviceType)
        super.init()
    }
    
    // MARK: - Advertising Methods
    func startAdvertising() {
        print("Advertising has started")
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        isCurrentlyAdvertising = true
    }
    
    func stopAdvertising() {
        print("Advertising has stopped")
        advertiser.delegate = nil
        advertiser.stopAdvertisingPeer()
        isCurrentlyAdvertising = false
    }
    
    // MARK: - Browsing Methods
    func startBrowsing() {
        print("Browsing has started")
        browser.delegate = self
        browser.startBrowsingForPeers()
        isCurrentlyBrowsing = true
    }
    
    func stopBrowsing() {
        print("Browsing has stopped")
        browser.delegate = nil
        browser.stopBrowsingForPeers()
        isCurrentlyBrowsing = false
    }
    
    func replyToRequest(isAccepted: Bool) {
        isAccepted ? acceptRequest?() : declineRequest?()
    }
    
    func handlePeerInvitation(_ peerID: MCPeerID, _ invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        acceptRequest = {
            invitationHandler(true, self.newSession)
            print("Accepted Request")
        }
        declineRequest = {
            invitationHandler(false, nil)
            print("Declined Request")
        }
        peerWantsToConnectMessage = "\(peerID.displayName) wants to chat with you."
        shouldShowConnectAlert = true
    }
    
    func peerClicked(browsedPeer: BrowsedPeer) {
        if isPeerAvailableToConnect(peerID: browsedPeer.peerID) {
            browser.invitePeer(browsedPeer.peerID, 
                               to: newSession,
                               withContext: nil,
                               timeout: invitationTimeout)
        }
    }
    
    func isPeerAvailableToConnect(peerID: MCPeerID) -> Bool {
        guard let browsedPeer = (browsedPeers.first { $0.peerID == peerID }) else {
            return false
        }
        return browsedPeer.currentStatus == .available
    }
    
    func removeUnavailablePeer(peerID: MCPeerID) {
        browsedPeers.removeAll() {
            $0.peerID == peerID
        }
    }
    
    func saveConnectedPeerIdentifier(_ peerID: MCPeerID) {
        var connectedPeers = UserDefaults.standard.stringArray(forKey: "ConnectedPeers")
        if let unwrappedConnectedPeers = connectedPeers {
            if !unwrappedConnectedPeers.contains(peerID.displayName) {
                connectedPeers?.append(peerID.displayName)
                UserDefaults.standard.set(connectedPeers, forKey: "ConnectedPeers")
            }
        }
    }
    
    func decidePeerStatus(_ peer: BrowsedPeer) {
        if SessionManager.shared.getMutualSession(with: peer.peerID) != nil {
            setStatus(for: peer.peerID, status: .connected)
        } else {
            setStatus(for: peer.peerID, status: .available)
        }
    }
    
    func setStatus(for peerID: MCPeerID, status: BrowsedPeer.Status) {
        guard let index = (browsedPeers.firstIndex {
            $0.peerID == peerID
        }) else {
            print("Couldn't find peerID: \(peerID.displayName), so couldn't set its status")
            return
        }
        print("Set peer status of \(peerID.displayName) to \(status)")
        browsedPeers[index].currentStatus = status
    }
    
    func showCouldntConnectError(failedToConnectPeer: MCPeerID) {
        couldntConnectMessage = "Couldn't connect to \(failedToConnectPeer.displayName)"
        couldntConnect = true
    }
}

extension MultipeerSessionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Received invitation from \(peerID.displayName)")
        handlePeerInvitation(peerID, invitationHandler)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        startErrorMessage = error.localizedDescription
        didNotStartAdvertising = true
    }
}

extension MultipeerSessionManager:  MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found a new peer: \(peerID.displayName)")
        let browsedPeer = BrowsedPeer(peerID: peerID)
        browsedPeers.append(browsedPeer)
        decidePeerStatus(browsedPeer)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Peer \(peerID.displayName) is lost. Removing...")
        removeUnavailablePeer(peerID: peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        startErrorMessage = error.localizedDescription
        didNotStartBrowsing = true
    }
}

extension MultipeerSessionManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async { [weak self] in
            switch state {
            case .notConnected:
                print("Failed to connect to \(peerID.displayName)")
                self?.showCouldntConnectError(failedToConnectPeer: peerID)
                self?.setStatus(for: peerID, status: .available)
            case .connecting:
                print("Connecting to \(peerID.displayName)")
                self?.setStatus(for: peerID, status: .connecting)
                
            case .connected:
                print("Connected to \(peerID.displayName)")
                self?.setStatus(for: peerID, status: .connected)
                DispatchQueue.main.async { [weak self] in
                    let message = "\(peerID.displayName) is connected successfully."
                    self?.peerConnectedSuccessfully = message
                    self?.showPeerConnectedAlert = true
                    let messageSender = MessageSender(companionPeer: peerID, sessionDelegate: self)
                    messageSender.sendSelfInfo()
                }
            @unknown default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Browser - Received data from \(peerID.displayName)")
        if let companion = (CompanionMP.getAll().first {
            $0.mcPeerID == peerID }) {
            ReceivedMessageHandler.handleReceivedUserMessage(messageData: data, from: companion)
        } else if let companion = ReceivedMessageHandler.handleCompanionInfo(data: data) {
            companion.saveLocally()
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}

