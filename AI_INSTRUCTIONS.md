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

---
*Ao iniciar uma tarefa, confirme que você leu este arquivo e o `architecture-sample.md`.*
