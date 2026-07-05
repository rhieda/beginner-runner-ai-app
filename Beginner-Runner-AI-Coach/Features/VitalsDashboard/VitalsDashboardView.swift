import SwiftUI

struct VitalsDashboardView: View {
    @State var store = VitalsDashboardStore()
    let onOpenSandbox: () -> Void
    
    var body: some View {
        ZStack {
            // Main canvas background
            Theme.Colors.background
                .ignoresSafeArea()
            
            // Screen content switcher
            switch store.state {
            case .checkingPermissions:
                VitalsDashboardCheckingPermissionsView()
                
            case .notAuthorized:
                VitalsDashboardErrorPlaceholderView(
                    onSettingsAction: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    },
                    onRetryAction: {
                        Task { await store.checkPermissionsAndLoadData() }
                    }
                )
                
            case .loadingData:
                VitalsDashboardLoadingDataView()
                
            case .emptyData:
                VitalsDashboardEmptyDataView(onReloadAction: {
                    Task { await store.loadData() }
                })
                
            case .loaded(let data):
                dashboardContentView(data: data)
                
            case .error(let message):
                VitalsDashboardErrorView(message: message, onRetryAction: {
                    Task { await store.checkPermissionsAndLoadData() }
                })
                
            case .generatingWorkout:
                if let previousData = getLoadedDataFromState() {
                    dashboardContentView(data: previousData)
                        .disabled(true)
                } else {
                    Theme.Colors.background.ignoresSafeArea()
                }
            }
            
            // AI Agent overlay HUD
            if case .generatingWorkout(let logs) = store.state {
                aiGenerationHUDOverlay(logs: logs)
            }
        }
        .task {
            // Business Rule: Auto-trigger permission check and load on task load
            await store.checkPermissionsAndLoadData()
        }
        .fullScreenCover(isPresented: $store.showWorkoutPreview) {
            if let workout = store.generatedWorkout {
                workoutPreviewView(for: workout)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("DASHBOARD")
                    .font(Theme.Typography.labelCaps)
                    .kerning(2.0)
                    .foregroundStyle(Theme.Colors.primary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onOpenSandbox()
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(Theme.Colors.onSurfaceVariant)
                }
            }
        }
        .toolbarBackground(Theme.Colors.surfaceGlass, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .preferredColorScheme(.dark)
    }
    
    private func workoutPreviewView(for workout: CustomWorkoutComposition) -> some View {
        let previewStore = WorkoutPreviewStore()
        previewStore.setWorkout(workout)
        return WorkoutPreviewView(store: previewStore)
    }
    
    // MARK: - Loading HUD Overlay
    private func aiGenerationHUDOverlay(logs: [String]) -> some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Theme.Colors.neonGreen.opacity(0.1))
                        .frame(width: 100, height: 100)
                    PulseIndicator(color: Theme.Colors.neonGreen)
                        .scaleEffect(2.5)
                }
                
                VStack(spacing: 6) {
                    Text("Gerando Treino Personalizado")
                        .font(Theme.Typography.headlineMd)
                        .foregroundStyle(Theme.Colors.primary)
                    Text("AGENT PIPELINE ACTIVE")
                        .font(Theme.Typography.labelCaps)
                        .kerning(1.5)
                        .foregroundStyle(Theme.Colors.neonGreen)
                }
                
                logConsoleView(logs: logs)
                
                Spacer()
            }
            .padding(.bottom, 40)
        }
    }
    
    private func logConsoleView(logs: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("AI COACH SYSTEM LOGS")
                .font(Theme.Typography.labelCaps)
                .foregroundStyle(Theme.Colors.onSurfaceVariant.opacity(0.8))
                .padding(.horizontal, 4)
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(0..<logs.count, id: \.self) { index in
                            Text(logs[index])
                                .font(Theme.Typography.dataTabular)
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.Colors.onSurface)
                                .id(index)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Theme.Spacing.unit * 3)
                }
                .frame(height: 160)
                .glassCard(cornerRadius: Theme.Radius.sm)
                .onChange(of: logs.count) {
                    if !logs.isEmpty {
                        withAnimation {
                            proxy.scrollTo(logs.count - 1, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.containerPadding)
    }
    
    // MARK: - Dashboard Content
    @ViewBuilder
    private func dashboardContentView(data: VitalsDashboardData) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: Theme.Spacing.sectionMargin) {
                    metricsBentoGrid(data: data)
                    
                    userStatusSection(data: data)
                    
                    Spacer()
                        .frame(height: 80)
                }
                .padding(.horizontal, Theme.Spacing.containerPadding)
                .padding(.vertical, Theme.Spacing.gridGutter)
            }
            
            ctaButton(data: data)
        }
    }
    
    @ViewBuilder
    private func metricsBentoGrid(data: VitalsDashboardData) -> some View {
        VStack(spacing: Theme.Spacing.sectionMargin) {
            TelemetryRing(
                progress: Double(data.readinessScore) / 100.0,
                score: data.readinessScore,
                label: data.readinessLabel,
                metricLabel: "Prontidão"
            )
            .padding(.top, 10)
            .neonGlow(color: Theme.Colors.neonGreen, radius: 12)
            
            VStack(spacing: Theme.Spacing.gridGutter) {
                HStack(spacing: Theme.Spacing.gridGutter) {
                    SparklineChartView(data: data.hrvTrend, title: "HRV", unit: "ms", color: Theme.Colors.neonGreen)
                    SparklineChartView(data: data.rhrTrend, title: "RHR", unit: "bpm", color: Theme.Colors.dataCyan)
                }
                
                HStack(spacing: Theme.Spacing.gridGutter) {
                    hrvDetailCard(data: data)
                    rhrDetailCard(data: data)
                }
            }
        }
    }
    
    @ViewBuilder
    private func hrvDetailCard(data: VitalsDashboardData) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.unit) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(Theme.Colors.neonGreen)
                Text("VAR. CARDÍACA")
                    .font(Theme.Typography.labelCaps)
                    .font(.system(size: 9))
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
            }
            
            Spacer()
            
            if data.hrvCurrent > 0 {
                Text("\(Int(data.hrvCurrent))")
                    .font(Theme.Typography.displayMetrics)
                    .font(.system(size: 32))
                    .foregroundStyle(Theme.Colors.primary)
                + Text(" ms")
                    .font(Theme.Typography.bodySm)
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
            } else {
                Text("--")
                    .font(Theme.Typography.displayMetrics)
                    .font(.system(size: 32))
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
            }
            
            HStack(spacing: 4) {
                Image(systemName: data.hrvChangePercentage >= 0 ? "arrow.up" : "arrow.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.Colors.neonGreen)
                Text("\(String(format: "%.0f%%", abs(data.hrvChangePercentage))) vs ontem")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Theme.Colors.neonGreen)
            }
        }
        .padding(Theme.Spacing.gridGutter)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .glassCard()
    }
    
    @ViewBuilder
    private func rhrDetailCard(data: VitalsDashboardData) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.unit) {
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .foregroundStyle(Theme.Colors.dataCyan)
                Text("FREQ. REPOUSO")
                    .font(Theme.Typography.labelCaps)
                    .font(.system(size: 9))
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
            }
            
            Spacer()
            
            if data.rhrCurrent > 0 {
                Text("\(Int(data.rhrCurrent))")
                    .font(Theme.Typography.displayMetrics)
                    .font(.system(size: 32))
                    .foregroundStyle(Theme.Colors.primary)
                + Text(" bpm")
                    .font(Theme.Typography.bodySm)
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
            } else {
                Text("--")
                    .font(Theme.Typography.displayMetrics)
                    .font(.system(size: 32))
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
            }
            
            HStack(spacing: 4) {
                Image(systemName: "minus")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
                Text(data.rhrStatus)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
            }
        }
        .padding(Theme.Spacing.gridGutter)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .glassCard()
    }
    
    @ViewBuilder
    private func userStatusSection(data: VitalsDashboardData) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.stackGap) {
            HStack(spacing: 8) {
                PulseIndicator(color: Theme.Colors.neonGreen)
                Text("ESTADO DO USUÁRIO")
                    .font(Theme.Typography.labelCaps)
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
            }
            .padding(.leading, 4)
            
            VStack(spacing: Theme.Spacing.stackGap) {
                VitalsDashboardStatusRow(
                    title: "FORMA FÍSICA",
                    value: data.fitnessState,
                    icon: "dumbbell.fill",
                    color: Theme.Colors.neonGreen,
                    trendIcon: data.fitnessState == "Sobrecarga" ? "exclamationmark.triangle.fill" : "trending.up",
                    trendColor: data.fitnessState == "Sobrecarga" ? Theme.Colors.secondaryContainer : Theme.Colors.neonGreen
                )
                
                VitalsDashboardStatusRow(
                    title: "ESTADO ATUAL",
                    value: data.recoveryState,
                    icon: "moon.zzz.fill",
                    color: Theme.Colors.dataCyan,
                    trendIcon: data.recoveryState == "Fadigado" ? "exclamationmark.circle.fill" : "checkmark.circle.fill",
                    trendColor: data.recoveryState == "Fadigado" ? Theme.Colors.secondaryContainer : Theme.Colors.dataCyan
                )
            }
        }
    }

    
    // MARK: - Bottom CTA Button
    private func ctaButton(data: VitalsDashboardData) -> some View {
        VStack {
            Button {
                Task { await store.generateWorkout(data: data) }
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(Theme.Colors.onPrimary)
                    Text("Gerar Treino de Corrida")
                        .font(Theme.Typography.bodyLg)
                        .fontWeight(.bold)
                        .foregroundStyle(Theme.Colors.onPrimary)
                    Spacer()
                }
                .padding()
                .background(Theme.Colors.primaryContainer)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.full))
                .neonGlow(color: Theme.Colors.primaryContainer, radius: 10)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Theme.Spacing.containerPadding)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .background(Theme.Colors.background)
    }
    
    // MARK: - Helpers
    private func getLoadedDataFromState() -> VitalsDashboardData? {
        if case .loaded(let data) = store.state {
            return data
        }
        return nil
    }
}

// MARK: - Helper Subviews (SwiftLint compliance)

struct VitalsDashboardStatusRow: View {
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

struct VitalsDashboardCheckingPermissionsView: View {
    var body: some View {
        VStack {
            ProgressView()
                .tint(Theme.Colors.primaryContainer)
                .scaleEffect(1.5)
            Text("Verificando Permissões...")
                .font(Theme.Typography.bodyLg)
                .foregroundStyle(Theme.Colors.onSurfaceVariant)
                .padding(.top, 16)
        }
    }
}

struct VitalsDashboardLoadingDataView: View {
    var body: some View {
        VStack {
            ProgressView()
                .tint(Theme.Colors.primaryContainer)
                .scaleEffect(1.5)
            Text("Buscando Dados de Saúde...")
                .font(Theme.Typography.bodyLg)
                .foregroundStyle(Theme.Colors.onSurfaceVariant)
                .padding(.top, 16)
        }
    }
}

struct VitalsDashboardEmptyDataView: View {
    let onReloadAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform.path.badge.minus")
                .font(.system(size: 60))
                .foregroundStyle(Theme.Colors.onSurfaceVariant)
            
            Text("Sem dados de telemetria")
                .font(Theme.Typography.headlineMd)
                .foregroundStyle(Theme.Colors.primary)
            
            Text("Nenhuma amostra de HRV ou RHR encontrada no HealthKit nos últimos 30 dias. Registre dados ou emparelhe um Apple Watch.")
                .font(Theme.Typography.bodySm)
                .foregroundStyle(Theme.Colors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button {
                onReloadAction()
            } label: {
                Text("Recarregar")
                    .font(Theme.Typography.bodyLg)
                    .fontWeight(.bold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Theme.Colors.surfaceContainerHigh)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.default))
                    .foregroundStyle(Theme.Colors.primary)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
}

struct VitalsDashboardErrorView: View {
    let message: String
    let onRetryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundStyle(Theme.Colors.secondaryContainer)
            
            Text("Algo deu errado")
                .font(Theme.Typography.headlineMd)
                .foregroundStyle(Theme.Colors.primary)
            
            Text(message)
                .font(Theme.Typography.bodySm)
                .foregroundStyle(Theme.Colors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button {
                onRetryAction()
            } label: {
                Text("Tentar Novamente")
                    .font(Theme.Typography.bodyLg)
                    .fontWeight(.bold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Theme.Colors.primaryContainer)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.default))
                    .foregroundStyle(Theme.Colors.onPrimary)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
}

#Preview {
    VitalsDashboardView(onOpenSandbox: {})
}
