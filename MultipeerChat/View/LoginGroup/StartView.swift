//
//  StartView.swift
//  MultipeerChat
//
//  Created by Hesham on 3/9/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

import SwiftUI

struct StartView: View {
    @Environment(LoginViewModel.self) var loginViewModel : LoginViewModel
    
    var body: some View {
        Group {
            if loginViewModel.isLoggedIn {
                AnyView(TabBarView())
                    .environment(MultipeerSessionManager())
            } else {
                AnyView(ProfileSetupView())
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
