//
//  ChatsView.swift
//  MultipeerChat
//
//  Created by Hesham on 3/9/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

import SwiftUI
import Observation

struct ChatsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(MultipeerSessionManager.self) var multipeerSessionManager: MultipeerSessionManager
    @State private var actionSheetShown = false
    @State private var chatsViewModel = ChatsViewModel()
    @State var browsingAnimationBool = false
    @State var advertisingAnimationBool = false
    @State var loadingState = LoadingState()
    
    var body: some View {
        NavigationStack {
            @Bindable var multipeerSessionManagerBindable = multipeerSessionManager
            VStack(alignment: .leading) {
               
                if !multipeerSessionManager.availablePeers.isEmpty {
                    Text("Available Peers")
                        .peerSectionText()
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach($multipeerSessionManagerBindable.availablePeers) { browsedPeer in
                                BrowsedPeerCell(peer: browsedPeer) {
                                    self.multipeerSessionManager.peerClicked(browsedPeer: browsedPeer.wrappedValue) {
                                        self.multipeerSessionManager.stopBrowsing()
                                    }
                                    
                                }
                            }
                        }
                    }.contentMargins(.horizontal, 20)
                }
                
                if !multipeerSessionManager.connectingPeers.isEmpty {
                    Text("Connecting Peers")
                        .peerSectionText()
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach($multipeerSessionManagerBindable.connectingPeers) { browsedPeer in
                                BrowsedPeerCell(peer: browsedPeer)
                            }
                        }
                    }.contentMargins(.horizontal, 20)
                }
                
                if !multipeerSessionManager.connectedPeers.isEmpty {
                    Text("Connected Peers")
                        .peerSectionText()
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach($multipeerSessionManagerBindable.connectedPeers, id: \.id) { peer in
                                BrowsedPeerCell(peer: peer)
                            }
                        }
                    }.contentMargins(.horizontal, 20)
                }
                
                VStack {
                    List {
                        ForEach(chatsViewModel.peers) { peer in
                            let chatroomViewDestination = ChatroomView(multipeerUser: peer)
                            NavigationLink(destination: chatroomViewDestination) {
                                if let peerID = chatroomViewDestination.companion?.mcPeerID {
                                    PeerChatCell(multipeerUser: peer, sessionActive: SessionManager.shared.getMutualSession(with: peerID) != nil)
                                }
                                
                            }
                            .listRowSeparator(.hidden)
                        }.onDelete { indexSet in
                            indexSet.forEach { index in
                                self.multipeerSessionManager.stopBrowsing()
                                self.chatsViewModel.peerRemoved(at: index)
                                self.multipeerSessionManager.removePeer(peerID: chatsViewModel.peers[index].mcPeerID)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.multipeerSessionManager.startBrowsing()
                                }
                                
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        refresh()
                    }
                }
                .navigationBarTitle("Chats")
                
                .onChange(of: multipeerSessionManager.isCurrentlyAdvertising) { oldValue, newValue in
                    if oldValue {
                        multipeerSessionManager.stopAdvertising()
                    }
                    if newValue {
                        multipeerSessionManager.startAdvertising()
                    }
                }
                .onChange(of: multipeerSessionManager.isCurrentlyBrowsing) { oldValue, newValue in
                    if oldValue {
                        multipeerSessionManager.stopBrowsing()
                    }
                    if newValue {
                        multipeerSessionManager.startBrowsing()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if let profilePic = UserMP.shared.profilePicture {
                            Image(uiImage: profilePic)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(.circle)
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        advertiserButton
                        
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        browserButton
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            self.chatsViewModel.removeAllPeers()
                        } label: {
                            Image(systemName: "x.circle")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            self.actionSheetShown.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .onAppear {
                self.reportOnAppear()
                multipeerSessionManagerBindable.stopBrowsing()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    multipeerSessionManagerBindable.startBrowsing()
                }
            }
            .alert(isPresented: $multipeerSessionManagerBindable.didNotStartBrowsing) {
                Alert(title: Text("Search Error"), message: Text(multipeerSessionManager.startBrowsingErrorMessage), dismissButton: .default( Text("OK"), action: {
                    self.presentationMode.wrappedValue.dismiss()
                }))
            }
            .alert(isPresented: $multipeerSessionManagerBindable.couldntConnect) {
                Alert(title: Text("Error"), message: Text(multipeerSessionManager.couldntConnectMessage), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $multipeerSessionManagerBindable.shouldShowConnectAlert) {
                Alert(title: Text("Invitation"), message: Text(multipeerSessionManagerBindable.peerWantsToConnectMessage), primaryButton: .default(Text("Accept"), action: {
                    self.multipeerSessionManager.replyToRequest(isAccepted: true)
                }), secondaryButton: .cancel(Text("Decline"), action: {
                    self.multipeerSessionManager.replyToRequest(isAccepted: false)
                }))
            }
        }
        .loadingView(loadingState: loadingState)
        
    }
    
    var browserButton: some View {
        BrowsingButton(multipeerSessionManager: multipeerSessionManager, isCurrentlyBrowsing: isCurrentlyBrowsing)
        
    }
    
    var advertiserButton: some View {
        AdvertiserButton(multipeerSessionManager: multipeerSessionManager, isCurrentlyAdvertising: isCurrentlyAdvertising)
    }
    
    func refresh() {
        self.multipeerSessionManager.publicPeers = []
        self.multipeerSessionManager.stopBrowsing()
        self.chatsViewModel.updatePeers()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.multipeerSessionManager.startBrowsing()
        }
    }
    
    func isCurrentlyAdvertising() -> Bool {
        return multipeerSessionManager.isCurrentlyAdvertising
    }
    
    func isCurrentlyBrowsing() -> Bool {
        return multipeerSessionManager.isCurrentlyBrowsing
    }
    
    func reportOnAppear() {
        print("Reloading peers")
        self.chatsViewModel.updatePeers()
    }
}

struct BrowsingButton: View {
    var multipeerSessionManager: MultipeerSessionManager
    @State var browsingAnimationBool: Bool = false
    var isCurrentlyBrowsing: () -> Bool
    
    var body: some View {
        Group {
            @Bindable var multipeerSessionManagerBindable = multipeerSessionManager
            Button {
                if multipeerSessionManager.isCurrentlyBrowsing {
                    multipeerSessionManager.stopBrowsing()
                } else {
                    multipeerSessionManager.startBrowsing()
                }
                browsingAnimationBool.toggle()
            } label: {
                
                if !isCurrentlyBrowsing() {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .foregroundStyle(.cyan.opacity(0.6), .cyan.opacity(0.3), .cyan.opacity(0.3))
                        .font(.largeTitle)
                        .fontWeight(.light)
                        .symbolRenderingMode(.palette)
                        .symbolVariant(.circle)
                        .symbolVariant(.fill)
                        .symbolEffect(.bounce.byLayer.down, value: browsingAnimationBool)
                } else {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .foregroundStyle(.white, .cyan, .cyan.opacity(0.8))
                        .font(.largeTitle)
                        .fontWeight(.light)
                        .symbolRenderingMode(.palette)
                        .symbolVariant(.circle)
                        .symbolVariant(.fill)
                        .symbolEffect(.variableColor)
                        .symbolEffect(.bounce.byLayer.up, value: browsingAnimationBool)
                }
            }
            
        }.overlay(alignment: .bottom) {
            Text("Browse").font(.system(size: 10))
                .foregroundStyle(isCurrentlyBrowsing() ? .white : .cyan)
                .padding(.vertical, 1)
                .padding(.horizontal, 4)
                .background {
                    RoundedRectangle(cornerRadius: 3)
                        .foregroundStyle(isCurrentlyBrowsing() ? .cyan : .white)
                        .overlay {
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(isCurrentlyBrowsing() ? .white : .cyan)
                        }
                    
                }
                .offset(y: -7)
        }
    }
}

struct AdvertiserButton: View {
    var multipeerSessionManager: MultipeerSessionManager
    @State var advertisingAnimationBool: Bool = false
    var isCurrentlyAdvertising: () -> Bool
    var body: some View {
        Group {
            @Bindable var multipeerSessionManagerBindable = multipeerSessionManager
            Button {
                if multipeerSessionManager.isCurrentlyAdvertising {
                    multipeerSessionManager.stopAdvertising()
                } else {
                    multipeerSessionManager.startAdvertising()
                }
                advertisingAnimationBool.toggle()
            } label: {
                if !isCurrentlyAdvertising() {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.green.opacity(0.6), .green.opacity(0.3), .green.opacity(0.3))
                        .font(.largeTitle)
                        .fontWeight(.light)
                        .symbolVariant(.circle)
                        .symbolVariant(.fill)
                        .symbolEffect(.bounce.byLayer.down, value: advertisingAnimationBool)
                } else {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .foregroundStyle(.white, .green, .green.opacity(0.8))
                        .font(.largeTitle)
                        .fontWeight(.light)
                        .symbolRenderingMode(.palette)
                        .symbolVariant(.circle)
                        .symbolVariant(.fill)
                        .symbolEffect(.variableColor)
                        .symbolEffect(.bounce.byLayer.up, value: advertisingAnimationBool)
                }
            }
        }.overlay(alignment: .bottom){
            Text("Advertise").font(.system(size: 10))
                .foregroundStyle(isCurrentlyAdvertising() ? .white : .green)
                .padding(.vertical, 1)
                .padding(.horizontal, 4)
                .background {
                    RoundedRectangle(cornerRadius: 3)
                        .foregroundStyle(isCurrentlyAdvertising() ? .green : .white)
                        .overlay {
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(isCurrentlyAdvertising() ? .white : .green, lineWidth: 1)
                        }
                }
                .offset(y: -7)
        }
    }
}
