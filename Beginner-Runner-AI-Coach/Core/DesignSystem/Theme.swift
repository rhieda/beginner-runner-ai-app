//
//  Theme.swift
//  Beginner-Runner-AI-Coach
//
//  Created by Antigravity.
//

// swiftlint:disable identifier_name

import SwiftUI

public enum Theme {
    /// Vitals Kinetic Color Palette
    public enum Colors {
        // Base canvas
        public static let background = Color(hex: "#000000") // Infinite black canvas
        
        // Surfaces
        public static let surface = Color(hex: "#131315")
        public static let surfaceDim = Color(hex: "#131315")
        public static let surfaceBright = Color(hex: "#39393b")
        public static let surfaceContainerLowest = Color(hex: "#0e0e10")
        public static let surfaceContainerLow = Color(hex: "#1b1b1d")
        public static let surfaceContainer = Color(hex: "#1f1f21")
        public static let surfaceContainerHigh = Color(hex: "#2a2a2c")
        public static let surfaceContainerHighest = Color(hex: "#353437")
        
        // Content
        public static let primary = Color(hex: "#ffffff")
        public static let onSurface = Color(hex: "#e5e1e4")
        public static let onSurfaceVariant = Color(hex: "#c0caad")
        public static let inverseSurface = Color(hex: "#e5e1e4")
        public static let inverseOnSurface = Color(hex: "#303032")
        
        // Outlines
        public static let outline = Color(hex: "#8a947a")
        public static let outlineVariant = Color(hex: "#414a34")
        public static let surfaceTint = Color(hex: "#8ddc00")
        
        // Brand & Accents
        public static let onPrimary = Color(hex: "#203700")
        public static let primaryContainer = Color(hex: "#a1fb00") // Electric Lime/Green Accent
        public static let onPrimaryContainer = Color(hex: "#457000")
        
        public static let secondary = Color(hex: "#ffb4ab") // Secondary accent
        public static let onSecondary = Color(hex: "#690006")
        public static let secondaryContainer = Color(hex: "#d30017") // Pulse Red
        public static let onSecondaryContainer = Color(hex: "#ffe2de")
        
        public static let tertiary = Color(hex: "#ffffff")
        public static let onTertiary = Color(hex: "#00363a")
        public static let tertiaryContainer = Color(hex: "#7df4ff") // Electric Blue
        public static let onTertiaryContainer = Color(hex: "#006f77")
        
        public static let error = Color(hex: "#ffb4ab")
        public static let onError = Color(hex: "#690005")
        public static let errorContainer = Color(hex: "#93000a")
        public static let onErrorContainer = Color(hex: "#ffdad6")
        
        // Cyberpunk/HUD glowing colors
        public static let neonGreen = Color(hex: "#A4FF00")
        public static let electricLime = Color(hex: "#D4FF00")
        public static let dataBlue = Color(hex: "#7DF4FF")
        public static let dataCyan = Color(hex: "#00DBE9")
        
        // Glassmorphic Opacities
        public static let surfaceGlass = Color(red: 28/255, green: 28/255, blue: 30/255).opacity(0.7)
        public static let borderGlass = Color.white.opacity(0.08)
    }
    
    /// Vitals Kinetic Spacing Guidelines
    public enum Spacing {
        public static let unit: CGFloat = 4
        public static let stackGap: CGFloat = 12
        public static let gridGutter: CGFloat = 16
        public static let containerPadding: CGFloat = 20
        public static let sectionMargin: CGFloat = 32
        public static let topBarTitlePadding: CGFloat = 24
    }
    
    /// Vitals Kinetic Corner Radii
    public enum Radius {
        public static let sm: CGFloat = 8
        public static let `default`: CGFloat = 16
        public static let md: CGFloat = 24
        public static let lg: CGFloat = 32
        public static let xl: CGFloat = 48
        public static let full: CGFloat = 9999
    }
    
    /// Vitals Kinetic Typography
    public enum Typography {
        public static let displayMetrics = Font.system(size: 48, weight: .bold, design: .monospaced)
        public static let headlineLg = Font.system(size: 32, weight: .black, design: .default)
        public static let headlineLgMobile = Font.system(size: 28, weight: .black, design: .default)
        public static let headlineMd = Font.system(size: 24, weight: .bold, design: .default)
        public static let bodyLg = Font.system(size: 18, weight: .regular, design: .default)
        public static let bodySm = Font.system(size: 14, weight: .regular, design: .default)
        public static let dataTabular = Font.system(size: 16, weight: .medium, design: .monospaced)
        public static let labelCaps = Font.system(size: 12, weight: .bold, design: .default)
    }
}

// MARK: - Color Hex Extension
extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
