# Feature Spec: Workout Generation & Apple Watch Sync

## 1. Visão Geral
Esta funcionalidade permite que o usuário visualize o treino gerado pelo `AgentOrchestrator` e o envie diretamente para o seu Apple Watch via `WorkoutKit`. O objetivo é transformar a recomendação da IA em uma sessão de exercício executável e monitorada.

## 2. Contratos de Dados (Domain)
### Entidades
Utiliza a estrutura `CustomWorkoutComposition` definida em `CoachAgent.swift`.

```swift
enum WorkoutIntensity: String, Codable, CaseIterable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
}

struct CustomWorkoutComposition: Codable {
    struct Step: Codable {
        let durationInMinutes: Int
        let intensityLevel: WorkoutIntensity?
    }

    struct Block: Codable {
        let work: Step
        let recovery: Step
    }

    let warmup: Step
    let blocks: [Block]
    let cooldown: Step
}
```

### Protocolo do Serviço (Interface)
```swift
protocol WorkoutKitServiceProtocol {
    func requestAuthorization() async throws -> Bool
    func scheduleWorkout(_ workout: CustomWorkoutComposition) async throws
}
```

## 3. Comportamento e Estados da UI (Feature Layer)
### Estados do Store
A View deve reagir aos seguintes estados definidos no `WorkoutPreviewStore`:
- **.idle**: Aguardando geração do treino.
- **.preview(workout)**: Exibindo o resumo do treino gerado.
- **.syncing**: Enviando o treino para o Apple Watch.
- **.synced**: Confirmação de que o treino foi agendado.
- **.error(message)**: Falha na geração ou no envio.

### Critérios de Aceite (BDD)
- **Cenário 1: Visualização do Treino Gerado**
    - **Given** que o `AgentOrchestrator` finalizou a pipeline com sucesso.
    - **When** a `WorkoutPreviewView` recebe o `CustomWorkoutComposition`.
    - **Then** a UI deve listar os blocos de Aquecimento, Trabalho/Recuperação e Desaquecimento com suas respectivas durações em inglês.

- **Cenário 2: Sincronização com Apple Watch**
    - **Given** que um treino está sendo exibido.
    - **When** o usuário toca no botão "Send to Apple Watch".
    - **Then** o app deve solicitar permissão do `WorkoutKit` (se necessário) e agendar o treino, exibindo uma confirmação de sucesso.

- **Cenário 3: Falha na Permissão ou Sincronização**
    - **Given** que o usuário tenta sincronizar.
    - **When** o `WorkoutKit` nega permissão ou ocorre um erro de sistema.
    - **Then** a UI deve exibir um alerta informando o erro em inglês.

## 4. Design System / UI
- **Componentes:**
    - `WorkoutIntervalRow`: Componente de lista para exibir cada etapa (step).
    - `PrimaryButton`: Para a ação principal de sincronização.
- **Navegação:** A `WorkoutPreviewView` é apresentada como uma Sheet após a análise dos agentes na `SandboxView`.

## 5. Pontos de Atenção (Arquitetura e Segurança)
- **Workout Configuration Entitlement**: Esta é uma capability restrita da Apple. Para rodar em dispositivos físicos, ela deve ser habilitada manualmente no portal do desenvolvedor (Apple Developer Program) para o App ID correspondente. No Simulador, esta restrição não é aplicada.
- **Sincronização**: O agendamento utiliza `WorkoutScheduler` e exige iOS 17+. O treino aparecerá no app nativo "Workouts" (Exercícios) do Apple Watch.
- **Localização**: Todo o conteúdo voltado ao usuário deve estar em inglês para consistência com o restante do projeto.

---
*Esta especificação deve ser seguida rigorosamente pela IA durante a implementação.*
