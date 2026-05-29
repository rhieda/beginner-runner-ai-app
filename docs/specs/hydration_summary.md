# Feature Spec: Resumo de Hidratação

## 1. Visão Geral
Exibe a quantidade de água ingerida pelo corredor no dia atual e permite registrar novos consumos (250ml). Crucial para a recuperação do atleta.

## 2. Contratos de Dados (Domain)
### Entidades
```swift
struct WaterIntake: Codable {
    let amountML: Int
    let goalML: Int
    let date: Date
    
    var progress: Double { Double(amountML) / Double(goalML) }
}
```

### Protocolo do Repositório (Interface)
```swift
protocol WaterRepositoryProtocol {
    func fetchTodayIntake() async throws -> WaterIntake
    func addWater(amount: Int) async throws -> WaterIntake
}
```

## 3. Comportamento e Estados da UI (Feature Layer)
### Estados do Store
A View deve reagir aos estados:
- **.loading**: Buscando dados iniciais.
- **.success(WaterIntake)**: Exibe progresso e botão de adicionar.
- **.error(String)**: Exibe erro e botão de retry.

### Critérios de Aceite (BDD)
- **Cenário 1: Registrar Água com Sucesso**
    - **Given** que o usuário está na tela de Hidratação.
    - **When** o usuário toca no botão "+ 250ml".
    - **Then** a UI deve mostrar um loading temporário e atualizar o progresso após a confirmação.

- **Cenário 2: Erro ao Carregar**
    - **Given** que não há conexão com o banco local/saúde.
    - **When** a tela é aberta.
    - **Then** exibir a mensagem "Não foi possível carregar seus dados" e um botão de recarregar.

## 4. Design System / UI
- **Cores:** Use azul do sistema para o progresso.
- **Componentes:** Card centralizado com um `CircularProgressView` (se existir) ou um `ProgressView` nativo estilizado.
