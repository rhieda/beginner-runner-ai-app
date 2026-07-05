---
name: VITALS Cyber-Athletic
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
  on-tertiary: '#2a3400'
  tertiary-container: '#caf300'
  on-tertiary-container: '#596c00'
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
  tertiary-fixed: '#caf300'
  tertiary-fixed-dim: '#b0d500'
  on-tertiary-fixed: '#171e00'
  on-tertiary-fixed-variant: '#3e4c00'
  background: '#131315'
  on-background: '#e5e1e4'
  surface-variant: '#353437'
  neon-green: '#A4FF00'
  electric-lime: '#D4FF00'
  data-cyan: '#00DBE9'
  data-blue: '#7DF4FF'
  surface-glass: rgba(28, 28, 30, 0.7)
  error-red: '#FFB4AB'
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
    fontFamily: Inter
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
VITALS is a high-performance health and fitness dashboard designed for the "cyber-athlete." The brand personality is aggressive, technical, and hyper-modern. It evokes the feeling of a futuristic head-up display (HUD) found in performance racing or sci-fi environments.

The design style is a hybrid of **Glassmorphism** and **High-Contrast / Bold** aesthetics. It utilizes deep dark surfaces, vibrant neon accents, and translucent layers to create a sense of focused energy and data precision. The target audience is data-driven athletes who value performance metrics and a cutting-edge visual experience.

## Colors
The palette is built on a "Total Dark" foundation using a deep charcoal neutral (#131315). The primary driver is **Neon Green**, used for critical path actions and healthy metrics. **Data Cyan** and **Electric Lime** serve as secondary accents to differentiate data streams.

Color application should follow a "glow-on-dark" principle:
- **Primary:** Neon Green for high-priority status and main action buttons.
- **Secondary/Tertiary:** Cyan and Lime for secondary data visualizations.
- **Glass surfaces:** Semi-transparent dark grays with subtle white borders to maintain legibility against the dark background.

## Typography
The system uses a dual-font approach. **Inter** handles all UI text, providing a clean, Swiss-style readability. **JetBrains Mono** is reserved for numerical data and metrics, emphasizing the technical, "calculated" nature of the product.

All "caps" labels should have increased letter spacing (5%) to improve scanability at small sizes. Display metrics use tight tracking to appear more impactful and integrated into the HUD style.

## Layout & Spacing
The system utilizes a **Fluid Grid** with a baseline unit of 4px. 

- **Mobile:** Single or double-column "Bento" style grid. 20px side margins. 16px gutters between cards.
- **Vertical Rhythm:** Sections are separated by a 32px margin. Internal card elements use a 12px stack gap.
- **Safe Areas:** The bottom of the screen includes a fixed action area with a 40px buffer to clear system navigation bars.

## Elevation & Depth
Hierarchy is established through **Glassmorphism** and **Tonal Layering**.

- **Level 0 (Background):** Deep matte surface (#131315).
- **Level 1 (Cards):** Glass-cards with 60% opacity, 20px backdrop blur, and a 1px 8% white border.
- **Level 2 (Active/Overlays):** 80% opacity glass with intense backdrop blurs.
- **Luminosity:** Depth is also conveyed via "Neon Glows." Critical elements use `drop-shadow` with the element's primary color at 25-40% opacity to simulate light emission.

## Shapes
The shape language is dominated by exaggerated **Pill-shaped** geometry. 

- **Main Containers/Cards:** Use 1rem (16px) rounding for standard cards.
- **Buttons/Pills:** Use full rounding (9999px) for a sleek, athletic feel.
- **Large Sections:** Use 2rem (32px) or 3rem (48px) for major layout containers.
- **Visual Flourishes:** Circular progress rings and rounded-end stroke paths in charts reinforce the organic but technical aesthetic.

## Components
- **Primary Buttons:** High-contrast, fully rounded pills using `primary-fixed` (Neon Green) background with `on-primary-fixed` (dark) text. Must include a `pill-glow` effect.
- **Glass Cards:** The primary container. Must have a subtle border and backdrop-filter. Padding is fixed at 16px (4 units).
- **Metric Rings:** Centrally aligned circular progress indicators with a stroke-width of 8px. Use linear gradients for the progress path.
- **Data Sparklines:** Minimalist, rounded stroke paths (2px width) with a semi-transparent area fill underneath.
- **Status Indicators:** Use small 6px pulses (animate-pulse) next to section headers to indicate "live" data.
- **Iconography:** Use Material Symbols (Outlined) with a weight of 400. Icons in data cards should often feature a low-opacity circular background of the icon's color.