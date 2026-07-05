//
//  TelemetryRing.swift
//  Beginner-Runner-AI-Coach
//
//  Created by Antigravity.
//

import SwiftUI

// MARK: - Telemetry Ring / Readiness Indicator
public struct TelemetryRing: View {
    public var progress: Double
    public var score: Int
    public var label: String
    public var metricLabel: String
    
    public init(
        progress: Double,
        score: Int,
        label: String = "OPTIMAL",
        metricLabel: String = "READINESS"
    ) {
        self.progress = progress
        self.score = score
        self.label = label
        self.metricLabel = metricLabel
    }
    
    public var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.white.opacity(0.05), lineWidth: 8)
            
            // Progress active track
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(
                    LinearGradient(
                        colors: [Theme.Colors.neonGreen, Theme.Colors.electricLime],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: -90))
                .neonGlow(color: Theme.Colors.neonGreen, radius: 6)
                .animation(.easeOut(duration: 1.5), value: progress)
            
            // Center Metrics Text
            VStack(spacing: 2) {
                Text(metricLabel.uppercased())
                    .font(Theme.Typography.labelCaps)
                    .kerning(1.2)
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
                
                if score == 0 && progress == 0.0 {
                    Text("--")
                        .font(Theme.Typography.displayMetrics)
                        .foregroundStyle(Theme.Colors.primary)
                } else {
                    Text("\(score)")
                        .font(Theme.Typography.displayMetrics)
                        .foregroundStyle(Theme.Colors.primary)
                }
                
                Text(label.uppercased())
                    .font(Theme.Typography.labelCaps)
                    .kerning(1.2)
                    .foregroundStyle(Theme.Colors.primaryContainer)
            }
        }
        .frame(width: 200, height: 200)
    }
}
