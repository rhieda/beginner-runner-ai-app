# Prompt: Gerar Testes Unitários (SDD)

Atue como um Especialista em QA e Testes iOS. Seu objetivo é garantir que a implementação da feature no projeto `Beginner-Runner-AI-Coach` esteja 100% alinhada com os critérios de aceite.

## Entradas:
1. **Especificação:** [COLE AQUI O CONTEÚDO DO ARQUIVO .md DA PASTA docs/specs/]
2. **Código Implementado:** [COLE O CÓDIGO DO STORE/VIEWMODEL OU REPOSITÓRIO]

## Tarefa:
Gere arquivos de teste unitário usando `XCTest` na pasta `Beginner-Runner-AI-CoachTests`.

## Requisitos dos Testes:
1. **Mapeamento BDD:** Cada "Cenário" da especificação deve se tornar pelo menos uma função de teste.
2. **Estrutura Given-When-Then:** Use comentários dentro do teste para separar as fases.
3. **Mocks:** Gere classes de Mock/Spy para os protocolos da camada `Domain` necessários para testar o `Store`.
4. **Casos de Borda:** Além dos cenários da spec, inclua testes para timeouts e dados corrompidos se aplicável.

## Exemplo de Saída Esperada:
```swift
func test_onAppear_whenRepositorySucceeds_shouldShowSuccessState() async {
    // Given
    let mockRepo = MockFeatureRepository()
    let sut = FeatureStore(repository: mockRepo)
    
    // When
    await sut.loadData()
    
    // Then
    XCTAssertEqual(sut.state, .success)
}
```
