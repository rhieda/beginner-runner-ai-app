# AI Instructions - Beginner Runner AI Coach

Esta é a guia mestra para qualquer IA (Cursor, Copilot, ChatGPT, Claude) atuando neste projeto. Siga rigorosamente estas diretrizes para manter a integridade da arquitetura e a qualidade do código.

## 1. Arquitetura e Estrutura (Clean Architecture)
O projeto segue uma estrutura de **Clean Architecture com Domain-Driven Design (DDD)** adaptada para SwiftUI.

### Camadas:
- **Domain/**: Contém a lógica de negócio pura.
    - `Entities/`: Modelos de dados de domínio.
    - `Interfaces/`: Protocolos para Repositórios e Data Providers.
    - `Aggregates/`: Lógica de agregação se necessário.
- **Data/**: Implementações concretas de acesso a dados.
    - `Repositories/`: Implementações dos protocolos da Domain.
    - `Infrastructure/`: Clientes de rede, CoreData, HealthKit, Firebase.
    - `Provider/`: Adaptadores específicos (ex: `HRVDataProvider`).
- **Features/**: Camada de UI organizada por funcionalidade.
    - Cada feature deve ter sua `View.swift` e seu `Store.swift` (ViewModel usando `@Observable`).
- **Core/**: Código transversal (Design System, Observability, Helpers).

### Regras de Ouro:
1. **Inversão de Dependência:** A camada `Domain` nunca deve depender da `Data`. A `Data` implementa protocolos definidos na `Domain`.
2. **SwiftUI Nativo:** Use apenas componentes nativos do SwiftUI. Evite UIKit a menos que seja estritamente necessário (documente o porquê).
3. **Gerenciamento de Estado:** Use a macro `@Observable` (iOS 17+) para Stores/ViewModels.

## 2. Spec-Driven Design (SDD)
Este projeto utiliza especificações como **Única Fonte de Verdade**.
- Antes de gerar ou alterar código em `Features/` ou `Domain/`, você **DEVE** ler o arquivo correspondente em `docs/specs/`.
- Se a especificação não existir, solicite ao usuário que a crie ou ajude-o a rascunhar uma baseada nos requisitos.
- O código gerado deve mapear 1:1 para os estados de UI e critérios de aceite definidos na Spec.

## 3. Padrões de Código (Swift & SwiftUI)
- **SwiftLint:**
    - Evite `force_cast` e `force_try`.
    - Identificadores devem ter no mínimo 3 caracteres (exceto `id`).
    - Comprimento de linha sugerido: 110 caracteres.
- **Async/Await:** Use a concorrência moderna do Swift. Evite `Combine` ou `Callbacks` para operações assíncronas simples.
- **Preview Content:** Sempre forneça Mock Data para `Previews` do SwiftUI na pasta `Preview Content`.

## 4. Testes e Validação
- Toda regra de negócio em `Domain` ou lógica de estado em `Store` deve ter testes unitários em `Beginner-Runner-AI-CoachTests`.
- Use o padrão **Given-When-Then** para descrever os casos de teste, baseando-se diretamente nos critérios de aceite da Spec.
- Testes unitários devem ser rigorosos e devem atingir uma cobertura acima de 85%.
- Toda implementação deve ser testada unitariamente.
- Siga rigorosamente as instruções de arquitetura e design patterns, como o Spec-Driven Design (SDD) e a arquitetura de Clean Architecture.

## 5. Ativação Automática de Agentes Especialistas (Multi-Agent Roleplay)
Para garantir a máxima especialização no desenvolvimento do código, a IA (você) deve alternar automaticamente de papel/perfil dependendo da etapa de desenvolvimento em que se encontra. 

### Regras de Ativação e Bloqueio de Papel:
1. **Ativação e Leitura**: Antes de iniciar qualquer ação em cada uma das fases abaixo, você deve ler o arquivo de instrução correspondente em `.ai/prompts/developer_agents/` usando a ferramenta `view_file`.
2. **Bloqueio Cognitivo (Role Lock)**: Ao iniciar a fase, você deve abrir sua resposta declarando explicitamente o seu perfil ativo e as restrições críticas em vigor. Exemplo:
   *`[Perfil Ativo: Coder Agent | Restrições: Sem mocks em produção, Métodos <= 100 linhas]`*.
3. **Auto-Avaliação**: Antes de finalizar seu turno e transicionar para o próximo agente, você deve rodar o **Checklist de Validação** presente no arquivo do perfil ativo e confirmar a conformidade de todos os itens.

### Perfis por Fase:
1. **Fase de Planejamento (Architect Agent)**:
   * **Gatilho**: Ao ler os requisitos, investigar o repositório ou estruturar o plano de implementação (`implementation_plan.md`).
   * **Perfil a ler**: [architect_agent.md](file:///Users/rafaelhieda/Documents/repos/tcc/beginner-runner-ai-app/Beginner-Runner-AI-Coach/.ai/prompts/developer_agents/architect_agent.md)
2. **Fase de Codificação (Coder Agent)**:
   * **Gatilho**: Ao começar a escrever/modificar arquivos SwiftUI, Stores, modelos de dados ou serviços na pasta `Beginner-Runner-AI-Coach/`.
   * **Perfil a ler**: [coder_agent.md](file:///Users/rafaelhieda/Documents/repos/tcc/beginner-runner-ai-app/Beginner-Runner-AI-Coach/.ai/prompts/developer_agents/coder_agent.md)
3. **Fase de Testes e Validação (QA Agent)**:
   * **Gatilho**: Ao criar arquivos em `Beginner-Runner-AI-CoachTests/` ou executar builds/testes via terminal.
   * **Perfil a ler**: [qa_agent.md](file:///Users/rafaelhieda/Documents/repos/tcc/beginner-runner-ai-app/Beginner-Runner-AI-Coach/.ai/prompts/developer_agents/qa_agent.md)
4. **Fase de Compliance e Entrega (Compliance Agent)**:
   * **Gatilho**: Ao revisar formatações, corrigir violações do SwiftLint ou finalizar a task gerando o `walkthrough.md`.
   * **Perfil a ler**: [compliance_agent.md](file:///Users/rafaelhieda/Documents/repos/tcc/beginner-runner-ai-app/Beginner-Runner-AI-Coach/.ai/prompts/developer_agents/compliance_agent.md)

---
*Ao iniciar uma tarefa, confirme que você leu este arquivo e os perfis de agente correspondentes.*
