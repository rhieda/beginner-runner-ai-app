import SwiftUI

struct SandboxView: View {
    @State private var store = SandboxStore()
    @State private var isShowingWorkoutPreview = false
    
    var body: some View {
        ZStack {
            // Dark canvas background
            Theme.Colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Theme.Spacing.sectionMargin) {
                    
                    // SECTION 1: HealthKit Authorization
                    VStack(alignment: .leading, spacing: Theme.Spacing.stackGap) {
                        HStack(spacing: 8) {
                            PulseIndicator(color: Theme.Colors.primaryContainer)
                            Text("HealthKit Authorization".uppercased())
                                .font(Theme.Typography.labelCaps)
                                .kerning(1.2)
                                .foregroundStyle(Theme.Colors.onSurfaceVariant)
                        }
                        .padding(.horizontal, Theme.Spacing.unit)
                        
                        VStack(spacing: 0) {
                            Button {
                                Task { await store.authorize() }
                            } label: {
                                HStack {
                                    Label("Request Permissions", systemImage: "lock.shield")
                                        .font(Theme.Typography.bodyLg)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .padding()
                                .foregroundStyle(Theme.Colors.primaryContainer)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                        .glassCard(cornerRadius: Theme.Radius.default)
                    }
                    
                    // SECTION 2: AI Orchestrator
                    VStack(alignment: .leading, spacing: Theme.Spacing.stackGap) {
                        HStack(spacing: 8) {
                            PulseIndicator(color: Theme.Colors.primaryContainer)
                            Text("AI Orchestrator".uppercased())
                                .font(Theme.Typography.labelCaps)
                                .kerning(1.2)
                                .foregroundStyle(Theme.Colors.onSurfaceVariant)
                        }
                        .padding(.horizontal, Theme.Spacing.unit)
                        
                        VStack(spacing: Theme.Spacing.stackGap) {
                            HStack {
                                Text("LLM Provider")
                                    .font(Theme.Typography.bodyLg)
                                    .foregroundStyle(Theme.Colors.onSurface)
                                Spacer()
                                Picker("LLM Provider", selection: $store.selectedLLMProvider) {
                                    ForEach(LLMProviderType.allCases) { type in
                                        Text(type.rawValue).tag(type)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Theme.Colors.primaryContainer)
                            }
                            .padding(.horizontal, 4)
                            
                            Divider()
                                .background(Theme.Colors.borderGlass)
                            
                            Button {
                                Task { await store.testAIAgents() }
                            } label: {
                                HStack {
                                    Label("Run Multi-Agent Pipeline", systemImage: "cpu")
                                        .font(Theme.Typography.bodyLg)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 14))
                                }
                                .padding()
                                .background(Theme.Colors.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                                .foregroundStyle(Theme.Colors.primaryContainer)
                            }
                            .buttonStyle(.plain)
                            
                            if store.generatedWorkout != nil {
                                Button {
                                    isShowingWorkoutPreview = true
                                } label: {
                                    HStack {
                                        Label("Preview Generated Workout", systemImage: "eye")
                                            .font(Theme.Typography.bodyLg)
                                            .fontWeight(.bold)
                                        Spacer()
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    .padding()
                                    .background(Theme.Colors.primaryContainer)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                                    .foregroundStyle(Theme.Colors.onPrimary)
                                    .neonGlow(color: Theme.Colors.primaryContainer, radius: 4)
                                }
                                .buttonStyle(.plain)
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding()
                        .glassCard(cornerRadius: Theme.Radius.default)
                    }
                    
                    // SECTION 3: Simulated Biometrics (Dev Tools)
                    VStack(alignment: .leading, spacing: Theme.Spacing.stackGap) {
                        HStack(spacing: 8) {
                            PulseIndicator(color: Theme.Colors.secondaryContainer)
                            Text("Simulated Biometrics (Dev Tools)".uppercased())
                                .font(Theme.Typography.labelCaps)
                                .kerning(1.2)
                                .foregroundStyle(Theme.Colors.onSurfaceVariant)
                        }
                        .padding(.horizontal, Theme.Spacing.unit)
                        
                        VStack(spacing: Theme.Spacing.stackGap * 1.5) {
                            Toggle(isOn: $store.useSimulatedMetrics) {
                                Text("Use Simulated Data")
                                    .font(Theme.Typography.bodyLg)
                                    .foregroundStyle(Theme.Colors.onSurface)
                            }
                            .tint(Theme.Colors.primaryContainer)
                            .disabled(store.selectedLLMProvider == .mock)
                            
                            Divider()
                                .background(Theme.Colors.borderGlass)
                            
                            // Simulated TRIMP Slider
                            VStack(alignment: .leading, spacing: Theme.Spacing.unit * 2) {
                                HStack {
                                    Text("Simulated TRIMP")
                                        .font(Theme.Typography.bodySm)
                                        .foregroundStyle(Theme.Colors.onSurface)
                                    Spacer()
                                    Text(String(format: "%.1f", store.simulatedTrimp))
                                        .font(Theme.Typography.dataTabular)
                                        .foregroundStyle(Theme.Colors.primaryContainer)
                                }
                                Slider(value: $store.simulatedTrimp, in: 0...200, step: 0.5)
                                    .tint(Theme.Colors.primaryContainer)
                            }
                            
                            // Simulated 7d HRV Slider
                            VStack(alignment: .leading, spacing: Theme.Spacing.unit * 2) {
                                HStack {
                                    Text("Simulated 7d HRV")
                                        .font(Theme.Typography.bodySm)
                                        .foregroundStyle(Theme.Colors.onSurface)
                                    Spacer()
                                    Text(String(format: "%.0f ms", store.simulatedSevenDayHRV))
                                        .font(Theme.Typography.dataTabular)
                                        .foregroundStyle(Theme.Colors.primaryContainer)
                                }
                                Slider(value: $store.simulatedSevenDayHRV, in: 10...150, step: 1)
                                    .tint(Theme.Colors.primaryContainer)
                            }
                            
                            // Simulated 30d HRV Slider
                            VStack(alignment: .leading, spacing: Theme.Spacing.unit * 2) {
                                HStack {
                                    Text("Simulated 30d HRV")
                                        .font(Theme.Typography.bodySm)
                                        .foregroundStyle(Theme.Colors.onSurface)
                                    Spacer()
                                    Text(String(format: "%.0f ms", store.simulatedThirtyDayHRV))
                                        .font(Theme.Typography.dataTabular)
                                        .foregroundStyle(Theme.Colors.primaryContainer)
                                }
                                Slider(value: $store.simulatedThirtyDayHRV, in: 10...150, step: 1)
                                    .tint(Theme.Colors.primaryContainer)
                            }
                            
                            Divider()
                                .background(Theme.Colors.borderGlass)
                            
                            HStack {
                                Text("User Goal")
                                    .font(Theme.Typography.bodySm)
                                    .foregroundStyle(Theme.Colors.onSurface)
                                Spacer()
                                TextField("Goal description", text: $store.simulatedUserGoal)
                                    .multilineTextAlignment(.trailing)
                                    .font(Theme.Typography.bodySm)
                                    .textFieldStyle(.plain)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Theme.Colors.surfaceContainerLowest)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.Radius.sm)
                                            .stroke(Theme.Colors.borderGlass, lineWidth: 1)
                                    )
                                    .frame(width: 180)
                            }
                        }
                        .padding()
                        .glassCard(cornerRadius: Theme.Radius.default)
                    }
                    
                    // SECTION 4: Data Provider Tests
                    VStack(alignment: .leading, spacing: Theme.Spacing.stackGap) {
                        HStack(spacing: 8) {
                            PulseIndicator(color: Theme.Colors.tertiaryContainer)
                            Text("Data Provider Tests".uppercased())
                                .font(Theme.Typography.labelCaps)
                                .kerning(1.2)
                                .foregroundStyle(Theme.Colors.onSurfaceVariant)
                        }
                        .padding(.horizontal, Theme.Spacing.unit)
                        
                        VStack(spacing: Theme.Spacing.stackGap) {
                            Button {
                                Task { await store.testHRV() }
                            } label: {
                                HStack {
                                    Label("Test HRV (30 days)", systemImage: "waveform.path.ecg")
                                        .font(Theme.Typography.bodyLg)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 12))
                                }
                                .padding()
                                .background(Theme.Colors.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                                .foregroundStyle(Theme.Colors.tertiaryContainer)
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                Task { await store.testRHR() }
                            } label: {
                                HStack {
                                    Label("Test RHR (7 days)", systemImage: "heart.fill")
                                        .font(Theme.Typography.bodyLg)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 12))
                                }
                                .padding()
                                .background(Theme.Colors.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                                .foregroundStyle(Theme.Colors.secondary)
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                Task { await store.testWorkouts() }
                            } label: {
                                HStack {
                                    Label("Test Workouts & TRIMP", systemImage: "figure.run")
                                        .font(Theme.Typography.bodyLg)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 12))
                                }
                                .padding()
                                .background(Theme.Colors.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                                .foregroundStyle(Theme.Colors.primaryContainer)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding()
                        .glassCard(cornerRadius: Theme.Radius.default)
                    }
                    
                    // SECTION 5: Log Terminal
                    VStack(spacing: Theme.Spacing.stackGap) {
                        HStack {
                            Text("Logs".uppercased())
                                .font(Theme.Typography.labelCaps)
                                .kerning(1.2)
                                .foregroundStyle(Theme.Colors.primary)
                            Spacer()
                            if !store.logs.isEmpty {
                                Button("Clear") {
                                    store.clearLogs()
                                }
                                .font(Theme.Typography.labelCaps)
                                .foregroundStyle(Theme.Colors.secondary)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.unit)
                        
                        VStack {
                            ScrollViewReader { proxy in
                                ScrollView {
                                    LazyVStack(alignment: .leading, spacing: 6) {
                                        if store.logs.isEmpty {
                                            Text("No logs yet. Tap a button above.")
                                                .font(Theme.Typography.bodySm)
                                                .foregroundStyle(Theme.Colors.onSurfaceVariant)
                                                .italic()
                                        } else {
                                            ForEach(store.logs) { log in
                                                HStack(alignment: .top, spacing: 8) {
                                                    Text(log.timestamp.formatted(date: .omitted, time: .standard))
                                                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                                        .foregroundStyle(Theme.Colors.onSurfaceVariant.opacity(0.5))
                                                    
                                                    Text(log.text)
                                                        .font(.system(size: 11, design: .monospaced))
                                                        .foregroundStyle(logColor(for: log.text))
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                                .id(log.id)
                                            }
                                        }
                                    }
                                    .padding(8)
                                }
                                .onChange(of: store.logs.count) {
                                    if let lastLog = store.logs.last {
                                        withAnimation {
                                            proxy.scrollTo(lastLog.id, anchor: .bottom)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(height: 180)
                        .background(Theme.Colors.surfaceContainerLowest)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.sm)
                                .stroke(Theme.Colors.borderGlass, lineWidth: 1)
                        )
                    }
                    .padding()
                    .glassCard(cornerRadius: Theme.Radius.default)
                }
                .padding(.horizontal, Theme.Spacing.containerPadding)
                .padding(.vertical, Theme.Spacing.sectionMargin)
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Provider Sandbox")
        .sheet(isPresented: $isShowingWorkoutPreview) {
            if let workout = store.generatedWorkout {
                WorkoutPreviewView(store: {
                    let previewStore = WorkoutPreviewStore()
                    previewStore.setWorkout(workout)
                    return previewStore
                }())
            }
        }
    }
    
    private func logColor(for text: String) -> Color {
        if text.contains("⚠️") {
            return Theme.Colors.secondaryContainer
        } else if text.contains("✅") {
            return Theme.Colors.neonGreen
        } else if text.contains("🤖") || text.contains("🛡️") {
            return Theme.Colors.primaryContainer
        }
        return Theme.Colors.onSurfaceVariant
    }
}

#Preview {
    NavigationStack {
        SandboxView()
    }
}
