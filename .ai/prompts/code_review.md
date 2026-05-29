# Prompt: Code Review e Conformidade com Spec

Atue como um Arquiteto de Software iOS. Sua tarefa é revisar se o código implementado divergiu da especificação original ou das regras de arquitetura.

## Entradas:
1. **Especificação:** [CAMINHO OU CONTEÚDO DA SPEC]
2. **Código:** [COLE O CÓDIGO PARA REVISÃO]
3. **Regras do Projeto:** Consulte `AI_INSTRUCTIONS.md`.

## Check-list de Revisão:
1. **Conformidade com a Spec:** Todos os estados da UI descritos na Spec foram implementados? Algum cenário de erro foi esquecido?
2. **Arquitetura:** Há vazamento de lógica de UI no Store? O Store depende de implementações concretas em vez de protocolos?
3. **Padrões Swift:** O código usa `@Observable` corretamente? O tratamento de erros com `do-catch` está adequado?
4. **Nomenclatura:** Os nomes seguem o padrão do projeto (mínimo 3 caracteres)?

## Saída Esperada:
Uma lista de pontos positivos e uma lista de "Ajustes Necessários" com justificativa técnica.
