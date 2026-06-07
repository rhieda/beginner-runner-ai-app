# Feature Spec: Sandbox Interactive Controls (Controles Interativos do Sandbox)

## 1. Visão Geral
Esta especificação descreve o desenvolvimento de controles interativos na tela do **Provider Sandbox** para permitir que desenvolvedores simulem métricas fisiológicas específicas (TRIMP, médias de VFC/HRV de 7 e 30 dias) e objetivos do usuário de forma manual e dinâmica. 

Isso resolve a limitação de testar os limites dos safety guardrails e a consistência das LLMs em simuladores iOS onde o banco de dados do HealthKit está tipicamente vazio.

---

## 2. Padrões de Código e Diretrizes (SwiftUI Expert Skill & AI Instructions)
Seguindo as diretrizes do `AI_INSTRUCTIONS.md` e do `swiftui-expert-skill`:
*   **Separação de Responsabilidades**: Toda a lógica de estado das variáveis simuladas e da chamada do orquestrador será encapsulada no `SandboxStore` (usando a macro `@Observable` do Swift).
*   **Componentes Natividade**: A UI utilizará componentes puramente nativos do SwiftUI (`Slider`, `TextField`, `Toggle`, `Section`).
*   **Desempenho**: Atualizações nas propriedades observáveis do `SandboxStore` no thread principal.
*   **State Management**: Nenhuma declaração ad-hoc de `@State` na View para as variáveis de dados de treino; todo o estado fisiológico é propagado e controlado pelo `SandboxStore`.

---

## 3. Propriedades de Simulação (Domain / State)

O `SandboxStore` manterá as seguintes variáveis observáveis:
```swift
var useSimulatedMetrics: Bool = true
var simulatedTrimp: Double = 65.4
var simulatedSevenDayHRV: Double = 55.2
var simulatedThirtyDayHRV: Double = 56.1
var simulatedUserGoal: String = "Build endurance without injury"
```

### Comportamento da Simulação
1.  **useSimulatedMetrics**: Um Toggle que, quando ativado, instrui o pipeline a ignorar dados reais do HealthKit e injetar diretamente os valores simulados acima ao chamar `aiOrchestrator.generateWorkout`.
2.  **selectedProvider == .mock**: Quando o provedor mockado é selecionado, o Toggle `useSimulatedMetrics` é implicitamente forçado para `true` e desativado na tela, pois o mock local não possui integração com dados de produção.

---

## 4. Estrutura da Interface (UI / SwiftUI)

A tela `SandboxView` ganhará uma nova seção de ferramentas do desenvolvedor:
```swift
Section("Simulated Biometrics (Dev Tools)") {
    Toggle("Use Simulated Data", isOn: $store.useSimulatedMetrics)
        .disabled(store.selectedProvider == .mock)
        
    VStack(alignment: .leading) {
        Text("Simulated TRIMP: \(String(format: "%.1f", store.simulatedTrimp))")
        Slider(value: $store.simulatedTrimp, in: 0...200, step: 0.5)
    }
    
    VStack(alignment: .leading) {
        Text("Simulated 7d HRV: \(String(format: "%.0f", store.simulatedSevenDayHRV)) ms")
        Slider(value: $store.simulatedSevenDayHRV, in: 10...150, step: 1)
    }
    
    VStack(alignment: .leading) {
        Text("Simulated 30d HRV: \(String(format: "%.0f", store.simulatedThirtyDayHRV)) ms")
        Slider(value: $store.simulatedThirtyDayHRV, in: 10...150, step: 1)
    }
    
    TextField("User Goal", text: $store.simulatedUserGoal)
}
```

---

## 5. Critérios de Aceite (BDD)

-   **Cenário 1: Forçar uso de Dados Simulados em Provedores Reais**
    -   **Given** que o usuário está executando o app no simulador iOS com o HealthKit vazio.
    -   **When** seleciona o provedor "Gemini 3.5 Flash" e ativa "Use Simulated Data".
    -   **Then** a chamada do pipeline não falhará por falta de dados fisiológicos e utilizará as métricas configuradas nos Sliders.

-   **Cenário 2: Validação Rápida do Guardrail de Fadiga**
    -   **Given** que o usuário ajusta o Slider de `7d HRV` para `20` (muito abaixo do baseline de 30 dias de `55`).
    -   **When** clica em "Run Multi-Agent Pipeline".
    -   **Then** o log exibe o status `FATIGUED` e o guardrail nativo do Swift força o treino para intensidade `Low` (Baixa).
