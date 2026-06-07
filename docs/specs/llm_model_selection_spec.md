# Feature Spec: Model-Based LLM Selection (Seleção de Modelos de LLM)

## 1. Visão Geral
Esta especificação descreve a refatoração do sistema de seleção de LLMs. Em vez de selecionar apenas a empresa provedora (OpenAI, Google Gemini, Anthropic Claude), a interface permitirá ao usuário escolher diretamente o modelo específico a ser utilizado no pipeline de agentes de IA.

Essa mudança melhora a granularidade do controle sobre o desempenho, tempo de resposta e custo dos modelos suportados.

## 2. Modelos Suportados e Mapeamento
A fábrica de provedores (`LLMProviderFactory`) e o enum `LLMProviderType` mapearão os modelos diretamente.

### Provedor Gemini (Google)
- **Gemini 2.5 Flash Lite** (`gemini-2.5-flash-lite`)
- **Gemini 2.5 Flash** (`gemini-2.5-flash`)
- **Gemini 3.5 Flash** (`gemini-3.5-flash`)
- **Gemini 3.1 Flash Lite** (`gemini-3.1-flash-lite`)
- **Gemini 1.5 Flash** (`gemini-1.5-flash`)
- **Gemini 1.5 Pro** (`gemini-1.5-pro`)

### Provedor OpenAI
- **GPT-4o** (`gpt-4o`)
- **GPT-4o Mini** (`gpt-4o-mini`)
- **GPT-4 Turbo** (`gpt-4-turbo`)

### Provedor Claude (Anthropic)
- **Claude 3.5 Sonnet** (`claude-3-5-sonnet-20241022`)
- **Claude 3.5 Haiku** (`claude-3-5-haiku-20241022`)
- **Claude 3 Opus** (`claude-3-opus-20240229`)

### Sandbox
- **Sandbox (Mock)**: Execução local simulada sem chamadas de rede.

---

## 3. Alterações de Arquitetura e Código

### Injetando o Modelo nos Provedores Concretos
Cada classe de provedor concreto receberá o identificador do modelo em seu construtor:
```swift
class GeminiLLMProvider: LLMProviderProtocol {
    private let model: String
    // ...
    init(networkClient: LLMNetworkClientProtocol = LLMNetworkClient(), apiKey: String = LLMConfig.geminiKey, model: String = "gemini-2.5-flash-lite")
}

class OpenAILLMProvider: LLMProviderProtocol {
    private let model: String
    // ...
    init(networkClient: LLMNetworkClientProtocol = LLMNetworkClient(), apiKey: String = LLMConfig.openAIKey, model: String = "gpt-4-turbo-preview")
}

class ClaudeLLMProvider: LLMProviderProtocol {
    private let model: String
    // ...
    init(networkClient: LLMNetworkClientProtocol = LLMNetworkClient(), apiKey: String = LLMConfig.claudeKey, model: String = "claude-3-sonnet-20240229")
}
```

### Fábrica de Provedores (`LLMProviderFactory.swift`)
O enum `LLMProviderType` listará os modelos individuais, e a fábrica instanciará os provedores passando a string de identificação do modelo correspondente.

---

## 4. Critérios de Aceite (BDD)
- **Cenário 1: Seleção de Modelo no Picker**
  - **Given** que o usuário abre a tela do Provider Sandbox.
  - **When** clica no menu de LLM Provider.
  - **Then** a lista de opções exibirá os nomes específicos dos modelos (ex: "Gemini 3.5 Flash", "GPT-4o Mini") ao invés de apenas a empresa.

- **Cenário 2: Execução de chamada com modelo correto**
  - **Given** que o usuário seleciona o modelo "Gemini 3.5 Flash" e inicia o pipeline.
  - **When** o `GeminiLLMProvider` envia a requisição.
  - **Then** o endpoint de destino conterá `/models/gemini-3.5-flash`.
