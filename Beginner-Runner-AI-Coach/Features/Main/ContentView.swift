//
//  ContentView.swift
//  Beginner-Runner-AI-Coach
//
//  Created by rafael hieda on 10/04/26.
//

import SwiftUI

struct ContentView: View {
    @State var i: Int = 0
    @State var path = NavigationPath()
    @State var shouldPresentSheet = false

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: Theme.Spacing.sectionMargin) {
                    Spacer()
                    
                    // Brand / Telemetry Suite Title
                    VStack(spacing: 8) {
                        Image(systemName: "bolt.heart.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Theme.Colors.neonGreen)
                            .neonGlow(color: Theme.Colors.neonGreen, radius: 10)
                        
                        Text("VITALS KINETIC")
                            .font(Theme.Typography.headlineLg)
                            .kerning(2.0)
                            .foregroundStyle(Theme.Colors.primary)
                        
                        Text("BIO-ANALYTICAL TELEMETRY")
                            .font(Theme.Typography.labelCaps)
                            .kerning(1.5)
                            .foregroundStyle(Theme.Colors.onSurfaceVariant)
                    }
                    
                    Spacer()
                    
                    // Developer Menu Container
                    VStack(spacing: Theme.Spacing.stackGap) {
                        NavigationLink(value: "sandbox") {
                            HStack {
                                Label("Open Provider Sandbox", systemImage: "testtube.2")
                                    .font(Theme.Typography.bodyLg)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Theme.Colors.primaryContainer)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
                            }
                            .padding()
                            .glassCard(cornerRadius: Theme.Radius.default)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        Text("DEVELOPER TESTING SUITE")
                            .font(Theme.Typography.labelCaps)
                            .kerning(1.0)
                            .foregroundStyle(Theme.Colors.onSurfaceVariant.opacity(0.6))
                    }
                    .padding(.horizontal, Theme.Spacing.containerPadding)
                    .padding(.bottom, 40)
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "sandbox" {
                    SandboxView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("CONSOLE")
                        .font(Theme.Typography.labelCaps)
                        .kerning(2.0)
                        .foregroundStyle(Theme.Colors.primary)
                }
            }
            .toolbarBackground(Theme.Colors.surfaceGlass, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
