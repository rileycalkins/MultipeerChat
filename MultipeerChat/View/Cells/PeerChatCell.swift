//
//  PeerChatCell.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 3/26/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

import SwiftUI

struct PeerChatCell: View {
    typealias actionClosure = (() -> ())?
    let multipeerUser: CompanionMP
    var action: actionClosure
    private let image: Image
    var sessionActive: Bool
    
    init(
        multipeerUser: CompanionMP,
        sessionActive: Bool,
        action: actionClosure = nil
    ) {
        self.multipeerUser = multipeerUser
        self.action = action
        self.image = DefaultImageConstructor.get(uiimage: multipeerUser.picture)
        self.sessionActive = sessionActive
    }
    
    var body: some View {
        HStack(spacing: 16) {
                self.image.peerImageModifier()
                    .frame(width: 60, height: 60)
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: sessionActive ? "wifi.circle.fill" : "wifi.exclamationmark.circle.fill")
                            .symbolEffect(.pulse)
                            .foregroundStyle(sessionActive ? .green : .red)
                            .font(.title)
                            .offset(x: 10, y: 4)
                            .background {
                                Circle()
                                    .fill(.white)
                                    .font(.title)
                                    .offset(x: 10, y: 4)
                            }
                    }
                VStack(alignment: .leading) {
                    Text(self.multipeerUser.mcPeerID.displayName)
                        .font(.title)
                    Text(self.multipeerUser.id.uuidString.replacingOccurrences(of: "-", with: ""))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                
            }
    }
}
