//
//  AdvertiserView.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 3/20/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

import SwiftUI

struct AdvertiserView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @State private var isAnimating = true
    @Environment(MultipeerSessionManager.self) var multipeerSessionManager: MultipeerSessionManager
    
    var body: some View {
        VStack {
            @Bindable var multipeerSessionManagerBindable = multipeerSessionManager
            ActivityIndicator(style: .large, animate: $isAnimating)
                .alert(isPresented: $multipeerSessionManagerBindable.shouldShowConnectAlert) {
                    Alert(title: Text("Invitation"), message: Text(multipeerSessionManagerBindable.peerWantsToConnectMessage), primaryButton: .default(Text("Accept"), action: {
                        self.multipeerSessionManager.replyToRequest(isAccepted: true)
                    }), secondaryButton: .cancel(Text("Decline"), action: {
                        self.multipeerSessionManager.replyToRequest(isAccepted: false)
                    }))
            }
            Text("Waiting for peers...")
                .alert(isPresented: $multipeerSessionManagerBindable.didNotStartAdvertising) {
                    Alert(title: Text("Hosting Error"),
                          message: Text(multipeerSessionManager.startErrorMessage),
                          dismissButton: .default( Text("OK"), action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }))
            }
            EmptyView().alert(isPresented: $multipeerSessionManagerBindable.showPeerConnectedAlert) {
                Alert(title: Text(""),
                      message: Text(multipeerSessionManager.peerConnectedSuccessfully),
                      dismissButton: .default( Text("OK")))
            }
        }.navigationBarTitle(Text("Hosting"))
        
    }
}

struct AdvertiserView_Previews: PreviewProvider {
    static var previews: some View {
        AdvertiserView()
    }
}
