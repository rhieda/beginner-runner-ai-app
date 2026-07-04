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
