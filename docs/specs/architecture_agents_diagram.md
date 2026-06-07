# Arquitetura de Agentes e Orquestração (TCC Reference)

Abaixo está a representação vetorial em formato Mermaid.js da arquitetura multi-agente implementada no projeto. Este código pode ser renderizado em leitores Markdown compatíveis (como o próprio GitHub) ou exportado em ferramentas como o [Mermaid Live Editor](https://mermaid.live).

```mermaid
graph TD
    %% Definições de Estilo
    classDef input fill:#2c3e50,stroke:#34495e,stroke-width:2px,color:#fff;
    classDef agent fill:#1abc9c,stroke:#16a085,stroke-width:2px,color:#fff;
    classDef orchestrator fill:#9b59b6,stroke:#8e44ad,stroke-width:2px,color:#fff;
    classDef safety fill:#e67e22,stroke:#d35400,stroke-width:2px,color:#fff;
    classDef output fill:#2ecc71,stroke:#27ae60,stroke-width:2px,color:#fff;
    
    %% Inputs
    subgraph Inputs ["1. Dados de Entrada (Runner Profile)"]
        TRIMP["TRIMP Score & Histórico"]:::input
        HRV["Médias de VFC/HRV (7d / 30d)"]:::input
        Goal["Objetivo do Usuário (User Goal)"]:::input
    end

    %% Processamento Paralelo
    subgraph ParallelAgents ["2. Processamento Paralelo (Agentes Analistas)"]
        LA["LoadAgent (Análise de Carga Crônica)"]:::agent
        RA["RecoveryAgent (Prontidão Biológica)"]:::agent
    end

    %% Orquestrador
    Orch["AgentOrchestrator (Domínio)"]:::orchestrator

    %% Head Coach
    Coach["CoachAgent (Head Coach - LLM)"]:::agent

    %% Validação Fisiológica
    subgraph Validation ["4. Validação Determinística (Swift Nativo)"]
        Guard["PhysiologicalSafetyGuardrail"]:::safety
        FatigueRule["Regra 1: Fadiga (Cap de Volume & Intensidade Low)"]:::safety
        OverreachRule["Regra 3: Sobrecarga (Atenuação de Intensidade High -> Moderate)"]:::safety
        CapRule["Regra 2: Limite de Sessão (Cap de 60 min no Total)"]:::safety
    end

    %% Treino Final
    Out["CustomWorkoutComposition (Treino Seguro)"]:::output

    %% Relações e Fluxos
    TRIMP --> LA
    HRV --> RA
    
    LA -->|LoadReport (Status & Avaliação)| Orch
    RA -->|RecoveryReport (Status & Avaliação)| Orch
    Goal --> Orch
    
    Orch -->|CoachAgentInput| Coach
    Coach -->|Proposta Original de Treino| Guard
    
    Guard -.-> FatigueRule
    Guard -.-> OverreachRule
    Guard -.-> CapRule
    
    Guard -->|Treino Ajustado e Validado| Out
```

## Descrição do Fluxo
1.  **Entrada de Dados (1)**: Os dados fisiológicos do usuário (calculados e tratados a partir do HealthKit) e seu objetivo de treino são isolados na camada de Domínio.
2.  **Agentes Analistas (2)**: O `LoadAgent` avalia a carga aguda/crônica e o `RecoveryAgent` analisa a prontidão biológica. Ambos os agentes rodam de forma concorrente assíncrona (`async let`).
3.  **Orquestrador (3)**: O `AgentOrchestrator` consolida os relatórios dos agentes e prepara o contexto estruturado para o `CoachAgent` (LLM com temperatura `0.0` para estabilidade).
4.  **Guardrail de Segurança (4)**: A proposta de treino gerada pela LLM passa por uma camada determinística nativa em Swift (`PhysiologicalSafetyGuardrail`). Ela atua como um filtro rígido que corrige limites de duração ou intensidades caso os relatórios apontem riscos (fadiga extrema ou sobrecarga de treinos) garantindo segurança física ao usuário.
