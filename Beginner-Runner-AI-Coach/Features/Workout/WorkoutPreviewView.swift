import SwiftUI

struct WorkoutPreviewView: View {
    @State var store: WorkoutPreviewStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Base background
                Theme.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.sectionMargin) {
                        switch store.state {
                        case .idle:
                            VStack(spacing: 16) {
                                Image(systemName: "figure.run.circle")
                                    .font(.system(size: 60))
                                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
                                Text("No workout available")
                                    .font(Theme.Typography.headlineMd)
                                    .foregroundStyle(Theme.Colors.primary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .glassCard()
                            
                        case .preview(let workout):
                            workoutSections(workout)
                            
                        case .syncing:
                            VStack(spacing: 20) {
                                ProgressView()
                                    .tint(Theme.Colors.primaryContainer)
                                    .scaleEffect(1.3)
                                Text("Syncing with Apple Watch...")
                                    .font(Theme.Typography.bodyLg)
                                    .foregroundStyle(Theme.Colors.onSurface)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .glassCard()
                            
                        case .synced:
                            VStack(spacing: 20) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(Theme.Colors.neonGreen)
                                    .neonGlow(color: Theme.Colors.neonGreen, radius: 10)
                                
                                Text("Workout Scheduled!")
                                    .font(Theme.Typography.headlineMd)
                                    .foregroundStyle(Theme.Colors.primary)
                                
                                Text("Open the Workouts app on your Apple Watch to start.")
                                    .font(Theme.Typography.bodySm)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
                                
                                Button("Close") {
                                    dismiss()
                                }
                                .font(Theme.Typography.bodyLg)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.Colors.primaryContainer)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.full))
                                .foregroundStyle(Theme.Colors.onPrimary)
                                .neonGlow(color: Theme.Colors.primaryContainer, radius: 4)
                                .padding(.top)
                            }
                            .frame(maxWidth: .infinity, minHeight: 300)
                            .glassCard()
                            
                        case .error(let message):
                            VStack(spacing: 20) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(Theme.Colors.secondaryContainer)
                                    .neonGlow(color: Theme.Colors.secondaryContainer, radius: 8)
                                
                                Text(message)
                                    .font(Theme.Typography.bodyLg)
                                    .foregroundStyle(Theme.Colors.primary)
                                    .multilineTextAlignment(.center)
                                
                                Button("Try Again") {
                                    Task { await store.syncToWatch() }
                                }
                                .font(Theme.Typography.bodyLg)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.Colors.surfaceContainerHigh)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.default))
                                .foregroundStyle(Theme.Colors.primary)
                                .padding(.top)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .glassCard()
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.containerPadding)
                    .padding(.vertical, Theme.Spacing.sectionMargin)
                }
            }
            .navigationTitle("Your Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Theme.Colors.onSurfaceVariant)
                }
                
                if case .preview = store.state {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Sync") {
                            Task { await store.syncToWatch() }
                        }
                        .font(Theme.Typography.bodyLg.weight(.bold))
                        .foregroundStyle(Theme.Colors.primaryContainer)
                    }
                }
            }
            .toolbarBackground(Theme.Colors.surfaceGlass, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    private func workoutSections(_ workout: CustomWorkoutComposition) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sectionMargin) {
            
            // Warmup Section
            VStack(alignment: .leading, spacing: Theme.Spacing.stackGap) {
                Text("Warmup".uppercased())
                    .font(Theme.Typography.labelCaps)
                    .kerning(1.2)
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
                    .padding(.horizontal, Theme.Spacing.unit)
                
                AsymmetricWorkoutIntervalRow(
                    title: "Light Jog",
                    categoryLabel: "Warmup",
                    duration: workout.warmup.durationInMinutes,
                    intensity: workout.warmup.intensityLevel ?? .low,
                    icon: "leaf.fill",
                    color: Theme.Colors.tertiaryContainer,
                    iconOnRight: true,
                    isFullWidth: false
                )
            }
            
            // Workout Blocks Section
            VStack(alignment: .leading, spacing: Theme.Spacing.stackGap) {
                Text("Workout Blocks".uppercased())
                    .font(Theme.Typography.labelCaps)
                    .kerning(1.2)
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
                    .padding(.horizontal, Theme.Spacing.unit)
                
                ForEach(0..<workout.blocks.count, id: \.self) { index in
                    let block = workout.blocks[index]
                    VStack(alignment: .leading, spacing: Theme.Spacing.stackGap) {
                        Text("Block \(index + 1)".uppercased())
                            .font(Theme.Typography.labelCaps)
                            .foregroundStyle(Theme.Colors.onSurfaceVariant.opacity(0.6))
                            .padding(.horizontal, Theme.Spacing.unit)
                        
                        AsymmetricWorkoutIntervalRow(
                            title: "Work Phase",
                            categoryLabel: "Work",
                            duration: block.work.durationInMinutes,
                            intensity: block.work.intensityLevel ?? .moderate,
                            icon: "flame.fill",
                            color: Theme.Colors.secondary,
                            iconOnRight: false,
                            isFullWidth: false
                        )
                        
                        AsymmetricWorkoutIntervalRow(
                            title: "Recovery Phase",
                            categoryLabel: "Recovery",
                            duration: block.recovery.durationInMinutes,
                            intensity: block.recovery.intensityLevel ?? .low,
                            icon: "timer",
                            color: Theme.Colors.primaryContainer,
                            iconOnRight: true,
                            isFullWidth: false
                        )
                    }
                    .padding(.bottom, 8)
                }
            }
            
            // Cooldown Section
            VStack(alignment: .leading, spacing: Theme.Spacing.stackGap) {
                Text("Cooldown".uppercased())
                    .font(Theme.Typography.labelCaps)
                    .kerning(1.2)
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
                    .padding(.horizontal, Theme.Spacing.unit)
                
                AsymmetricWorkoutIntervalRow(
                    title: "Slow Walk",
                    categoryLabel: "Cooldown",
                    duration: workout.cooldown.durationInMinutes,
                    intensity: workout.cooldown.intensityLevel ?? .low,
                    icon: "figure.walk",
                    color: Theme.Colors.secondaryContainer,
                    iconOnRight: true,
                    isFullWidth: true
                )
            }
            
            // Send to Watch Button
            Button {
                Task { await store.syncToWatch() }
            } label: {
                HStack {
                    Spacer()
                    Label("Send to Apple Watch", systemImage: "applewatch")
                        .font(Theme.Typography.bodyLg)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()
                .background(Theme.Colors.primaryContainer)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.full))
                .foregroundStyle(Theme.Colors.onPrimary)
                .neonGlow(color: Theme.Colors.primaryContainer, radius: 8)
            }
            .buttonStyle(.plain)
            .padding(.top, 10)
        }
    }
}

// MARK: - Asymmetric Telemetry Interval View
struct AsymmetricWorkoutIntervalRow: View {
    let title: String
    let categoryLabel: String
    let duration: Int
    let intensity: WorkoutIntensity
    let icon: String
    let color: Color
    let iconOnRight: Bool
    let isFullWidth: Bool
    
    var body: some View {
        if isFullWidth {
            fullWidthCard
        } else {
            HStack(spacing: Theme.Spacing.stackGap) {
                if iconOnRight {
                    detailCard
                    iconCard
                } else {
                    iconCard
                    detailCard
                }
            }
        }
    }
    
    private var detailCard: some View {
        HStack(spacing: 0) {
            // Left color-coded indicator border
            Rectangle()
                .fill(color)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(categoryLabel.uppercased())
                    .font(Theme.Typography.labelCaps)
                    .foregroundStyle(color)
                Text(title)
                    .font(Theme.Typography.bodyLg)
                    .fontWeight(.bold)
                    .foregroundStyle(Theme.Colors.primary)
            }
            .padding(.leading, 14)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(duration) Min")
                    .font(Theme.Typography.dataTabular)
                    .foregroundStyle(Theme.Colors.primary)
                Text(intensity.rawValue)
                    .font(Theme.Typography.bodySm)
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
            }
            .padding(.trailing, 16)
        }
        .frame(height: 72)
        .glassCard(cornerRadius: Theme.Radius.sm)
    }
    
    private var iconCard: some View {
        ZStack {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(color)
                .opacity(0.7)
        }
        .frame(width: 72, height: 72)
        .glassCard(cornerRadius: Theme.Radius.sm)
    }
    
    private var fullWidthCard: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(color)
                .frame(width: 4)
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(color)
                }
                .padding(.leading, 12)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(categoryLabel.uppercased())
                        .font(Theme.Typography.labelCaps)
                        .foregroundStyle(color)
                    Text(title)
                        .font(Theme.Typography.bodyLg)
                        .fontWeight(.bold)
                        .foregroundStyle(Theme.Colors.primary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(duration) Min")
                    .font(Theme.Typography.dataTabular)
                    .foregroundStyle(Theme.Colors.primary)
                Text(intensity.rawValue)
                    .font(Theme.Typography.bodySm)
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
            }
            .padding(.trailing, 16)
        }
        .frame(height: 72)
        .glassCard(cornerRadius: Theme.Radius.sm)
    }
}

#Preview {
    WorkoutPreviewView(store: {
        let store = WorkoutPreviewStore()
        store.setWorkout(CustomWorkoutComposition(
            warmup: .init(durationInMinutes: 5, intensityLevel: .low),
            blocks: [
                .init(
                    work: .init(durationInMinutes: 3, intensityLevel: .moderate),
                    recovery: .init(durationInMinutes: 2, intensityLevel: .low)
                ),
                .init(
                    work: .init(durationInMinutes: 3, intensityLevel: .moderate),
                    recovery: .init(durationInMinutes: 2, intensityLevel: .low)
                )
            ],
            cooldown: .init(durationInMinutes: 5, intensityLevel: .low)
        ))
        return store
    }())
}
