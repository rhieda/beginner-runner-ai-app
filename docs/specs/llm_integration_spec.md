# Feature Spec: LLM Providers Integration

## 1. Visão Geral
Melhorar a arquitetura atual de agentes de IA integrando provedores reais de LLMs (Google Gemini, OpenAI, Anthropic Claude) utilizando `URLSession` nativo. A configuração das chaves de API será gerenciada de forma segura através de um arquivo `Secrets.plist` (ignorado pelo git) de acordo com os princípios de segurança do projeto.

## 2. Contratos de Dados e Infraestrutura (Clean Architecture)
A integração ocorrerá principalmente nas camadas `Data` e `Core`, respeitando o `@AI_INSTRUCTIONS.md`.

### Segurança e Configuração (`Data/Infrastructure/`)
- Adição de `Secrets.plist` ao `.gitignore`.
- Criação de `LLMConfig.swift` para ler de forma segura do `Secrets.plist`.

### Infraestrutura de Rede (`Data/Infrastructure/Network/`)
Um cliente de rede nativo usando async/await.
```swift
enum LLMNetworkError: Error {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(statusCode: Int, payload: String?)
    case decodingFailed
}

protocol LLMNetworkClientProtocol {
    func execute<T: Decodable>(request: URLRequest) async throws -> T
}
```

### Provedores Concretos (`Data/Provider/LLM/`)
As classes a seguir implementarão o `LLMProviderProtocol` (já existente em `Core/AI/AIAgentProtocols.swift`):
- `OpenAILLMProvider`
- `GeminiLLMProvider`
- `ClaudeLLMProvider`

### DTOs (Data Transfer Objects)
Modelos encapsulados em `Data/Provider/LLM/DTOs/` para serialização de cada API:
- `OpenAIDTOs.swift`: `OpenAIRequest`, `OpenAIResponse`
- `GeminiDTOs.swift`: `GeminiRequest`, `GeminiResponse`
- `ClaudeDTOs.swift`: `ClaudeRequest`, `ClaudeResponse`

## 3. Orquestração e Factory (`Domain/Agents/` & `Features/`)
### Injeção de Dependência
Uma Factory será responsável por instanciar o provedor desejado, isolando a complexidade de instanciação da UI.

```swift
enum LLMProviderType {
    case openai, gemini, claude, mock
}

enum LLMProviderFactory {
    static func create(type: LLMProviderType) throws -> LLMProviderProtocol {
        // Implementação da fábrica
    }
}
```

### Critérios de Aceite (BDD)
- **Cenário 1: Execução de Prompt com Sucesso**
    - **Given** que o sistema usa um provider real (ex: Gemini) e possui uma chave válida no `Secrets.plist`.
    - **When** o `Agent` (ex: `LoadAgent`) chama `generateResponse()`.
    - **Then** a requisição HTTP nativa é enviada e o JSON da resposta é convertido corretamente na `String` final, mantendo o fluxo atual de orquestração inalterado.

- **Cenário 2: Erro na Requisição da API**
    - **Given** que a API está com instabilidade (ou a chave é inválida).
    - **When** o `LLMNetworkClient` executa o request.
    - **Then** um erro `LLMNetworkError` específico é lançado (ex: `.unauthorized`), propagando o erro corretamente até o `SandboxStore` (estado `.error`).

## 4. Testes e Validação
Conforme diretrizes de qualidade:
- **Testes de Rede (Mock):** Criação de testes unitários para cada provider (`Beginner-Runner-AI-CoachTests/Providers/`) utilizando uma classe `MockURLProtocol`.
- **Casos de Teste (Given-When-Then):** Validar se os DTOs estão encodando corretamente para a string JSON esperada pelos endpoints, e se estão decodando as respostas simuladas adequadamente (sucesso e falha).
- **Sem Dependências:** Garantir uso exclusivo das APIS do Swift Foundation sem recorrer a CocoaPods ou SPM.
