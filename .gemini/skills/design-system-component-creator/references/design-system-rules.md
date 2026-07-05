# Vitals Kinetic Design Rules

This reference document outlines the layout rhythm, spacing tokens, and color rules for constructing UI screens in the Beginner Runner AI Coach app.

## 1. Spacing & Rhythm (Theme.Spacing)

Ensure that all paddings, margins, and gaps use the layout spacing tokens:
* **Unit Gap (`Theme.Spacing.unit` = 4pt)**: Smallest spacing used for tightly coupled views (e.g., small labels next to icons, padding inside micro badges).
* **Stack Gap (`Theme.Spacing.stackGap` = 12pt)**: Default spacing inside vertical or horizontal stacks (`VStack(spacing: Theme.Spacing.stackGap)`).
* **Grid Gutter (`Theme.Spacing.gridGutter` = 16pt)**: Spacing between grid elements or standard list items in Bento box grids.
* **Container Padding (`Theme.Spacing.containerPadding` = 20pt)**: Outer padding of views, page margins, and card borders.
* **Section Margin (`Theme.Spacing.sectionMargin` = 32pt)**: Distinct margin separating high-level blocks/sections of the screen.

## 2. Corner Radii (Theme.Radius)

* **Small (`Theme.Radius.sm` = 8pt)**: Used for small indicators, inline tags, status capsules, and inputs.
* **Default (`Theme.Radius.default` = 16pt)**: Standard card containers (e.g., activity cards, stat summaries).
* **Medium (`Theme.Radius.md` = 24pt)**: Heavy section boxes, large overlay panels.
* **Large (`Theme.Radius.lg` = 32pt)**: Prominent header backgrounds or floating screens.
* **Full (`Theme.Radius.full` = 9999pt)**: Circular progress rings, pills, and pill-buttons.

## 3. Color Usage & States

Avoid raw Hex codes in code. Use the designated tokens in `Theme.Colors`:

| State / Meaning | Design System Color | Swift Code Mapping |
| :--- | :--- | :--- |
| **Canvas Background** | Pure Black (`#000000`) | `Theme.Colors.background` |
| **Containers / Cards** | Glassmorphic overlay | `.glassCard()` modifier |
| **Ready / Optimal state** | Neon Green / Electric Lime | `Theme.Colors.neonGreen`, `Theme.Colors.electricLime`, or `Theme.Colors.primaryContainer` |
| **Rest / Active Blue** | Electric Blue | `Theme.Colors.tertiaryContainer` |
| **High Strain / Warning** | Pulse Red | `Theme.Colors.secondaryContainer` |
| **Primary Text** | Solid White | `Theme.Colors.primary` |
| **Secondary Text** | Muted Gray-Green | `Theme.Colors.onSurfaceVariant` |

## 4. Layout Structure

Every screen should follow a consistent top-to-bottom layout structure:
1. **Dynamic HUD Header**: A clean top area containing title, subtitle, and possibly a pulsing live status dot (`PulseIndicator`) or a small utility button.
2. **Hero Telemetry**: A central focal point showing primary readiness, status, or progress (using `TelemetryRing` or similar ring indicators).
3. **Bento Box Detail Grid**: Stacked details or horizontal columns showing secondary metrics (e.g., HRV, Heart Rate, TRIMP) housed in glassmorphic cards.
4. **Bottom Active Action**: Highly visible pill-shaped action buttons for initiating workouts or routines.
