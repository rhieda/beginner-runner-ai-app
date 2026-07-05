//
//  SparklineChartView.swift
//  Beginner-Runner-AI-Coach
//
//  Created by Antigravity.
//

import SwiftUI

public struct SparklineChartView: View {
    public let data: [Double]
    public let title: String
    public let unit: String
    public let color: Color
    
    public init(
        data: [Double],
        title: String,
        unit: String,
        color: Color = Theme.Colors.neonGreen
    ) {
        self.data = data
        self.title = title
        self.unit = unit
        self.color = color
    }
    
    private var maxVal: Double { data.max() ?? 0 }
    private var minVal: Double { data.min() ?? 0 }
    private var avgVal: Double {
        data.isEmpty ? 0 : data.reduce(0, +) / Double(data.count)
    }
    
    private var trendDirection: TrendDirection {
        guard data.count >= 2 else { return .stable }
        let first = data[0]
        let last = data[data.count - 1]
        if last > first { return .up }
        if last < first { return .down }
        return .stable
    }
    
    enum TrendDirection {
        case up, down, stable
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text("\(title) (\(unit))")
                    .font(Theme.Typography.labelCaps)
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
                
                Spacer()
                
                Text("7-DIA")
                    .font(Theme.Typography.labelCaps)
                    .foregroundStyle(color)
            }
            
            // Sparkline Graph
            ZStack {
                if data.count >= 2 {
                    // Gradient Fill Area
                    SparklineShape(data: data, isClosed: true)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Line Path
                    SparklineShape(data: data, isClosed: false)
                        .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        .neonGlow(color: color, radius: 4)
                    
                    // Max/Min Badges
                    VStack {
                        HStack {
                            Spacer()
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 4, height: 4)
                                Text("MAX: \(Int(maxVal))")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(color)
                            }
                            .padding(.top, 2)
                            .padding(.trailing, 8)
                        }
                        
                        Spacer()
                        
                        HStack {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Theme.Colors.onSurfaceVariant.opacity(0.4))
                                    .frame(width: 4, height: 4)
                                Text("MIN: \(Int(minVal))")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(Theme.Colors.onSurfaceVariant.opacity(0.6))
                            }
                            .padding(.bottom, 4)
                            .padding(.leading, 8)
                            Spacer()
                        }
                    }
                    .pointerEvents(false)
                } else {
                    // Empty/Insufficient data state line
                    LinePlaceholder()
                        .stroke(Theme.Colors.onSurfaceVariant.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [4]))
                    
                    Text("Sem dados")
                        .font(Theme.Typography.bodySm)
                        .foregroundStyle(Theme.Colors.onSurfaceVariant)
                }
            }
            .frame(height: 40)
            
            // Footer
            HStack {
                Text("MÉD: \(Int(avgVal))")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color)
                
                Spacer()
                
                Image(systemName: trendIconName)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
            }
        }
        .padding(Theme.Spacing.gridGutter)
        .glassCard(cornerRadius: Theme.Radius.sm)
    }
    
    private var trendIconName: String {
        switch trendDirection {
        case .up: return "trending.up"
        case .down: return "trending.down"
        case .stable: return "minus"
        }
    }
}

// MARK: - Sparkline Shape
struct SparklineShape: Shape {
    let data: [Double]
    let isClosed: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard data.count >= 2 else { return path }
        
        let minVal = data.min() ?? 0
        let maxVal = data.max() ?? 0
        let delta = maxVal - minVal
        
        let stepX = rect.width / CGFloat(data.count - 1)
        
        var points: [CGPoint] = []
        for index in 0..<data.count {
            let x = CGFloat(index) * stepX
            let normalizedValue = delta == 0 ? 0.5 : (data[index] - minVal) / delta
            // Invert Y coordinate since SwiftUI y=0 is at the top
            // Leave a 5px padding at top and bottom to prevent clipping
            let y = rect.height - (CGFloat(normalizedValue) * (rect.height - 10) + 5)
            points.append(CGPoint(x: x, y: y))
        }
        
        path.move(to: points[0])
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        
        if isClosed {
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
        }
        
        return path
    }
}

// MARK: - Line Placeholder
struct LinePlaceholder: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height / 2))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height / 2))
        return path
    }
}

// MARK: - View Extension for pointer events
extension View {
    @ViewBuilder
    func pointerEvents(_ enabled: Bool) -> some View {
        if #available(iOS 15.0, *) {
            self.allowsHitTesting(enabled)
        } else {
            self
        }
    }
}

#Preview {
    HStack {
        SparklineChartView(
            data: [65.0, 72.0, 68.0, 75.0, 70.0, 80.0, 74.0],
            title: "HRV",
            unit: "ms",
            color: Theme.Colors.neonGreen
        )
        SparklineChartView(
            data: [54.0, 52.0, 55.0, 50.0, 51.0, 49.0, 52.0],
            title: "RHR",
            unit: "bpm",
            color: Theme.Colors.dataCyan
        )
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
