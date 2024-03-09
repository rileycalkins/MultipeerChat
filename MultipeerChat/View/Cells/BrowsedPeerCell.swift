//
//  BrowsedPeerCell.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 3/22/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

import SwiftUI


struct BrowsedPeerCell: View {
    @Environment(MultipeerSessionManager.self) var multipeerSessionManager: MultipeerSessionManager
    @Binding var peer: BrowsedPeer
    var action: (() -> ())?
    
    var body: some View {
        Button {
            self.action?()
        } label: {
            HStack {
                ZStack {
                    if peer.currentStatus == .connecting {
                        Capsule()
                            .fill(.white)
                            .frame(width: 60, height: 45)
                            .overlay {
                                Capsule()
                                    .stroke(peer.currentStatus.textColor, lineWidth: 1.5)
                            }
                    } else {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 45))
                            .foregroundStyle(.white)
                            .overlay {
                                Image(systemName: "circle")
                                    .font(.system(size: 50))
                                    .fontWeight(.ultraLight)
                                    .foregroundStyle(peer.currentStatus.textColor)
                            }
                    }
                    
                    Image(systemName: peer.currentStatus.imageString)
                        .font(.title)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(peer.currentStatus.textColor)
                        .symbolEffect(.variableColor)
                }
                
                
                VStack(alignment: .leading) {
                    Text(peer.peerID.displayName)
                        
                        .fontWeight(.semibold)
                    Text(peer.currentStatus.description)
                        .font(.footnote)
                }
            }.foregroundStyle(peer.currentStatus.textColor)
                .padding(.vertical, 8)
                .padding(.horizontal)
                .padding(.trailing, peer.currentStatus == .connected ? 30 : 0)
        }.background {
            peer.currentStatus.textColor.opacity(0.2)
                .clipShape(.rect(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(peer.currentStatus.textColor, lineWidth: 2)
                        .padding(1)
                }
        }
        .overlay(alignment: .topTrailing) {
            if peer.currentStatus == .connected {
                Button {
                    multipeerSessionManager.removePeer(peerID: peer.peerID)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        multipeerSessionManager.startBrowsing()
                    }
                } label: {
                    Image(systemName: "x.circle")
                        .font(.title)
                        .foregroundStyle(.white)
                }.padding(.trailing, 4)
                    .padding(.top, 4)
            }
        }
    }
}

