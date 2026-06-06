import SwiftUI

struct WorkoutPreviewView: View {
    @State var store: WorkoutPreviewStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                switch store.state {
                case .idle:
                    ContentUnavailableView("No workout available", systemImage: "figure.run.circle")
                case .preview(let workout):
                    workoutSections(workout)
                case .syncing:
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Syncing with Apple Watch...")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .listRowBackground(Color.clear)
                case .synced:
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.green)
                        Text("Workout Scheduled!")
                            .font(.headline)
                        Text("Open the Workouts app on your Apple Watch to start.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        Button("Close") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .listRowBackground(Color.clear)
                case .error(let message):
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.orange)
                        Text(message)
                            .multilineTextAlignment(.center)
                        
                        Button("Try Again") {
                            Task { await store.syncToWatch() }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Your Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                
                if case .preview = store.state {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Sync") {
                            Task { await store.syncToWatch() }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func workoutSections(_ workout: CustomWorkoutComposition) -> some View {
        Section("Warmup") {
            WorkoutIntervalRow(
                title: "Warmup",
                duration: workout.warmup.durationInMinutes,
                intensity: workout.warmup.intensityLevel ?? .low,
                icon: "leaf.fill",
                color: .blue
            )
        }
        
        Section("Workout Blocks") {
            ForEach(0..<workout.blocks.count, id: \.self) { index in
                let block = workout.blocks[index]
                VStack(alignment: .leading, spacing: 8) {
                    Text("Block \(index + 1)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    WorkoutIntervalRow(
                        title: "Work",
                        duration: block.work.durationInMinutes,
                        intensity: block.work.intensityLevel ?? .moderate,
                        icon: "flame.fill",
                        color: .orange
                    )
                    
                    WorkoutIntervalRow(
                        title: "Recovery",
                        duration: block.recovery.durationInMinutes,
                        intensity: block.recovery.intensityLevel ?? .low,
                        icon: "timer",
                        color: .green
                    )
                }
                .padding(.vertical, 4)
            }
        }
        
        Section("Cooldown") {
            WorkoutIntervalRow(
                title: "Cooldown",
                duration: workout.cooldown.durationInMinutes,
                intensity: workout.cooldown.intensityLevel ?? .low,
                icon: "figure.walk",
                color: .blue
            )
        }
        
        Section {
            Button {
                Task { await store.syncToWatch() }
            } label: {
                HStack {
                    Spacer()
                    Label("Send to Apple Watch", systemImage: "applewatch")
                        .font(.headline)
                    Spacer()
                }
            }
            .buttonStyle(.borderedProminent)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
        }
    }
}

struct WorkoutIntervalRow: View {
    let title: String
    let duration: Int
    let intensity: WorkoutIntensity
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(intensity.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("\(duration) min")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(duration) minutes, \(intensity.rawValue) intensity")
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
