---
name: DummyJSON Store
description: A tidy one-color Material 3 store — Confident Teal on white paper, honest prices in green.
colors:
  confident-teal: "#00796B"
  honest-green: "#2E7D32"
  alert-red: "#D32F2F"
  banner-red-deep: "#B71C1C"
  banner-red-wash: "#FFEBEE"
  star-amber: "#FFC107"
  text-grey: "#616161"
  line-grey: "#9E9E9E"
  paper: "#FFFFFF"
  ink: "#000000"
typography:
  display:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "26px"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "normal"
  headline:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "24px"
    fontWeight: 700
    lineHeight: 1.25
    letterSpacing: "normal"
  title:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "18px"
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: "normal"
  body:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: "normal"
  label:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: "normal"
rounded:
  field: "8px"
  media: "8px"
  card: "12px"
  pill: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "24px"
  xxl: "32px"
components:
  button-primary:
    backgroundColor: "{colors.confident-teal}"
    textColor: "{colors.paper}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    height: "48px"
  button-secondary:
    backgroundColor: "transparent"
    textColor: "{colors.confident-teal}"
    typography: "{typography.body}"
    rounded: "{rounded.pill}"
  text-field:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink}"
    rounded: "{rounded.field}"
    padding: "16px 14px"
  card:
    backgroundColor: "{colors.paper}"
    rounded: "{rounded.card}"
  banner-error:
    backgroundColor: "{colors.banner-red-wash}"
    textColor: "{colors.banner-red-deep}"
    rounded: "{rounded.field}"
    padding: "12px"
  app-bar:
    backgroundColor: "{colors.confident-teal}"
    textColor: "{colors.paper}"
    typography: "{typography.title}"
---

# Design System: DummyJSON Store

## Overview

**Creative North Star: "The Tidy Counter"**

DummyJSON Store looks like a small neighborhood shop where everything has its place. One confident teal owns the room — the app bar, the splash, the primary buttons, the focus of every field. Everything else is white paper, black ink and one grey voice, so a visitor can scan any screen in seconds and an evaluator can see the discipline instantly.

The system is deliberately plain: stock Material 3 components, no custom chrome, no gradients, no second accent. The craft lives in precision instead — a 48dp primary button, one 8dp radius shared by every custom surface, text colors verified against WCAG AA, and a price language that never lies. Expression is spent only inside Material's own theming slots (color roles, type scale, shape, motion).

It is a teaching system as much as a store: every text style is named by formula, every gap comes from a spacing helper, and every screen is assembled from the same small set of components. New screens stay on-brand by reusing the counter, not by improvising.

**Key Characteristics:**
- One brand color — Confident Teal (#00796B) — against white paper and black ink
- Functional color only: Honest Green reports price/stock, Alert Red reports absence, Star Amber marks ratings
- Plain Material 3 components at exact sizes (48dp primary button, 8dp custom radius, 1px field borders)
- Honest price language: bold green now-price + struck grey old-price, only when a discount truly exists
- Flat depth: tonal M3 surfaces and default card elevation (1), never custom shadows
- Roboto everywhere, sized 12–26px by formula, weights 400/600/700 in practice

## Colors

One saturated brand color against a paper-and-ink neutral set; every other hue reports a fact.

### Primary
- **Confident Teal** (#00796B): The single voice of the brand. Owns the app bar, the splash screen, primary buttons (Login), the focused border of every field, and inline text accents ("back" in Welcome back, Logout). It also seeds the Material `ColorScheme`, so all derived roles harmonize with it. White text on it passes WCAG AA at 5.32:1 (deliberately darkened from #00897B for exactly this reason).

### Secondary
- **Honest Green** (#2E7D32): The price color. Only ever marks what you actually pay (after discount) and "in stock" status. Chosen over Colors.green for contrast: 5.13:1 on white.
- **Alert Red** (#D32F2F): Absence and danger — "Out of stock". 4.98:1 on white.
- **Banner Red pair** — deep #B71C1C text on a #FFEBEE wash: reserved for the login error banner.
- **Star Amber** (#FFC107): rating stars only, never decoration.

### Neutral
- **Ink** (#000000): headings and body text on paper.
- **Text Grey** (#616161): subtitles, hints, and the struck-through old price. 6.19:1 on white — the only grey allowed for readable text.
- **Line Grey** (#9E9E9E): field borders at rest, small icons, the empty-state icon. Never for readable text.
- **Paper** (#FFFFFF): backgrounds, field fill, and all text on teal.

### Named Rules
**The One Voice Rule.** Confident Teal is the only brand color; green, red and amber never decorate — they report price, stock and rating.

**The Honest Price Rule.** What you pay is bold Honest Green; what it was is struck Text Grey — and the struck price appears only when a real discount exists.

## Typography

**Display Font:** Roboto (the system face, with system-ui fallback)
**Body Font:** Roboto
**Label/Mono Font:** none (no distinct face)

**Character:** plain and honest — the system face used without ornament. Hierarchy comes from weight (400/600/700) and a compact 12–26px size set, not from a display typeface.

### Hierarchy
- **Display** (700, 26px): splash title only — "DummyJSON Store" on teal.
- **Headline** (700, 24px): screen headings ("Welcome back"); the details title is its 22px/700 sibling.
- **Title** (600, 18px): card titles and the app-bar title (white variant on teal); section headings use 18px/700.
- **Body** (400, 16px): reading text, outlined-button labels, ratings.
- **Label** (600, 14px): primary button labels (white on teal). Supporting 14/13/12px regular in Text Grey carry hints and captions.

### Named Rules
**The Formula Rule.** Every text style lives in one file (lib/core/theming/styles.dart) and is named `font<size><weight><color>` (e.g. font14BoldGreen) — screens pick a style, never a raw TextStyle.

## Layout

Phone-first single column. Content sits in a scrollable full-bleed column with 24px screen padding; the login form is capped at a 400px max width so wide screens (web) keep the counter tidy. Gaps come from the `verticalSpace`/`horizontalSpace` helpers at six steps — 4, 8, 12, 16, 24, 32px (a 6px icon-gap appears beside small icons). Lists are rows: each product is a ListTile card (56px thumbnail, 8dp radius) in a plain list; the details page is one scrollable column (250px hero image, then 16px-padded content). Density is comfortable — Material defaults, no compact mode.

## Elevation & Depth

Flat by default. Depth is conveyed by Material 3's tonal surfaces and the framework's own card elevation only — there are no custom shadows anywhere. Teal surfaces (app bar, splash) are solid color at zero elevation. Cards rest at elevation 1 (the product list).

### Shadow Vocabulary
- **elevation-1** (M3 Card default): product cards — a barely-there lift.

### Named Rules
**The Flat-By-Default Rule.** Surfaces are flat tonal M3 surfaces at rest; elevation appears only as Flutter's default card shadow (1), never as a custom BoxShadow.

## Shapes

One radius carries the custom surfaces: 8dp — text fields, image thumbnails, the error banner, gallery tiles. Cards use Material's own 12dp. Buttons are full pills (M3 stadium). Field borders are 1px; focus changes the border color (Line Grey → Confident Teal), not its width. Circles are unused today (the old 80px profile avatar is gone with the Home screen). No other radii, no clipping games beyond rounded image tiles.

## Components

### Buttons
- **Shape:** full pill (M3 stadium), no custom radius.
- **Primary:** Confident Teal fill, white 14px/600 label, full-width, minimum 48px height ("Login").
- **Secondary / Ghost:** outlined button with a teal 16px/400 label ("Clear search" in the empty state); the Logout action lives in the app-bar settings popup menu (teal "Logout" item with a logout icon) — while logging out the gear icon in the app bar swaps to an 18px spinner and the menu item disables.
- **Hover / Focus:** Material's own state layers; no custom transitions.

### Chips
- **Style:** Material default Chip for the discount badge ("-12%") on the details screen.
- **State:** single static use — no filter or selected variants exist.

### Cards / Containers
- **Corner Style:** 12dp (Material default).
- **Background:** Paper white.
- **Shadow Strategy:** default M3 elevation 1 — see Elevation & Depth.
- **Border:** none.
- **Internal Padding:** the product row keeps ListTile's own padding; the settings menu uses Material's own item padding.

### Inputs / Fields
- **Style:** filled white, 1px Line Grey border, 8dp radius, 16×14px internal padding; optional prefix/suffix icons.
- **Focus:** border turns Confident Teal (color change only — width stays 1px).
- **Error / Disabled:** Material's default error text; no custom error decoration.
- **One field, everywhere:** every field in the app is the same AppTextFormField.

### Navigation
- **Style:** Confident Teal app bar with a single white 18px/600 title, set once in the shared appBarTheme. Screens push forward; no bottom navigation exists; the system Back gesture always works (M3 default). The Products app bar (the post-login root) hosts the settings affordance: a gear IconButton with the tooltip/Semantics label "Settings" opening a popup menu (signed-in username label + Logout).

### States (Loading / Error / Empty)
- **Loading:** plain centered spinner — white on the teal splash, default color elsewhere.
- **Error:** centered column — 48px red error icon, the message, a "Try again" elevated icon button, 24px padding.
- **Empty:** 48px grey search-off icon, the message, an optional "Clear search" outlined button.

### Signature: The Price Language
Everywhere a price appears — card and details alike — the same sentence: bold Honest Green for the current price, struck Text Grey for the old price (only when a discount exists), a small gap between them, and a discount Chip on the details screen. This consistency is a deliberate, repaired invariant.

### Signature: The Splash
Full-bleed Confident Teal, an 80px white shopping-bag mark, the 26px/700 white title, and a slim white progress spinner — the only screen without an app bar.

## Do's and Don'ts

### Do:
- **Do** add every text style to styles.dart with the formula name (font14BoldGreen); pick a style, never a raw TextStyle.
- **Do** keep readable text at ≥ 4.5:1 contrast — #616161 for grey text, never #9E9E9E.
- **Do** use the spacing helpers at the six documented steps (4/8/12/16/24/32).
- **Do** keep the price language identical in card and details (bold green now-price, struck grey old-price, only when discounted).
- **Do** size primary actions at 48px height and custom surfaces at 8dp radius.

### Don't:
- **Don't** introduce a second brand color, a gradient, or a custom shadow — teal is the one voice; depth belongs to Material.
- **Don't** port iOS controls or build custom chrome; Material 3 owns structure, navigation and motion.
- **Don't** strike through the old price or show a discount chip when there is no discount.
- **Don't** use raw Colors.red / Colors.green / Colors.grey for readable text (they fail WCAG AA) — use the documented values.
- **Don't** hand-roll spacing with magic SizedBox numbers outside the helper steps.
