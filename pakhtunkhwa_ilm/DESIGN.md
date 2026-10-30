---
name: Pakhtunkhwa Ilm
colors:
  surface: '#effdf3'
  surface-dim: '#cfddd4'
  surface-bright: '#effdf3'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#e9f7ed'
  surface-container: '#e3f1e7'
  surface-container-high: '#ddece2'
  surface-container-highest: '#d8e6dc'
  on-surface: '#121e18'
  on-surface-variant: '#3f4940'
  inverse-surface: '#27332d'
  inverse-on-surface: '#e6f4ea'
  outline: '#6f7a70'
  outline-variant: '#bec9be'
  surface-tint: '#0c6d3b'
  primary: '#005129'
  on-primary: '#ffffff'
  primary-container: '#086b3a'
  on-primary-container: '#92e9ab'
  inverse-primary: '#83d99c'
  secondary: '#006d3f'
  on-secondary: '#ffffff'
  secondary-container: '#8af9b4'
  on-secondary-container: '#007443'
  tertiary: '#5b4200'
  on-tertiary: '#ffffff'
  tertiary-container: '#785800'
  on-tertiary-container: '#ffd06f'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#9ef5b7'
  primary-fixed-dim: '#83d99c'
  on-primary-fixed: '#00210e'
  on-primary-fixed-variant: '#00522a'
  secondary-fixed: '#8af9b4'
  secondary-fixed-dim: '#6ddc9a'
  on-secondary-fixed: '#00210f'
  on-secondary-fixed-variant: '#00522e'
  tertiary-fixed: '#ffdea0'
  tertiary-fixed-dim: '#f3bf4b'
  on-tertiary-fixed: '#261900'
  on-tertiary-fixed-variant: '#5c4300'
  background: '#effdf3'
  on-background: '#121e18'
  surface-variant: '#d8e6dc'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.015em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 1rem
  margin-tablet: 1.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system establishes a focused, reassuring, and premium digital learning environment tailored for K-12 students, teachers, and parents across Khyber Pakhtunkhwa. Balancing public-sector dependability with modern, frictionless EdTech product design, the interface balances high-contrast legibility with an approachable, student-first sensibility.

### Design Movements & Tone
- **Modern Institutional Utility:** Clean lines, purposeful layouts, and robust structure drawn from contemporary Android design paradigms. It strips away academic clutter while maintaining scholarly dignity.
- **Organic Soft Tactility:** Crisp, pure white reading surfaces float atop a comforting warm off-white canvas with pill-shaped accents, subtle low-opacity shadows, and soft corner radii. This creates an inviting, tactile environment suited for long reading sessions without eye strain.
- **High-Affordance Accessibility:** Generous touch targets, high text-to-background contrast ratios (conforming to WCAG AAA for body content), and prominent offline/download status indicators guarantee performance and clarity on entry-level Android devices and low-connectivity environments.

## Colors

The palette draws deeply from the cultural landscape and visual identity of Khyber Pakhtunkhwa, anchored by verdant natural tones and balanced by warm paper neutrals.

### Roles & Application Rules
- **Primary (`#086B3A` - Deep Forest Green):** Used for top app bars, major module headers, active tab indicators, and deep authoritative anchors. Represents official textbook authenticity.
- **Secondary (`#0B8F55` - Rich Emerald Green):** Used for primary action buttons (e.g., "Download Book", "Start Quiz"), progress fills, active chapter states, and positive status chips.
- **Tertiary / Accent (`#FFCA55` - Accent Amber):** Reserved for high-value highlights, star ratings, revision bookmarks, exam notices, and achievement badges. Never use for standard interactive states.
- **Neutral Primary (`#17231D` - Dark Ink):** The primary color for all reading body text, headline titles, and high-emphasis interface labels.
- **Secondary Neutral (`#69756E`):** Governs metadata such as file sizes (e.g., "14.2 MB • PDF"), publication years, authors, and passive breadcrumbs.
- **Canvas & Surface:** `#F8FAF7` (Warm Off-White) serves as the persistent canvas backdrop, while `#FFFFFF` (Pure White) defines floating textbook cards, modal sheets, and reading viewports.
- **Subtle Surface Accent (`#DDF7E8` - Soft Mint):** Applied to active pill buttons, chapter completion indicators, and badge backgrounds.
- **System Feedback:** Download interruptions, sync issues, and destructive actions leverage Warning/Error Red (`#D94343`).

## Typography

The typography pairing uses **Plus Jakarta Sans** for structural identity and headings, alongside **Inter** for sustained technical legibility across mobile screens.

### Bilingual & Script Considerations
- **Urdu Script Adaptation:** When rendering Urdu localized content (e.g., Nastaliq or modern Naskh web font fallbacks), increase line height (`lineHeight`) by a minimum of `4dp` to `6dp` across all body tiers to accommodate ascenders and descenders without clipping.
- **Book Reader Context:** The E-Reader viewport permits student-driven scaling (`100%` to `150%`). Default reading text maps to `body-lg` (`16px/26px`) to reduce ocular fatigue during textbook study.
- **Numbers & Metrics:** Tabular numerals should be enabled for file sizes, chapter percentages, and page indexes to avoid horizontal layout jitter during updates.

## Layout & Spacing

The layout is anchored to an **8dp baseline grid** (with a secondary 4dp sub-unit for compact chips and icon alignments) to preserve native Android rhythm and responsive scalability.

### Breakpoints & Adaptive Rules
- **Handheld Portrait (< 600dp):** Fluid single-column view with a 4-column sub-grid for shelf displays. Canvas margins are locked to `16dp` (`margin`), with `12dp` gutters (`gutter-mobile`) between cards. Minimum touch target height is `48dp`.
- **Handheld Landscape / Small Tablets (600dp - 839dp):** Transitions to an 8-column layout. Margin expands to `24dp` (`margin-tablet`). Book shelves display in 3-column or 4-column card grids. E-reader split-pane reveals the chapter tree alongside the reading panel.
- **Classroom Tablets (≥ 840dp):** Fixed 12-column system constrained to an 1120dp maximum width container, centered on the display.

## Elevation & Depth

This system avoids heavy drop shadows, instead utilizing warm, ambient, tinted diffusions and soft structural borderlines (`#E5ECE6`) to deliver clarity under bright ambient classroom lighting.

### Elevation Hierarchy
- **Level 0 (Canvas):** Ground layer (`#F8FAF7`). No shadow. Holds primary screen containers and flat category selectors.
- **Level 1 (Card & Book Surface):** `#FFFFFF` surface layered with an ultra-subtle tinted shadow: `0px 2px 8px rgba(23, 35, 29, 0.04)` and a single hairline border (`1px solid #E5ECE6`). Used for standard book cards, unit listings, and chapter accordions.
- **Level 2 (Interactive Floating / Active Filter):** Active cards during tap states or selected state cards use `0px 6px 16px rgba(8, 107, 58, 0.08)`.
- **Level 3 (Sticky Headers & Navigation Bars):** Grounded by `#FFFFFF` with `0px 4px 12px rgba(23, 35, 29, 0.06)` or a bottom border rule (`1px solid #E5ECE6`) without blur.
- **Level 4 (Bottom Sheets, Dialogs & Offline Managers):** Floating surfaces layered at `0px 12px 32px rgba(23, 35, 29, 0.14)`. Scrim overlay applies `#17231D` at `40%` opacity.

## Shapes

The shape system leverages a standard **Rounded (Level 2)** geometry to evoke safety, friendliness, and modern handheld ergonomics.

### Structural Radius Scale
- **Default Elements (`8px`):** Small action chips, input text fields, progress bars, and metadata pill badges.
- **Large Elements (`16px`):** Textbook preview cards, subject container blocks, bottom sheets, and interactive quiz containers.
- **Extra Large Elements (`24px`):** Hero grade-level cards (e.g., "Class 9 - Science Group"), modal dialogue shells, and featured study alerts.
- **Pill (Fully Circular):** Primary action buttons ("Download", "Read Now"), audio narration controls, and active filter tags.

## Components

### Buttons
- **Primary Action (CTA):** Height `48dp`, background `#0B8F55`, foreground `#FFFFFF`, border-radius `24dp` (pill). Font is `label-lg`. Pressed state transitions to `#086B3A`.
- **Secondary / Offline Download:** Height `48dp`, background `#DDF7E8`, text `#086B3A`, border none. When downloading, it transitions into an integrated horizontal progress indicator.
- **Ghost / Tertiary:** Transparent background, text `#086B3A`, border `1px solid transparent`. Active press reveals `#DDF7E8` at `50%` opacity.

### Textbook & Resource Cards
- Constructed on a pure white surface (`#FFFFFF`) with a `16dp` radius and a `1px solid #E5ECE6` border.
- Layout features a vertical vertical book cover preview (aspect ratio 3:4), followed by subject tag (`label-sm`), textbook title (`title-md`), and class tag.
- Includes a bottom metadata row: file size (`body-sm` in `#69756E`) paired with an instant-state icon (Cloud for online-only, Check-Circle in `#0B8F55` for verified local storage).

### Grade & Subject Filter Chips
- Height `36dp`, rounded-full (`18dp`). 
- **Inactive:** Surface `#FFFFFF`, border `1px solid #E5ECE6`, text `#17231D`.
- **Active:** Surface `#DDF7E8`, border `1.5px solid #086B3A`, text `#086B3A`, font weight `600`.

### Form & Input Fields
- Height `52dp`, background `#FFFFFF`, border `1.5px solid #E5ECE6`, corner radius `12dp`. 
- Padding horizontal `16dp`. Placeholder text `#69756E`. 
- Focused state transforms the border to `#0B8F55` with an ambient glow (`box-shadow: 0 0 0 3px rgba(11, 143, 85, 0.15)`).

### Checkboxes & Radio Selectors
- Checkbox dimensions are `20x20dp` with a `4dp` corner radius. Checked background is `#086B3A` with a white check glyph.
- Radio buttons feature an outer ring in `#086B3A` with an inner solid circle (`10dp`).

### Offline Storage & Sync Indicators
- Sticky status component pinned below the top app bar during low-connectivity scenarios.
- Surface `#DDF7E8` with a compact `32dp` height, containing a synchronized status icon and micro-copy (`label-sm` in `#086B3A`) confirming: "Ready for Offline Study in Village Mode."