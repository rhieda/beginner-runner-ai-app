//
//  ViewModifiers.swift
//  Beginner-Runner-AI-Coach
//
//  Created by Antigravity.
//

import SwiftUI

// MARK: - Glassmorphic Card View Modifier
public struct GlassCardModifier: ViewModifier {
    public var cornerRadius: CGFloat
    
    public init(cornerRadius: CGFloat = Theme.Radius.default) {
        self.cornerRadius = cornerRadius
    }
    
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Theme.Colors.surfaceGlass)
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Theme.Colors.borderGlass, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    /// Wraps a view in a glassmorphic container with frosted backdrop blur and custom border outlines.
    public func glassCard(cornerRadius: CGFloat = Theme.Radius.default) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Neon Glow View Modifier
public struct NeonGlowModifier: ViewModifier {
    public var color: Color
    public var radius: CGFloat
    
    public init(color: Color = Theme.Colors.primaryContainer, radius: CGFloat = 8) {
        self.color = color
        self.radius = radius
    }
    
    public func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.4), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.2), radius: radius * 2, x: 0, y: 0)
    }
}

extension View {
    /// Applies a multi-layered neon glow drop-shadow effect to the view.
    public func neonGlow(color: Color = Theme.Colors.primaryContainer, radius: CGFloat = 8) -> some View {
        self.modifier(NeonGlowModifier(color: color, radius: radius))
    }
}
