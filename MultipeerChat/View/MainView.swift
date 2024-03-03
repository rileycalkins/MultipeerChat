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
    
    @State private var actionSheetShown = false
    @State private var chatsViewModel = ChatsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(chatsViewModel.peers) { peer in
                        let chatroomViewDestination = ChatroomView(multipeerUser: peer)
                        NavigationLink(destination: chatroomViewDestination) {
                            PeerChatCell(multipeerUser: peer, sessionActive: SessionManager.shared.getMutualSession(with: chatroomViewDestination.companion.mcPeerID) != nil)
                        }
                    }.onDelete { indexSet in
                        indexSet.forEach { index in
                            self.chatsViewModel.peerRemoved(at: index)
                            
                        }
                    }
                }.refreshable {
                    self.chatsViewModel.updatePeers()
                }
            }
            .navigationBarTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let profilePic = UserMP.shared.profilePicture {
                        Image(uiImage: profilePic)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(.circle)
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
