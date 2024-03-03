//
//  MainView.swift
//  MultipeerChat
//
//  Created by Hesham on 3/9/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

import SwiftUI
import Observation

struct MainView: View {
    @Environment(AdvertiserViewModel.self) var advertiserVM: AdvertiserViewModel
    @State private var actionSheetShown = false
    @State private var chatsViewModel = ChatsViewModel()
    @State var animationBool = false
    var body: some View {
        NavigationStack {
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
                            
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    self.chatsViewModel.updatePeers()
                }
            }
            .navigationBarTitle("Chats")
            .onChange(of: advertiserVM.isCurrentlyAdvertising) { oldValue, newValue in
                if oldValue {
                    advertiserVM.stopAdvertising()
                }
                if newValue {
                    advertiserVM.startAdvertising()
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
                        if advertiserVM.isCurrentlyAdvertising {
                            advertiserVM.stopAdvertising()
                        } else {
                            advertiserVM.startAdvertising()
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
            .onAppear {
                self.reportOnAppear()
            }
            .confirmationDialog("Choose an Option", isPresented: $actionSheetShown) {
                NavigationLink("Host a session") {
                    AdvertiserView()
                }
                NavigationLink("Join a session") {
                    BrowserView()
                }
            } message: {
                Text("Choose an Option")
            }
        }
    }
    
    
    
    func isCurrentlyAdvertising() -> Bool {
        return advertiserVM.isCurrentlyAdvertising
    }
    
    func reportOnAppear() {
        print("Reloading peers")
        self.chatsViewModel.updatePeers()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
