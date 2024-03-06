//
//  LoadingView.swift
//  MultipeerChat
//
//  Created by Riley Calkins on 3/3/24.
//  Copyright © 2024 Hesham Salama. All rights reserved.
//

import Combine
import SwiftUI
import Observation


struct CircularProgressView: View {
    var progress: CGFloat
    var body: some View {
        if progress < 10 {
            ZStack {
                Circle()
                    .stroke(lineWidth: 20.0)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)

                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .butt, lineJoin: .miter))
                    .foregroundColor(Color.blue)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear(duration: 10))
            }
            .frame(width: 100, height: 100)
        }
        
    }
}

@Observable
class LoadingState {
    var isActive: Bool = false
    var progress: CGFloat = 0
    var cancellables: Set<AnyCancellable> = []

    func startLoading(withSuccess success: Bool) {
        isActive = true
        progress = 0
        
        Timer.publish(every: 1 / 10, on: .main, in: .common)
            .autoconnect()
            .prefix(10) // Runs for 10 seconds
            .sink { [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
                    self?.isActive = false
                    self?.progress = 0
                }
            } receiveValue: { [weak self] _ in
                guard let self = self, self.progress < 1 else { return }
                self.progress += 1
            }
            .store(in: &cancellables)
    }
}

struct LoadingViewModifier: ViewModifier {
    var loadingState: LoadingState

    func body(content: Content) -> some View {
        content.overlay(
            Group {
                if loadingState.isActive {
                    CircularProgressView(progress: loadingState.progress) // Always full circle
                        .frame(width: 100, height: 100)
                }
            }
        )
    }
}

extension View {
    func loadingView(loadingState: LoadingState) -> some View {
        self.modifier(LoadingViewModifier(loadingState: loadingState))
    }
}



