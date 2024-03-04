//
//  BrowserView.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 3/20/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

import SwiftUI

struct BrowserView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(MultipeerSessionManager.self) var multipeerSessionManager: MultipeerSessionManager
    
    var body: some View {
        Group {
            @Bindable var multipeerSessionManagerBindable = multipeerSessionManager
            List {
                Section(header: Text("Available Peers")) {
                    ForEach(multipeerSessionManager.availableAndConnectingPeers) { browsedPeer in
                        BrowsedPeerCell(browsedPeer: browsedPeer) {
                            self.multipeerSessionManager.peerClicked(browsedPeer: browsedPeer)
                        }
                    }
                }
                Section(header: Text("Connected Peers")) {
                    ForEach(multipeerSessionManager.connectedPeers, id: \.id) { peer in
                        BrowsedPeerCell(connectedPeer: peer)
                    }
                }
                .alert(isPresented: $multipeerSessionManagerBindable.couldntConnect) {
                    Alert(title: Text("Error"), message: Text(multipeerSessionManager.couldntConnectMessage), dismissButton: .default(Text("OK")))
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Peer Search"))
            
            .alert(isPresented: $multipeerSessionManagerBindable.didNotStartBrowsing) {
                Alert(title: Text("Search Error"), message: Text(multipeerSessionManager.startErrorMessage), dismissButton: .default( Text("OK"), action: {
                    self.presentationMode.wrappedValue.dismiss()
                }))
            }
        }
    }
}

struct BrowserView_Previews: PreviewProvider {
    static var previews: some View {
        BrowserView()
    }
}
