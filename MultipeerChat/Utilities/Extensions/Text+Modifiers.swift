//
//  Text+Modifiers.swift
//  MultipeerChat
//
//  Created by Riley Calkins on 3/5/24.
//  Copyright © 2024 Hesham Salama. All rights reserved.
//

import Foundation
import SwiftUI

struct PeerSectionHeaderViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textCase(.uppercase)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.leading)
        
    }
}

extension Text {
    func peerSectionText() -> some View {
        self.modifier(PeerSectionHeaderViewModifier())
    }
}
