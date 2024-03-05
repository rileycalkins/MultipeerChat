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
            ScrollView(.horizontal) {
                HStack {
                    ForEach(multipeerSessionManager.availableAndConnectingPeers) { browsedPeer in
                        BrowsedPeerCell(browsedPeer: browsedPeer) {
                            self.multipeerSessionManager.peerClicked(browsedPeer: browsedPeer)
//                            loadingState.startLoading(withSuccess: self.multipeerSessionManager.couldntConnect)
                        }
                    }
                }
            }.contentMargins(.horizontal, 20)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(multipeerSessionManager.connectedPeers, id: \.id) { peer in
                        BrowsedPeerCell(connectedPeer: peer)
                    }
                }
            }.contentMargins(.horizontal, 20)
                .alert(isPresented: $multipeerSessionManagerBindable.couldntConnect) {
                    Alert(title: Text("Error"), message: Text(multipeerSessionManager.couldntConnectMessage), dismissButton: .default(Text("OK")))
                }
            VStack {
                List {
                    ForEach(chatsViewModel.peers) { peer in
                        let chatroomViewDestination = ChatroomView(multipeerUser: peer)
                        NavigationLink(destination: chatroomViewDestination) {
                            PeerChatCell(multipeerUser: peer, sessionActive: SessionManager.shared.getMutualSession(with: chatroomViewDestination.companion.mcPeerID) != nil)
                        }
                        .listRowSeparator(.hidden)
                    }.onDelete { indexSet in
                        indexSet.forEach { index in
                            self.chatsViewModel.peerRemoved(at: index)
                            self.multipeerSessionManager.removeUnavailablePeer(peerID: chatsViewModel.peers[index].mcPeerID)
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    self.chatsViewModel.updatePeers()
                }
            }
            .navigationBarTitle("Chats")
            .loadingView(loadingState: loadingState)
            .alert(isPresented: $multipeerSessionManagerBindable.shouldShowConnectAlert) {
                Alert(title: Text("Invitation"), message: Text(multipeerSessionManagerBindable.peerWantsToConnectMessage), primaryButton: .default(Text("Accept"), action: {
                    self.multipeerSessionManager.replyToRequest(isAccepted: true)
                }), secondaryButton: .cancel(Text("Decline"), action: {
                    self.multipeerSessionManager.replyToRequest(isAccepted: false)
                }))
            }
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
                    Group {
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
                        Text("Advertise").font(.system(size: 8))
                            .foregroundStyle(.green)
                    }
                    
                }
                ToolbarItem(placement: .topBarLeading) {
                    Group {
                        Button {
                            if multipeerSessionManager.isCurrentlyBrowsing {
                                multipeerSessionManagerBindable.browsedPeers = []
                                multipeerSessionManager.stopBrowsing()
                            } else {
                                //                            multipeerSessionManagerBindable.browsedPeers = []
                                multipeerSessionManager.startBrowsing()
                            }
                            browsingAnimationBool.toggle()
                        } label: {
                            
                            if !isCurrentlyBrowsing() {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.cyan.opacity(0.6), .cyan.opacity(0.3), .cyan.opacity(0.3))
                                    .font(.largeTitle)
                                    .fontWeight(.light)
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
                        Text("Browse").font(.system(size: 8))
                            .foregroundStyle(.cyan)
                    }
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
            .onDisappear {
                self.multipeerSessionManager.stopBrowsing()
                self.multipeerSessionManager.stopAdvertising()
            }
            .onAppear {
                self.reportOnAppear()
                self.multipeerSessionManager.startAdvertising()
                self.multipeerSessionManager.startBrowsing()
            }
            .alert(isPresented: $multipeerSessionManagerBindable.didNotStartBrowsing) {
                Alert(title: Text("Search Error"), message: Text(multipeerSessionManager.startErrorMessage), dismissButton: .default( Text("OK"), action: {
                    self.presentationMode.wrappedValue.dismiss()
                }))
            }
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

