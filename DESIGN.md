---
version: alpha
colors:
  primary: "#16466B"
  accent: "#398B98"
  surface: "#FFFFFF"
  background: "#F5F8FB"
  text: "#0F2438"
  muted: "#5B6F82"
typography:
  heading:
    fontFamily: Cairo
    fontWeight: 700
  body:
    fontFamily: Cairo
    fontWeight: 700
rounded:
  card: 12px
  control: 8px
spacing:
  field: 12px
  section: 24px
---
# NewCare design
## Overview
An Arabic nursing-center logbook: rapid, legible data entry on a shared Windows device. Product register, rather than a marketing page. The signature is the official navy/teal Arabic logo, used with restraint in welcome and authentication surfaces.
## Colors
Runtime ownership remains `lib/core/theme/app_colors.dart`; this document records its intent and roles. Navy commits actions; teal identifies the center and synchronization. Red denotes money out, deletion or errors. Labels accompany status colors.
## Typography
Bundled Cairo Bold implements Arabic and English text, with clear bold numbers in financial tables. `lib/core/theme/app_theme.dart` remains the runtime type owner. No new font is introduced for startup.
## Layout
Operational screens stay compact and fill their available width. Authentication uses `NcAuthLayout`: a centered, naturally scrolling card capped at 480 logical pixels; padding reduces on phones. No workspace navigation is offered before setup. Use one primary action and a quiet account-mode link.
## Elevation & Depth
White surfaces with the existing subtle border. Avoid decorative dashboard cards or large empty side panels on startup.
## Shapes
Existing 12-pixel cards and 8-pixel controls. Preserve the official logo proportions.
## Components
Fields: `NcField`; buttons: `NcButton`; forms/cards: `NcCard`; identity heading: `AuthBrandHeading`. Brand motion remains in the existing splash, with reduced-motion support.
## Do's and Don'ts
Use Arabic first, localize all owned labels and tooltips, keep loading actions stable, and preserve input on failure. Never show preview passwords in cloud release mode or a fake online/matched status. Do not redesign operational screens for the startup change.
