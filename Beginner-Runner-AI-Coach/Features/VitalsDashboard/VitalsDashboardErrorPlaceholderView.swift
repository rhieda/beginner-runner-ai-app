import SwiftUI

struct VitalsDashboardErrorPlaceholderView: View {
    let onSettingsAction: () -> Void
    let onRetryAction: () -> Void
    
    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: Theme.Spacing.sectionMargin) {
                Spacer()
                
                // Alert Card
                VStack(spacing: 24) {
                    // Lock Icon with glowing container
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.secondaryContainer.opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Theme.Colors.secondaryContainer)
                            .neonGlow(color: Theme.Colors.secondaryContainer, radius: 10)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Acesso ao HealthKit")
                            .font(Theme.Typography.headlineMd)
                            .foregroundStyle(Theme.Colors.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("TELEMETRIA RESTRITA")
                            .font(Theme.Typography.labelCaps)
                            .kerning(2.0)
                            .foregroundStyle(Theme.Colors.secondaryContainer)
                    }
                    
                    Text("Para calcular o seu escore de Prontidão e prescrever treinos de corrida seguros, o aplicativo necessita ler os dados de Variabilidade Cardíaca (HRV), Frequência Cardíaca de Repouso (RHR) e Histórico de Treinos do Apple Health.")
                        .font(Theme.Typography.bodySm)
                        .foregroundStyle(Theme.Colors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 8)
                    
                    VStack(spacing: 12) {
                        // Grant Settings Button
                        Button {
                            onSettingsAction()
                        } label: {
                            HStack {
                                Spacer()
                                Label("Abrir Ajustes do iOS", systemImage: "gearshape.fill")
                                    .font(Theme.Typography.bodyLg)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            .padding()
                            .background(Theme.Colors.primaryContainer)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.full))
                            .foregroundStyle(Theme.Colors.onPrimary)
                            .neonGlow(color: Theme.Colors.primaryContainer, radius: 6)
                        }
                        .buttonStyle(.plain)
                        
                        // Retry Button
                        Button {
                            onRetryAction()
                        } label: {
                            Text("Tentar Novamente")
                                .font(Theme.Typography.bodySm)
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.Colors.onSurfaceVariant)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 8)
                }
                .padding(Theme.Spacing.containerPadding)
                .glassCard(cornerRadius: Theme.Radius.default)
                
                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.containerPadding)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    VitalsDashboardErrorPlaceholderView(
        onSettingsAction: {},
        onRetryAction: {}
    )
}
