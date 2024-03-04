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
    @State var animationBool = false
    @State var loadingState = LoadingState()
    var body: some View {
        NavigationStack {
            @Bindable var multipeerSessionManagerBindable = multipeerSessionManager
            ScrollView(.horizontal) {
                HStack {
                    ForEach(multipeerSessionManager.availableAndConnectingPeers) { browsedPeer in
                        BrowsedPeerCell(browsedPeer: browsedPeer) {
                            self.multipeerSessionManager.peerClicked(browsedPeer: browsedPeer)
                            loadingState.startLoading(withSuccess: self.multipeerSessionManager.couldntConnect)
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
                    
                    Button {
                        if multipeerSessionManager.isCurrentlyAdvertising {
                            multipeerSessionManager.stopAdvertising()
                        } else {
                            multipeerSessionManager.startAdvertising()
                        }
                    } label: {
                        Image(systemName: isCurrentlyAdvertising() ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                            .tint(isCurrentlyAdvertising() ? .white : .red)
                            .symbolEffect(.pulse)
                            .font(.title3)
                            .frame(width: 40, height: 40)
                            .offset(y: isCurrentlyAdvertising() ? 0 : -3)
                            .background {
                                if isCurrentlyAdvertising() {
                                    Image(systemName: "square.fill")
                                        .font(.system(size: 36))
                                        .foregroundStyle(.green)
                                        .symbolEffect(.pulse)
                                } else {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(isCurrentlyAdvertising() ? .green : .red, lineWidth: 1)
                                }
                                
                            }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if multipeerSessionManager.isCurrentlyBrowsing {
                            multipeerSessionManager.stopBrowsing()
                        } else {
                            multipeerSessionManagerBindable.browsedPeers = []
                            multipeerSessionManager.startBrowsing()
                        }
                    } label: {
                        Image(systemName: isCurrentlyBrowsing() ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                            .tint(isCurrentlyBrowsing() ? .white : .red)
                            .symbolEffect(.pulse)
                            .font(.title3)
                            .frame(width: 40, height: 40)
                            .offset(y: isCurrentlyBrowsing() ? 0 : -3)
                            .background {
                                if isCurrentlyBrowsing() {
                                    Image(systemName: "square.fill")
                                        .font(.system(size: 36))
                                        .foregroundStyle(.cyan)
                                        .symbolEffect(.pulse)
                                } else {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(isCurrentlyBrowsing() ? .cyan : .red, lineWidth: 1)
                                }
                                
                            }
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
            .alert(isPresented: $multipeerSessionManagerBindable.shouldShowConnectAlert) {
                Alert(title: Text("Invitation"), message: Text(multipeerSessionManagerBindable.peerWantsToConnectMessage), primaryButton: .default(Text("Accept"), action: {
                    self.multipeerSessionManager.replyToRequest(isAccepted: true)
                }), secondaryButton: .cancel(Text("Decline"), action: {
                    self.multipeerSessionManager.replyToRequest(isAccepted: false)
                }))
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

