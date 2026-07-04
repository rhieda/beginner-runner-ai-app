---
name: design-system-component-creator
description: Guidelines and SwiftUI templates for creating UI components following the Vitals Kinetic (Kinetic Obsidian) design system, focusing on glassmorphism, HUD telemetry aesthetic, and specific styling rules.
---

# Design System Component Creator Skill

Use this skill when designing, building, or modifying SwiftUI user interface components in the app. All components must adhere strictly to the **Vitals Kinetic** (Kinetic Obsidian) design specification.

## Core Styling Principles

1. **Depth over Shadow**: 
   * Avoid drop shadows for elevation. Use the custom glassmorphism modifier `.glassCard()` defined in [ViewModifiers.swift](file:///Users/rafaelhieda/Documents/repos/tcc/beginner-runner-ai-app/Beginner-Runner-AI-Coach/Beginner-Runner-AI-Coach/Core/DesignSystem/Components/ViewModifiers.swift).
   * Active, glowing telemetry metrics use `.neonGlow(color:radius:)`.
2. **Infinite Canvas**:
   * The base view background must always be pure black (`Theme.Colors.background` / `#000000`) or a very dark surface container (`Theme.Colors.surfaceContainerLowest` / `#0e0e10`).
3. **Monospaced Data**:
   * All metrics, values, counts, scores, and timestamps must use `Theme.Typography.displayMetrics` or `Theme.Typography.dataTabular` (JetBrains Mono).
4. **Descriptive Labels**:
   * Use capitalized labels with extra tracking/kerning for section headers and captions via `Theme.Typography.labelCaps` with `.kerning(1.2)`.

## Task Workflow

### 1. Verification & Specification
* Check the corresponding Spec in `docs/specs/` to align with the visual and functional requirements.
* Determine if the component is feature-specific (place in `Features/<FeatureName>/Components/`) or cross-cutting / globally reusable (place in `Core/DesignSystem/Components/`).

### 2. Design Tokens Mapping
* Reference colors, typography, spacing, and corner radii strictly from [Theme.swift](file:///Users/rafaelhieda/Documents/repos/tcc/beginner-runner-ai-app/Beginner-Runner-AI-Coach/Beginner-Runner-AI-Coach/Core/DesignSystem/Theme.swift). Do **not** hardcode color Hex values or magic numbers.

### 3. Component Implementation
* Wrap secondary containers in `.glassCard()`.
* Add custom previews using mock data defined under `Preview Content`.

## References

* [design-system-rules.md](references/design-system-rules.md) — Spacing tokens, layout rhythm, color guidelines, and code snippets.
* [code-templates.md](references/code-templates.md) — SwiftUI code examples for buttons, cards, list items, and status indicators.
