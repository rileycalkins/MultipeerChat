//
//  PeerChatCell.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 3/26/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

import SwiftUI
import MultipeerConnectivity

struct PeerChatCell: View {
    @Environment(MultipeerSessionManager.self) var multipeerSessionManager: MultipeerSessionManager
    typealias actionClosure = (() -> ())?
    let multipeerUser: CompanionMP
    var action: actionClosure
    private let image: Image
    
    init(
        multipeerUser: CompanionMP,
        sessionActive: Bool,
        action: actionClosure = nil
    ) {
        self.multipeerUser = multipeerUser
        self.action = action
        self.image = DefaultImageConstructor.get(uiimage: multipeerUser.picture)
    
    }
    
    var body: some View {
        Group {
            @Bindable var multiPSMBindable = multipeerSessionManager
            VStack {
                HStack(spacing: 16) {
                    self.image.peerImageModifier()
                        .frame(width: 60, height: 60)
                        .overlay(alignment: .bottomTrailing) {
                            if peerConnected(peerID: multipeerUser.mcPeerID) {
                                Image(systemName: "wifi")
                                    .font(.title)
                                    .fontWeight(.ultraLight)
                                    .symbolVariant(.circle)
                                    .symbolVariant(.fill)
                                    .symbolEffect(.variableColor)
                                    .foregroundStyle(.white, .green, .green)
                                    .offset(x: 10, y: 4)
                            } else {
                                Image(systemName: "wifi.exclamationmark")
                                    .font(.title)
                                    .fontWeight(.ultraLight)
                                    .symbolVariant(.circle)
                                    .symbolVariant(.fill)
                                    .symbolEffect(.pulse)
                                    .foregroundStyle(.white, .red, .red)
                                    .offset(x: 10, y: 4)
                            }
                        }
                    VStack(alignment: .leading) {
                        Text(self.multipeerUser.mcPeerID.displayName)
                            .font(.title)
                        Text(self.multipeerUser.id.uuidString.replacingOccurrences(of: "-", with: ""))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(String(describing: SessionManager.shared.getMutualSession(with: [multipeerUser.mcPeerID])?.connectedPeers))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(String(describing: SessionManager.shared.getMutualSession(with: [multipeerUser.mcPeerID])?.myPeerID))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
        }
    }
    
    func peerConnected(peerID: MCPeerID) -> Bool {
        return multipeerSessionManager.connectedPeers.contains(where: { $0.peerID == peerID })
    }
}
