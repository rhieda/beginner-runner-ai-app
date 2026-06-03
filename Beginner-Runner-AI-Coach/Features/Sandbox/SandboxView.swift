import SwiftUI

struct SandboxView: View {
    @State private var store = SandboxStore()
    
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
                Picker("LLM Provider", selection: $store.selectedProvider) {
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
    }
}

#Preview {
    NavigationStack {
        SandboxView()
    }
}
