//
//  BrowsedPeerCell.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 3/22/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

import SwiftUI

struct BrowsedPeerCell: View {
    var browsedPeer: BrowsedPeer?
    var connectedPeer: BrowsedPeer?
    var action: (() -> ())?
    
    var body: some View {
        if let browsedPeer = browsedPeer {
            Button {
                self.action?()
            } label: {
                HStack {
                    VStack(alignment: .center) {
                        Text(browsedPeer.peerID.displayName)
                        Text(browsedPeer.currentStatus.description)
                        Image(systemName: browsedPeer.currentStatus.imageString)
                    }.foregroundColor(.gray)
                }.padding()
            }.background {
                browsedPeer.currentStatus.textColor
                    .clipShape(.rect(cornerRadius: 10))
            }
        }
        if let connectedPeer = connectedPeer {
            Button {
                self.action?()
            } label: {
                HStack {
                    VStack(alignment: .center) {
                        Text(connectedPeer.peerID.displayName)
                        Text(connectedPeer.currentStatus.description)
                        Image(systemName: connectedPeer.currentStatus.imageString)
                    }.foregroundColor(.gray)
                }.padding()
            }.background {
                connectedPeer.currentStatus.textColor
                    .clipShape(.rect(cornerRadius: 10))
            }
        }
        
    }
}

