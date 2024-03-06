//
//  BrowsedPeerCell.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 3/22/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

import SwiftUI


struct BrowsedPeerCell: View {
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
        }.background {
            peer.currentStatus.textColor.opacity(0.2)
                .clipShape(.rect(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(peer.currentStatus.textColor, lineWidth: 2)
                        .padding(1)
                }
        }
    }
}

