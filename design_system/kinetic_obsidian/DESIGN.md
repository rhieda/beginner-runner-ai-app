---
name: Vitals Cyber-Athletic
colors:
  surface: '#131315'
  surface-dim: '#131315'
  surface-bright: '#39393b'
  surface-container-lowest: '#0e0e10'
  surface-container-low: '#1b1b1d'
  surface-container: '#1f1f21'
  surface-container-high: '#2a2a2c'
  surface-container-highest: '#353437'
  on-surface: '#e5e1e4'
  on-surface-variant: '#c0caad'
  inverse-surface: '#e5e1e4'
  inverse-on-surface: '#303032'
  outline: '#8a947a'
  outline-variant: '#414a34'
  surface-tint: '#8ddc00'
  primary: '#ffffff'
  on-primary: '#203700'
  primary-container: '#a1fb00'
  on-primary-container: '#457000'
  inverse-primary: '#416900'
  secondary: '#7ef4ff'
  on-secondary: '#00363b'
  secondary-container: '#01dbe9'
  on-secondary-container: '#005c62'
  tertiary: '#ffffff'
  on-tertiary: '#690006'
  tertiary-container: '#ffdad6'
  on-tertiary-container: '#cb0016'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#a1fb00'
  primary-fixed-dim: '#8ddc00'
  on-primary-fixed: '#102000'
  on-primary-fixed-variant: '#304f00'
  secondary-fixed: '#7ef4ff'
  secondary-fixed-dim: '#01dbe9'
  on-secondary-fixed: '#002022'
  on-secondary-fixed-variant: '#004f55'
  tertiary-fixed: '#ffdad6'
  tertiary-fixed-dim: '#ffb4ab'
  on-tertiary-fixed: '#410002'
  on-tertiary-fixed-variant: '#93000c'
  background: '#131315'
  on-background: '#e5e1e4'
  surface-variant: '#353437'
  electric-lime: '#D4FF00'
  surface-glass: rgba(28, 28, 30, 0.7)
  data-cyan: '#00DBE9'
  neon-glow: rgba(164, 255, 0, 0.4)
typography:
  display-metrics:
    fontFamily: JetBrains Mono
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 38px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '800'
    lineHeight: 32px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 26px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
  data-tabular:
    fontFamily: JetBrains Mono
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 20px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  unit: 4px
  stack-gap: 12px
  grid-gutter: 16px
  container-padding: 20px
  section-margin: 32px
---

## Brand & Style
The brand personality is high-performance, technical, and aggressive, designed for elite athletes and biohackers who view their body as a high-precision machine. It evokes a "Cyber-Athletic" aesthetic—combining the dark, data-heavy visuals of sci-fi interfaces with the high-visibility energy of modern sportswear.

The design style is a hybrid of **Glassmorphism** and **High-Contrast Bold**. It utilizes deep obsidian surfaces, ultra-vibrant neon accents, and translucent layers with intense backdrop blurs to create a sense of focused, "head-up display" (HUD) clarity.

## Colors
The palette is dominated by a "Midnight Obsidian" neutral base to maximize the impact of functional neon signals. 

- **Primary (Neon Green):** Used for critical readiness metrics, calls to action, and "optimal" status states. It is the primary light source in the UI.
- **Secondary (Data Cyan):** Reserved for recovery, sleep, and secondary biometric data points to provide visual distinction from active effort metrics.
- **Neutral:** A range of deep grays and near-blacks (#0E0E10 to #1F1F21) provide the foundation for layered glass effects.
- **Functional Accents:** High-saturation glows are used to signify active states or positive trends, while muted variants are used for stable or inactive data.

## Typography
The system uses a dual-font approach to balance readability with a technical feel. 

**Inter** is the workhorse for headlines and body text, utilizing heavy weights (800+) for a bold, impactful brand presence. 

**JetBrains Mono** is used for all "Data" layers—metrics, labels, and status indicators. This adds a systematic, monospaced aesthetic that reinforces the feeling of a precision instrument. Tabular figures are essential for comparing heart rates and time-based metrics.

## Layout & Spacing
The layout follows a **Fluid Bento Grid** model. On mobile, components occupy either a full-width slot or a 2-column split. 

- **Margins:** 20px side margins provide breathing room on narrow devices.
- **Vertical Rhythm:** A 12px gap is maintained between stacked items within a section, while larger sections are separated by 32px to create a clear hierarchy of information clusters.
- **Interactive Zones:** Primary actions are fixed to the bottom of the viewport with a blurred "safe area" background to ensure thumb accessibility and persistent visibility.

## Elevation & Depth
Depth is achieved through **Glassmorphism** and **Luminous Layering** rather than traditional drop shadows.

- **Surface Layers:** The background is #131315. "Cards" use a semi-transparent fill (`rgba(28, 28, 30, 0.6)`) with a 20px backdrop blur and a 1px subtle white border at 8% opacity.
- **Active Elevation:** Elements do not "lift" off the page; instead, they "glow." Use `drop-shadow` with the primary color at 40% opacity for critical metrics and active buttons.
- **Interaction Depth:** On press, elements scale down slightly (95-96%) and increase their glow intensity, simulating a physical pressure-sensitive surface.

## Shapes
The shape language is dominated by generous, organic curves that contrast with the sharp, technical typography.

- **Base Cards:** Use `rounded-lg` (1rem / 16px) for standard metric containers.
- **Primary Buttons & Pills:** Use "Full" roundedness (9999px) to create distinct, tappable targets that stand out from the rectangular grid.
- **Icons:** Enclosed in circular containers or displayed as clean, optical-grid-aligned glyphs with a 400-weight stroke.

## Components

### Buttons
- **Primary Action:** Full-width, 64px height, Pill-shaped. Background uses `primary-fixed` (#A4FF00) with dark text. Includes a heavy external glow.
- **Icon Buttons:** Circular or simple ghost icons with `on-surface-variant` colors, increasing in opacity on hover.

### Cards (Bento Boxes)
- **Metric Cards:** Use the `glass-card` style. Headlines are `label-caps` in `on-surface-variant`. Main data uses `display-metrics` or `headline-lg`.
- **Status Cards:** Feature a leading circular icon container with a low-opacity tint of the category color (e.g., 10% green for fitness).

### Data Visualization
- **Progress Rings:** Use a 6px to 8px stroke width. Background tracks are nearly transparent. The active progress uses a linear gradient (Neon Green to Electric Lime) and a `neon-glow` filter.
- **Trend Indicators:** Tiny Material Symbols (trending_up/down) paired with `label-caps` text, color-coded to the metric's health.

### Navigation
- **Top Bar:** Fixed, 64px height, with a high-intensity backdrop blur and a subtle bottom border.
- **Bottom Action Bar:** A floating or fixed container that uses the `surface-dim` background at 80% opacity to let content peek through while maintaining button legibility.