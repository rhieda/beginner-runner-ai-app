# Feature Spec: Vitals Dashboard with Trends

## 1. Visão Geral
O **Vitals Dashboard with Trends** é a tela central do aplicativo `Beginner-Runner-AI-Coach`. O objetivo da tela é fornecer ao usuário iniciante uma visão imediata de sua prontidão biológica (Readiness), tendências de 7 dias de HRV (Variabilidade da Frequência Cardíaca) e RHR (Frequência Cardíaca de Repouso), e estados de forma física e recuperação. 

A partir desta tela, o usuário pode solicitar a geração de um treino personalizado e adaptado ao seu estado fisiológico através do pipeline multiagente.

---

## 2. Contratos de Dados (Domain)

### Entidades do Domínio
- `HealthDataBaseLocalSample`: Representa amostras temporais individuais de HRV e RHR obtidas do HealthKit.
- `WorkoutSample`: Representa sessões de treino passadas com duração, frequência cardíaca média e máxima.
- `CustomWorkoutComposition`: Estrutura do treino gerado pelo pipeline de IA (aquecimento, blocos e desaquecimento).

### Regras de Negócio e Cálculos Fisiológicos
1. **Verificação de Permissões no Carregamento:** Ao iniciar a tela (no modificador `.task`), o aplicativo deve verificar a autorização de leitura do HealthKit. Se não concedida, deve-se disparar a solicitação e, em caso de recusa definitiva, transicionar para o estado `.notAuthorized`.
2. **Índice de Prontidão (Readiness Score):** Calculado no domínio com base na relação entre a média móvel de 7 dias e a de 30 dias de HRV:
   $$Readiness = \min\left(100, \max\left(0, \frac{\text{HRV 7d Avg}}{\text{HRV 30d Avg}} \times 86\right)\right)$$
   *Nota: Se as médias móveis de 7 ou 30 dias de HRV forem nulas devido a dados insuficientes, o escore de prontidão é definido como `0` e rotulado como `"INDISPONÍVEL"`.*
3. **Forma Física (Fitness State):** Determinado prioritariamente via inferência inteligente do `LoadAgent` (analisando a intensidade TRIMP e o histórico de treinos recentes). Em caso de falha de conexão ou timeout na inferência, o sistema realiza o fallback automático para o mapeamento fisiológico determinístico local:
   - Sem treinos recentes: **Sem dados**
   - TRIMP > 80: **Sobrecarga** (`overreaching`)
   - TRIMP entre 40 e 80: **Em Forma** (`adapting`)
   - TRIMP < 40: **Pouco Treino** (`undertraining`)
   *Nota: Esses limites (40 e 80) são uma proposição arbitrária temporária para exibição na UI offline e devem ser sinalizados no código-fonte com um comentário explicativo (`// TODO: rever limites de TRIMP após validação científica`).*
4. **Estado Atual (Recovery State):** Determinado prioritariamente via inferência inteligente do `RecoveryAgent` (analisando as médias móveis de HRV de 7 e 30 dias). Em caso de falha na inferência, o sistema realiza o fallback automático para a regra fisiológica determinística local:
   - Médias de HRV nulas / Dados insuficientes: **Sem dados**
   - HRV 7d >= HRV 30d: **Descansado** (`recovered`)
   - HRV 7d < HRV 30d: **Fadigado** (`fatigued`)

---

## 3. Comportamento e Estados da UI (Feature Layer)

### Estados do Store (`VitalsDashboardStore.State`)
A View reage aos seguintes estados mantidos no Store:
- **.checkingPermissions**: Estado inicial durante a validação de acesso ao HealthKit.
- **.notAuthorized**: Permissão de acesso ao HealthKit negada pelo usuário (exibe tela de placeholder de erro).
- **.loadingData**: Buscando dados históricos do HealthKit.
- **.emptyData**: Dados carregados com sucesso, mas o histórico está vazio (sem amostras).
- **.loaded(VitalsDashboardData)**: Dados obtidos e processados com sucesso.
- **.generatingWorkout(logs: [String])**: Executando o pipeline multiagente para gerar o treino.

---

### Critérios de Aceite (BDD)

#### Cenário 1: Checagem de Permissões ao Carregar (Task Modifer)
- **Given** que o usuário abre o aplicativo e a `VitalsDashboardView` é carregada.
- **When** o modificador `.task` é acionado.
- **Then** a aplicação deve invocar `checkPermissionsAndLoadData()` no Store, exibindo o estado `.checkingPermissions`.

#### Cenário 2: Acesso ao HealthKit Negado
- **Given** que a checagem de permissões está em execução.
- **When** a resposta de autorização do HealthKit for negada.
- **Then** o Store transiciona para o estado `.notAuthorized` e a View renderiza a `VitalsDashboardErrorPlaceholderView`.

#### Cenário 3: Carregamento de Dados com Sucesso (Métricas e Gráficos)
- **Given** que o acesso ao HealthKit é autorizado.
- **When** a busca de HRV (30 dias), RHR (7 dias) e Workouts (7 dias) retorna dados válidos.
- **Then** o Store calcula as médias móveis, monta os arrays de tendências de 7 dias para os sparklines, calcula o escore de prontidão e transiciona para o estado `.loaded`.

#### Cenário 4: Geração de Treino de Corrida
- **Given** que o dashboard está no estado `.loaded`.
- **When** o usuário clica no botão "Gerar Treino de Corrida".
- **Then** o Store transiciona para `.generatingWorkout`, exibe um overlay glassmorphic com o log incremental da IA e, após a conclusão do pipeline, apresenta a `WorkoutPreviewView` em fullscreen (`.fullScreenCover`).

---

## 4. Design System / UI

### Componentes Customizados
1. **`SparklineChartView`**:
   - Desenha a linha de tendência com uma curva suave usando SwiftUI `Path`.
   - Inclui efeito de brilho neon via `.neonGlow()`.
   - Adiciona preenchimento de gradiente linear de opacidade do verde neon para transparente sob a curva.
   - Exibe o valor máximo (`MAX`), mínimo (`MIN`), média (`MÉD`) e ícone indicador de tendência de forma dinâmica.
2. **`VitalsDashboardErrorPlaceholderView`**:
   - Cartão glassmorphic centralizado com ícone de alerta e instrução para habilitar o HealthKit, contendo botão "Conceder Acesso".

### Diretrizes de Layout
- Fundo em preto puro (#000000) e cartões com `.glassCard()`.
- Espaçamentos e tipografia estritamente alinhados aos tokens definidos em `Theme.Spacing` e `Theme.Typography`.
