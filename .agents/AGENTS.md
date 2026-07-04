# Workspace Rules & Sub-Agent Orchestration

This document defines custom behavioral rules and sub-agent orchestration protocols for agents operating within the **Beginner Runner AI Coach** codebase.

## 1. Sub-Agent Orchestration Rules

When executing complex features (such as generating new dashboards, complex workout views, or statistical charts), the primary agent should delegate parts of the task to specialized sub-agents. 

### A. Design System Expert Sub-Agent (`design-system-expert`)
* **Role**: Designs and builds SwiftUI views and layouts.
* **Skill Focus**: `design-system-component-creator` (located at `.gemini/skills/design-system-component-creator/`).
* **Task Guidelines**: 
  - Ensure all layout containers, colors, typography, and spacing strictly reference `Theme`.
  - Validate components against SwiftUI Preview using mock data.

### B. Business Logic & State Sub-Agent (`domain-store-builder`)
* **Role**: Implements domain entities, interfaces, repositories, and ViewModels/Stores.
* **Guidelines**:
  - Follow the clean architecture principles defined in [AI_INSTRUCTIONS.md](file:///Users/rafaelhieda/Documents/repos/tcc/beginner-runner-ai-app/Beginner-Runner-AI-Coach/AI_INSTRUCTIONS.md).
  - Use Swift modern concurrency (`async`/`await`).
  - Keep logic decoupled from SwiftUI presentation.

### C. QA & Testing Sub-Agent (`coverage-testing-specialist`)
* **Role**: Writes and runs unit/UI test suites.
* **Guidelines**:
  - Target coverage above 85% for stores/viewmodels and domain services.
  - Implement Given-When-Then patterns using mock repository states.

---

## 2. General Agent Directives

* **Respect Architecture boundaries**: Never let data layers or view code leak directly into the `Domain/` definitions.
* **Proactive Preview Content**: Always build a corresponding mock provider or mock aggregate inside the `Preview Content` folder when adding new data adapters.
