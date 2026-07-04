---
name: Vitals Kinetic
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
  secondary: '#ffb4ab'
  on-secondary: '#690006'
  secondary-container: '#d30017'
  on-secondary-container: '#ffe2de'
  tertiary: '#ffffff'
  on-tertiary: '#00363a'
  tertiary-container: '#7df4ff'
  on-tertiary-container: '#006f77'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#a1fb00'
  primary-fixed-dim: '#8ddc00'
  on-primary-fixed: '#102000'
  on-primary-fixed-variant: '#304f00'
  secondary-fixed: '#ffdad6'
  secondary-fixed-dim: '#ffb4ab'
  on-secondary-fixed: '#410002'
  on-secondary-fixed-variant: '#93000c'
  tertiary-fixed: '#7df4ff'
  tertiary-fixed-dim: '#00dbe9'
  on-tertiary-fixed: '#002022'
  on-tertiary-fixed-variant: '#004f54'
  background: '#131315'
  on-background: '#e5e1e4'
  surface-variant: '#353437'
  neon-green: '#A4FF00'
  electric-lime: '#D4FF00'
  surface-glass: rgba(28, 28, 30, 0.7)
  data-blue: '#7DF4FF'
  data-cyan: '#00DBE9'
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
  data-tabular:
    fontFamily: JetBrains Mono
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 20px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
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

Vitals Kinetic is a high-performance bio-analytical platform designed for athletes and data-driven individuals. The brand personality is intense, technical, and precise, evoking the feeling of a professional telemetry suite.

The UI utilizes a **Glassmorphic** approach layered over a pure black, "infinite depth" background. It blends elements of **Cyberpunk/Vaporwave** (neon greens and high-contrast accents) with a strict **Minimalist** layout structure. The aesthetic prioritizes immediate legibility of metrics through "glowing" data visualizations and semi-transparent cards that feel like a head-up display (HUD).

## Colors

The palette is anchored in a "Deep Dark" mode, using absolute black (`#000000`) for the base canvas to maximize the luminance of the accent colors. 

- **Primary (Neon Green):** Used for "Ready" states, positive trends, and primary metrics. It represents optimal performance.
- **Secondary (Pulse Red):** Reserved for high-intensity heart rate metrics or critical alerts.
- **Tertiary (Electric Blue):** Dedicated to recovery, sleep, and restorative data streams.
- **Neutral:** A range of deep grays and transparent whites are used for container borders and secondary labels to maintain the HUD aesthetic without competing with data.

Gradient treatments, specifically a transition from `#A4FF00` to `#D4FF00`, are used to denote progress and energy levels.

## Typography

The system uses a dual-font strategy:
1. **Inter** is the workhorse for structural UI, headlines, and descriptive text. Its high x-height ensures clarity on dark backgrounds.
2. **JetBrains Mono** is the "data soul" of the system. It is used for all numerical values, tabular data, and metrics, emphasizing the technical, measured nature of the product.

Hierarchy is strictly enforced through weight (Extrabold for titles) and casing (Caps for metadata/labels). Metrics use a display weight to stand out against the glass backgrounds.

## Layout & Spacing

The layout follows a **Fluid Grid** model designed for mobile-first consumption but scalable to dashboard views. 

- **Vertical Rhythm:** Components are grouped into sections separated by a `32px` margin. Within sections, a "Bento Box" grid is used with `16px` gutters.
- **Safe Zones:** A standard horizontal padding of `20px` ensures content remains clear of bezel edges.
- **Alignment:** Centralized "Hero" metrics (like the Readiness Ring) establish the focus, while secondary data is distributed in 2-column or full-width "wide" cards.

## Elevation & Depth

Depth is created through **Glassmorphism** rather than traditional shadows. 

- **Surface 0 (Background):** Pure black (`#000000`).
- **Surface 1 (Cards):** Semi-transparent dark grey with a 20px backdrop blur and a `1px` subtle white outline (8% opacity). This creates a "hovering" effect.
- **Neon Glows:** Primary active elements (like the Readiness ring or recovery bars) use `drop-shadow` effects with 40-60% opacity of the primary color to simulate light emission.
- **Navigation:** The TopBar and BottomNav use an 80% opacity blur to suggest they are the topmost layer in the stack.

## Shapes

The design uses a high-radius shape language to offset the technical "hardness" of the monospaced fonts and high contrast colors.

- **Primary Containers:** 1rem (`16px`) rounded corners.
- **Large Layout Blocks:** 2rem to 3rem for specialized hero sections.
- **Interactive Elements:** Buttons and active navigation states use pill-shapes (full rounding) to indicate touch targets.
- **Data Accents:** Small bars within charts use 2px rounding to maintain a clean, architectural look.

## Components

### Cards (Glass Cards)
Cards are the primary container. They must have a `backdrop-filter: blur(20px)`, a semi-transparent background, and a thin `1px` border (`rgba(255,255,255,0.08)`).

### Buttons & Navigation
- **Top AppBar:** Minimal, transparent background with blur. Icons should be `24px` Material Symbols.
- **Bottom Navigation:** Uses a frosted glass effect with a top border. Active states are indicated by a tinted background pill (`primary/10`) and a color shift to the primary neon.

### Data Visualizations
- **Progress Rings:** Use large stroke widths (8px) with rounded caps and a glowing "neon" drop shadow.
- **Barcharts:** Uniform width bars with rounded tops. Use varying opacities of the tertiary color to show intensity or distribution.
- **Pulse Indicators:** Small glowing dots (animate-pulse) used next to "Live" or "State" headers.

### Lists & Activity
Activity items are simplified glass cards with 12px padding, utilizing `primary-container/10` for icon backgrounds to create a "squircle" housing for symbols.