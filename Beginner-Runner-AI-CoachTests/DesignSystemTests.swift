// swiftlint:disable identifier_name

import Testing
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
@testable import Beginner_Runner_AI_Coach

struct DesignSystemTests {
    
    private struct RGBAComponents {
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double
    }
    
    // MARK: - Helper to extract RGBA components
    private func getRGBA(from color: Color) -> RGBAComponents? {
        #if canImport(UIKit)
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return RGBAComponents(red: Double(r), green: Double(g), blue: Double(b), alpha: Double(a))
        }
        #endif
        return nil
    }
    
    // MARK: - Test Cases
    
    @Test func testHexParsingSixDigits() {
        // Given: A valid 6-digit hex color string representing Neon Green (#A4FF00)
        let hex = "#A4FF00"
        
        // When: Initializing SwiftUI Color from the hex string
        let color = Color(hex: hex)
        
        // Then: The resolved RGBA components should match Red: 164/255, Green: 1.0, Blue: 0.0, Alpha: 1.0
        if let rgba = getRGBA(from: color) {
            #expect(abs(rgba.red - (164.0 / 255.0)) < 0.01)
            #expect(abs(rgba.green - 1.0) < 0.01)
            #expect(rgba.blue == 0.0)
            #expect(rgba.alpha == 1.0)
        } else {
            Issue.record("Failed to resolve UI/CGColor components from SwiftUI Color")
        }
    }
    
    @Test func testHexParsingThreeDigits() {
        // Given: A valid 3-digit hex color string representing white (#F00)
        let hex = "#F00"
        
        // When: Initializing SwiftUI Color from the hex string
        let color = Color(hex: hex)
        
        // Then: The resolved RGBA components should match Red: 1.0, Green: 0.0, Blue: 0.0, Alpha: 1.0
        if let rgba = getRGBA(from: color) {
            #expect(rgba.red == 1.0)
            #expect(rgba.green == 0.0)
            #expect(rgba.blue == 0.0)
            #expect(rgba.alpha == 1.0)
        } else {
            Issue.record("Failed to resolve UI/CGColor components from SwiftUI Color")
        }
    }
    
    @Test func testHexParsingInvalidFallback() {
        // Given: An invalid hex string "invalid_hex"
        let hex = "invalid_hex"
        
        // When: Initializing SwiftUI Color from the invalid hex string
        let color = Color(hex: hex)
        
        // Then: It should fallback to pure black (#000000)
        if let rgba = getRGBA(from: color) {
            #expect(rgba.red == 0.0)
            #expect(rgba.green == 0.0)
            #expect(rgba.blue == 0.0)
            #expect(rgba.alpha == 1.0)
        } else {
            Issue.record("Failed to resolve UI/CGColor components from SwiftUI Color")
        }
    }
}
