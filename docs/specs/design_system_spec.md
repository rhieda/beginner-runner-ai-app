# Feature Spec: Vitals Kinetic Design System

## 1. Visão Geral
Esta especificação define a implementação do design system **Vitals Kinetic** (Kinetic Obsidian) no aplicativo `Beginner-Runner-AI-Coach`. O objetivo é transformar a interface em uma experiência imersiva de alta performance voltada para atletas (HUD - Head-Up Display), baseada em profundidade por glassmorfismo, contraste com fundo preto puro, destaques em verde neon e azul elétrico, e tipografia técnica.

A implementação limita a aparência do aplicativo para **Dark Mode fixo** e substitui layouts de tabelas padrão (`List`) por contêineres customizados em `ScrollView`.

---

## 2. Estrutura do Design System (Core)

Os tokens do design system serão expostos através do namespace `Theme` para centralizar cores, espaçamentos, cantos arredondados e tipografia.

### Cores (`Theme.Colors`)
As cores seguem a especificação de `kinetic_obsidian/DESIGN.md`:
- **Canvas Base / Fundo:** `background` (#000000 - Preto Absoluto).
- **Superfície Principal:** `surface` (#131315).
- **Recipientes de Vidro (Glass):** `surfaceGlass` (rgba(28, 28, 30, 0.7) com desfoque de fundo de 20px).
- **Borda de Vidro:** `borderGlass` (rgba(255, 255, 255, 0.08) com espessura de 1px).
- **Destaque Primário (Verde Neon):** `neonGreen` (#A4FF00) / `primaryContainer` (#a1fb00).
- **Destaque Secundário (Vermelho de Alerta):** `secondaryContainer` (#d30017) / `secondary` (#ffb4ab).
- **Destaque Terciário (Azul Elétrico):** `tertiaryContainer` (#7df4ff).
- **Texto:** `primary` (#ffffff), `onSurface` (#e5e1e4), `onSurfaceVariant` (#c0caad).

### Espaçamento (`Theme.Spacing`)
- `unit`: 4pt (unidade de base)
- `stackGap`: 12pt (espaço entre elementos em pilhas)
- `gridGutter`: 16pt (espaço de grade)
- `containerPadding`: 20pt (margens laterais seguras)
- `sectionMargin`: 32pt (margem entre seções principais)

### Cantos Arredondados (`Theme.Radius`)
- `sm`: 8pt
- `default`: 16pt
- `md`: 24pt
- `lg`: 32pt
- `xl`: 48pt
- `full`: 9999pt (Estilo Pill/Cápsula)

### Tipografia (`Theme.Typography`)
Usa fontes nativas com pesos específicos para simular Inter e JetBrains Mono:
- `displayMetrics`: Fonte monospacada de 48pt com peso negrito (para números de destaque).
- `headlineLg`: Fonte padrão de 32pt com peso black.
- `headlineMd`: Fonte padrão de 24pt com peso negrito.
- `bodyLg`: Fonte padrão de 18pt com peso regular.
- `bodySm`: Fonte padrão de 14pt com peso regular.
- `dataTabular`: Fonte monospacada de 16pt com peso médio.
- `labelCaps`: Fonte padrão de 12pt com peso negrito (usada com caixa alta e espaçamento entre letras).

---

## 3. Comportamento e Estados da UI (Feature Layer)

### Refatoração das Views Existentes

#### A. Menu Principal (`ContentView`)
- Fundo preto absoluto.
- O link para "Open Provider Sandbox" deve ser renderizado como um `GlassCard` com cantos `Theme.Radius.default`.
- Ícones com destaque em verde neon.
- Força a aparência escura (`.preferredColorScheme(.dark)`).

#### B. Painel de Testes (`SandboxView`)
- Transforma a tela de `List` para `ScrollView`.
- Agrupa seções (HealthKit, AI Orchestrator, Simulated Biometrics, Data Providers, Logs) em contêineres `GlassCard` individuais.
- Controles interativos (Pickers, Sliders, Toggles, botões de ação) reestilizados:
  - Sliders com barra de progresso no tom cinza escuro e controle deslizante com brilho neon verde.
  - Botões secundários usando borda fina translúcida.
  - Seção de Logs com tipografia monospacada `Theme.Typography.dataTabular` e fundo escuro.

#### C. Visualização de Treino (`WorkoutPreviewView`)
- Transforma a tela de `List` para `ScrollView`.
- As seções (Aquecimento, Blocos de Treino, Desaquecimento) usam cartões assimétricos com barra vertical indicadora colorida na borda esquerda:
  - **Aquecimento (Warmup):** Indicador lateral em Azul (`Theme.Colors.tertiaryContainer`).
  - **Blocos de Trabalho (Work):** Indicador lateral em Laranja/Vermelho (`Theme.Colors.secondary`).
  - **Recuperação (Recovery):** Indicador lateral em Verde Neon (`Theme.Colors.primaryContainer`).
  - **Desaquecimento (Cooldown):** Indicador lateral em Azul (`Theme.Colors.tertiaryContainer`).
- Botão "Send to Apple Watch" reestilizado como um botão proeminente em forma de pílula (`Theme.Radius.full`), fundo em verde neon e sombra brilhosa (`drop-shadow` de 40% de opacidade).

### Critérios de Aceite (BDD)

- **Cenário 1: Renderização com Fundo Escuro HUD**
  - **Given** que o usuário inicia o aplicativo ou navega pelas telas do Sandbox e Preview.
  - **Then** o fundo geral da tela deve ser preto absoluto (#000000), os cartões devem ser translúcidos com efeito de vidro fosco, e o esquema de cores deve ser restrito ao modo escuro.

- **Cenário 2: Layout de Cartão de Vidro (GlassCard)**
  - **Given** que o SandboxView exibe as seções de simulação.
  - **Then** cada seção deve ter bordas finas arredondadas (16pt), um fundo semi-transparente e desfoque nativo, sem sombras escuras tradicionais.

- **Cenário 3: Exibição de Métricas com Alinhamento Monospacado**
  - **Given** que o usuário visualiza dados simulados de TRIMP e HRV na tela de Sandbox ou no Preview.
  - **Then** as métricas numéricas devem ser exibidas com a fonte de sistema monospacada para evitar flutuação na largura dos números ao alterar os valores via Slider.

- **Cenário 4: Micro-animações de Estado**
  - **Given** que a tela exibe estados "Live" ou carregamento ativo.
  - **Then** deve ser exibido um indicador circular verde com animação de pulso contínuo (escala entre 1.0 e 1.5, opacidade alternando de 1.0 para 0.4).

---

## 4. Componentes Compartilhados (`Core/DesignSystem/Components`)

1. **`GlassCard` / `.glassCard()`**:
   Aplica o fundo com material `.ultraThinMaterial`, a sobreposição de `Theme.Colors.surfaceGlass`, a borda fina `Theme.Colors.borderGlass` e a curvatura `Theme.Radius.default`.
2. **`PulseIndicator`**:
   Um círculo que executa uma animação repetitiva de pulsação infinita.
3. **`TelemetryRing`**:
   Um anel de progresso circular desenhado com `StrokeStyle(lineWidth: 8, lineCap: .round)`, gradiente linear neon do verde ao amarelo limão e brilho sutil.

---
*Esta especificação deve ser seguida rigorosamente pela IA durante a implementação.*
