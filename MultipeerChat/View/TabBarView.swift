//
//  TabBarView.swift
//  MultipeerChat
//
//  Created by Hesham on 3/9/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

import SwiftUI

struct TabBarView: View {
    @Environment(MultipeerSessionManager.self) var multipeerSessionManager: MultipeerSessionManager
    private let chatsView = ChatsView()
    private let moreView = MoreView()
    var body: some View {
        TabView {
            chatsView
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Chat")
            }
            moreView
                .tabItem {
                    Image(systemName: "ellipsis.circle.fill")
                    Text("More")
            }
        }.onAppear {
            multipeerSessionManager.startBrowsing()
            multipeerSessionManager.startAdvertising()
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
