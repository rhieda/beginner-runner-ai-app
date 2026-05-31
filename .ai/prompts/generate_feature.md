# Prompt: Gerar Feature Completa (SDD)

Atue como um Especialista iOS Senior. Seu objetivo é implementar uma nova funcionalidade no projeto `Beginner-Runner-AI-Coach` seguindo o **Spec-Driven Design**.

## Entradas:
1. **Especificação:** [COLE AQUI O CONTEÚDO DO ARQUIVO .md DA PASTA docs/specs/]
2. **Contexto:** Consulte `AI_INSTRUCTIONS.md` e `architecture-sample.md` para regras de arquitetura.

## Tarefa:
Gere o código Swift necessário para as seguintes camadas:

1. **Domain Layer:**
   - Crie a Entidade em `Domain/Entities/`.
   - Crie o Protocolo do Repositório em `Domain/Interfaces/`.

2. **Feature Layer:**
   - Crie o `Store.swift` em `Features/[Nome]/` usando `@Observable`, tratando todos os estados (loading, success, error) definidos na Spec.
   - Crie a `View.swift` em `Features/[Nome]/` com suporte a Previews e Mock Data.

3. **Data Layer (Esqueleto):**
   - Crie uma implementação Mock do Repositório em `Data/Repositories/` para que a UI possa ser testada imediatamente.

## Regras de Saída:
- O código deve ser limpo, seguir SwiftLint (sem force casts).
- Use `async/await`.
- Certifique-se de que a View mapeia exatamente para os Critérios de Aceite da Spec.
