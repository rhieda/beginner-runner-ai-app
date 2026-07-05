# SwiftUI Component Code Templates

This reference provides production-ready SwiftUI templates implementing the Vitals Kinetic styling.

## 1. Glassmorphic Card Container

Use the `.glassCard()` modifier to wrap content sections.

```swift
import SwiftUI

struct StatGlassCard: View {
    let title: String
    let value: String
    let unit: String
    let statusColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.unit * 2) {
            HStack {
                Text(title.uppercased())
                    .font(Theme.Typography.labelCaps)
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
                    .kerning(1.2)
                Spacer()
                PulseIndicator(color: statusColor)
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(Theme.Typography.displayMetrics)
                    .foregroundStyle(Theme.Colors.primary)
                
                Text(unit.lowercased())
                    .font(Theme.Typography.bodySm)
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
            }
        }
        .padding(Theme.Spacing.containerPadding)
        .glassCard()
    }
}
```

## 2. Pill-shaped Action Button

Primary buttons use a full corner radius, electric background accent colors, and dark text.

```swift
import SwiftUI

struct ActionButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(Theme.Typography.labelCaps)
                .kerning(1.5)
                .foregroundStyle(Theme.Colors.onPrimary)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Theme.Colors.neonGreen, Theme.Colors.electricLime],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .neonGlow(color: Theme.Colors.neonGreen, radius: 8)
        }
    }
}
```

## 3. Horizontal Telemetry Row

Used for lists of historical records, activities, or raw biometric streams.

```swift
import SwiftUI

struct TelemetryRow: View {
    let title: String
    let subtitle: String
    let metric: String
    let iconName: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.gridGutter) {
            // Icon squircle container
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.Colors.primaryContainer)
                .frame(width: 40, height: 40)
                .background(Theme.Colors.primaryContainer.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.bodyLg)
                    .foregroundStyle(Theme.Colors.primary)
                Text(subtitle)
                    .font(Theme.Typography.bodySm)
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
            }
            
            Spacer()
            
            Text(metric)
                .font(Theme.Typography.dataTabular)
                .foregroundStyle(Theme.Colors.primaryContainer)
        }
        .padding(Theme.Spacing.stackGap)
        .glassCard(cornerRadius: Theme.Radius.sm)
    }
}
```

## 4. TelemetryRing Usage

How to integrate the standard readiness/stress ring:

```swift
import SwiftUI

struct DiagnosticsOverviewView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.sectionMargin) {
            // Primary telemetry focus
            TelemetryRing(
                progress: 0.85,
                score: 85,
                label: "Optimal",
                metricLabel: "Readiness"
            )
            .padding(.top, Theme.Spacing.sectionMargin)
            
            // Secondary cards
            HStack(spacing: Theme.Spacing.gridGutter) {
                StatGlassCard(title: "HRV", value: "72", unit: "ms", statusColor: Theme.Colors.neonGreen)
                StatGlassCard(title: "RHR", value: "58", unit: "bpm", statusColor: Theme.Colors.dataBlue)
            }
            .padding(.horizontal, Theme.Spacing.containerPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
    }
}
```

## 5. Modular Telemetry Status Row

For displaying user states or category details (e.g. Fitness State, Recovery State) without triggering SwiftLint parameter limits:

```swift
import SwiftUI

struct TelemetryStatusRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trendIcon: String
    let trendColor: Color
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.labelCaps)
                    .font(.system(size: 9))
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
                Text(value)
                    .font(Theme.Typography.bodyLg)
                    .fontWeight(.bold)
                    .foregroundStyle(Theme.Colors.primary)
            }
            .padding(.leading, 10)
            
            Spacer()
            
            Image(systemName: trendIcon)
                .foregroundStyle(trendColor)
        }
        .padding()
        .glassCard()
    }
}
```

## 6. HUD Sparkline Chart View

Use this to draw lightweight, high-fidelity SVG-like line graphs with neon glows, background linear gradients, min/max metrics, and trend indicators:

```swift
import SwiftUI

struct HUDSparklineChartView: View {
    let data: [Double]
    let title: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.unit * 2) {
            // Header: Title & Trend Icon
            HStack {
                Text(title.uppercased())
                    .font(Theme.Typography.labelCaps)
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
                
                Spacer()
                
                Image(systemName: "trending.up")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color)
            }
            
            // The Line Chart
            GeometryReader { geometry in
                ZStack {
                    // Fill gradient under path
                    SparklineShape(data: data)
                        .path(in: CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height))
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.2), color.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // The glowing line path
                    SparklineShape(data: data)
                        .stroke(color, lineWidth: 2)
                        .neonGlow(color: color, radius: 4)
                }
            }
            .frame(height: 50)
            
            // Footer: Stats & Averages
            HStack {
                Text("MIN: \(Int(data.min() ?? 0))")
                Spacer()
                Text("MAX: \(Int(data.max() ?? 0))")
            }
            .font(Theme.Typography.dataTabular)
            .font(.system(size: 9))
            .foregroundStyle(Theme.Colors.onSurfaceVariant)
        }
        .padding(Theme.Spacing.gridGutter)
        .glassCard()
    }
}

// Shape used to plot points relative to geometry bounds
struct SparklineShape: Shape {
    let data: [Double]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard data.count > 1 else { return path }
        
        let minVal = data.min() ?? 0.0
        let maxVal = data.max() ?? 1.0
        let range = maxVal - minVal > 0 ? maxVal - minVal : 1.0
        
        let stepX = rect.width / CGFloat(data.count - 1)
        
        for index in 0..<data.count {
            let val = data[index]
            let normalizedY = (val - minVal) / range
            let pt = CGPoint(
                x: CGFloat(index) * stepX,
                y: rect.height - (CGFloat(normalizedY) * rect.height)
            )
            
            if index == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        return path
    }
}
```

