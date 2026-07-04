//
//  PulseIndicator.swift
//  Beginner-Runner-AI-Coach
//
//  Created by Antigravity.
//

import SwiftUI

// MARK: - Pulsing Live State Indicator
public struct PulseIndicator: View {
    public var color: Color
    @State private var animate = false
    
    public init(color: Color = Theme.Colors.primaryContainer) {
        self.color = color
    }
    
    public var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .scaleEffect(animate ? 1.5 : 1.0)
            .opacity(animate ? 0.3 : 1.0)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
                ) {
                    animate = true
                }
            }
    }
}
