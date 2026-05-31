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
            
            Section("Logs") {
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
