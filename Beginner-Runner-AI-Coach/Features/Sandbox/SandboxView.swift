import SwiftUI

struct SandboxView: View {
    @State private var store = SandboxStore()
    @State private var isShowingWorkoutPreview = false
    
    var body: some View {
        List {
            Section("HealthKit Authorization") {
                Button {
                    Task { await store.authorize() }
                } label: {
                    Label("Request Permissions", systemImage: "lock.shield")
                }
            }
            
            Section("AI Orchestrator") {
                Picker("LLM Provider", selection: $store.selectedLLMProvider) {
                    ForEach(LLMProviderType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)

                Button {
                    Task { await store.testAIAgents() }
                } label: {
                    Label("Run Multi-Agent Pipeline", systemImage: "cpu")
                }
                
                if let workout = store.generatedWorkout {
                    Button {
                        isShowingWorkoutPreview = true
                    } label: {
                        Label("Preview Generated Workout", systemImage: "eye")
                    }
                    .foregroundStyle(.blue)
                }
            }
            
            Section("Simulated Biometrics (Dev Tools)") {
                Toggle("Use Simulated Data", isOn: $store.useSimulatedMetrics)
                    .disabled(store.selectedLLMProvider == .mock)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Simulated TRIMP")
                        Spacer()
                        Text(String(format: "%.1f", store.simulatedTrimp))
                            .foregroundStyle(.secondary)
                            .font(.system(.body, design: .monospaced))
                    }
                    Slider(value: $store.simulatedTrimp, in: 0...200, step: 0.5)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Simulated 7d HRV")
                        Spacer()
                        Text(String(format: "%.0f ms", store.simulatedSevenDayHRV))
                            .foregroundStyle(.secondary)
                            .font(.system(.body, design: .monospaced))
                    }
                    Slider(value: $store.simulatedSevenDayHRV, in: 10...150, step: 1)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Simulated 30d HRV")
                        Spacer()
                        Text(String(format: "%.0f ms", store.simulatedThirtyDayHRV))
                            .foregroundStyle(.secondary)
                            .font(.system(.body, design: .monospaced))
                    }
                    Slider(value: $store.simulatedThirtyDayHRV, in: 10...150, step: 1)
                }
                
                HStack {
                    Text("User Goal")
                    Spacer()
                    TextField("Goal description", text: $store.simulatedUserGoal)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            Section("Data Provider Tests") {
                Button {
                    Task { await store.testHRV() }
                } label: {
                    Label("Test HRV (30 days)", systemImage: "waveform.path.ecg")
                }
                
                Button {
                    Task { await store.testRHR() }
                } label: {
                    Label("Test RHR (7 days)", systemImage: "heart.fill")
                }
                
                Button {
                    Task { await store.testWorkouts() }
                } label: {
                    Label("Test Workouts & TRIMP", systemImage: "figure.run")
                }
            }
            
            Section {
                if store.logs.isEmpty {
                    Text("No logs yet. Tap a button above.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.logs, id: \.self) { log in
                        Text(log)
                            .font(.system(.caption, design: .monospaced))
                    }
                }
            } header: {
                HStack {
                    Text("Logs")
                    Spacer()
                    if !store.logs.isEmpty {
                        Button("Clear", role: .destructive) {
                            store.clearLogs()
                        }
                        .font(.caption)
                        .textCase(.none)
                    }
                }
            }
        }
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
}

#Preview {
    NavigationStack {
        SandboxView()
    }
}
