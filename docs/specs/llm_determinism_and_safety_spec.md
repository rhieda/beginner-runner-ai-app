# Especificação Técnica: Determinismo de LLMs e Validação Fisiológica Baseada em Regras

## 1. Visão Geral
Esta especificação detalha as modificações arquiteturais destinadas a mitigar a variação estocástica nas recomendações de treino geradas pelo pipeline de agentes de IA, além de reforçar a segurança física do usuário (corredor iniciante) por meio de guardrails determinísticos em código nativo.

---

## 2. Fundamentação Teórica e Motivação (Subsídios para o TCC)

A variação inconsistente em recomendações de treino é um desafio crítico no desenvolvimento de sistemas de saúde baseados em IA. Para embasamento na monografia do TCC, a solução implementada é dividida em três pilares fundamentais:

### 2.1 O Parâmetro de Temperatura (Determinismo vs. Criatividade)
Modelos de Linguagem de Grande Porte (LLMs) são, por natureza, preditores probabilísticos de tokens. Ao receber um prompt, o modelo calcula a distribuição de probabilidade de todos os tokens possíveis para o próximo passo. A seleção do token final é governada pelo hiperparâmetro **Temperatura ($T$)**:
*   **Temperatura Alta ($T \ge 0.7$)**: Achata a curva de probabilidade, permitindo que tokens menos prováveis sejam escolhidos. Isso introduz aleatoriedade, "criatividade" e variação estilística.
*   **Temperatura Zero ($T = 0.0$ / amostragem gananciosa)**: Colapsa a distribuição, forçando o modelo a selecionar estritamente o token de maior probabilidade absoluta a cada passo.

**Motivação para o TCC**: No domínio da saúde e educação física, a criatividade e a variação descontrolada de treinos são indesejáveis e perigosas. Um corredor com o mesmo nível de fadiga acumulada deve receber prescrições de treino idênticas ou extremamente próximas a cada consulta. Configurar $T = 0.0$ garante a **reprodutibilidade das sugestões** sob os mesmos parâmetros de entrada.

### 2.2 Aprendizado Few-Shot (Few-Shot Prompting)
LLMs respondem melhor a estruturas semânticas rígidas quando apresentadas a exemplos prévios de entrada e saída esperados dentro do prompt de sistema (Few-Shot Learning). 
*   Ao invés de apenas instruir o formato JSON, fornecer instâncias de mapeamento direto (fadiga extrema $\rightarrow$ treino regenerativo leve) reduz o espaço de busca e evita alucinações de formato ou de lógica.

**Motivação para o TCC**: O uso de poucas fotos/exemplos estruturados garante a consistência sintática do JSON retornado e guia o modelo conceitualmente sobre como aplicar as reduções fisiológicas.

### 2.3 Defesa em Profundidade: Guardrails em Código Swift (Determinismo Puro)
Embora a redução da temperatura minimize desvios, LLMs ainda estão sujeitas a falhas probabilísticas de raciocínio. Por isso, a arquitetura adota o princípio de **Defesa em Profundidade** (Defense in Depth).
*   **Camada Probabilística (LLM)**: O `CoachAgent` atua como um gerador de propostas baseado em heurísticas.
*   **Camada Determinística (Swift Nativo)**: O `PhysiologicalSafetyGuardrail` atua como um validador rígido e imutável que garante que, mesmo se a LLM falhar ou sugerir um treino inadequado, as regras fisiológicas estritas de segurança (limite de 60 minutos, atenuação em caso de fadiga ou overreaching) sejam executadas com 100% de previsibilidade no compilador.

---

## 3. Detalhamento Técnico das Alterações

### 3.1 Provedores de Rede: Forçando Temperatura 0.0

A temperatura padrão de todos os requests das APIs integradas será configurada para `0.0`:
*   `OpenAIRequest`: Configurado com default `temperature = 0.0` no inicializador.
*   `ClaudeRequest`: Configurado com default `temperature = 0.0` no inicializador.
*   `GeminiLLMProvider`: Modificação da chamada HTTP para forçar `temperature: 0.0` nas configurações de geração do payload JSON.

### 3.2 Prompts com Exemplos Few-Shot (`Prompts.swift`)

Inclusão de blocos de exemplos de entrada e saída reais para cada um dos agentes.
*   **LoadAgent**: Exemplo demonstrando a identificação de sobrecarga crônica ("overreaching").
*   **RecoveryAgent**: Exemplo que mapeia a queda de VFC (HRV) em relação à linha de base para o estado de fadiga ("fatigued").
*   **CoachAgent**: Exemplo demonstrando que o estado de fadiga força a redução sistemática das durações dos blocos e quedas para intensidade "Low" (Baixa).

### 3.3 Regras Avançadas do `PhysiologicalSafetyGuardrail.swift`

O guardrail passará a receber tanto o estado de recuperação (`recoveryStatus`) quanto o estado de carga crônica (`loadStatus`). A lógica executará três regras prioritárias:

1.  **Regra de Fadiga (Recuperação Baixa)**:
    *   Força intensidade baixa (`.low`).
    *   Limita blocos de trabalho a no máximo 5 minutos.
    *   Limita aquecimento e desaquecimento a no máximo 10 minutos.
2.  **Regra de Sobrecarga (Overreaching)**:
    *   Se o usuário estiver em `overreaching`, atenua a intensidade de qualquer bloco classificado como `.high` (Alta) para `.moderate` (Moderada).
    *   Limita blocos de trabalho a no máximo 8 minutos.
3.  **Regra de Limitação de Tempo Total (Cap de 60 minutos)**:
    *   Garante que o tempo total do treino de iniciantes não ultrapasse 60 minutos.
    *   Algoritmo: Se o tempo total exceder 60 minutos, reduz/remove blocos sequencialmente a partir do último. Se restar apenas um bloco, ajusta a duração deste até encaixar nos limites, ajustando também aquecimento e desaquecimento se necessário.

---

## 4. Critérios de Aceite (BDD)

### Cenário 1: Reprodutibilidade Completa (Temperatura 0.0)
*   **Given** que as mesmas métricas fisiológicas são enviadas para o orchestrator múltiplas vezes.
*   **When** os agentes processam a requisição.
*   **Then** a saída retornada deve ser idêntica e sem variações nas métricas do treino proposto.

### Cenário 2: Limitação de Tempo Total Excedido
*   **Given** que o `CoachAgent` sugeriu um treino longo de 70 minutos totais.
*   **When** a validação passa pelo `PhysiologicalSafetyGuardrail`.
*   **Then** o treino é ajustado dinamicamente para ter menos de 60 minutos.
