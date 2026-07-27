# Cờ Cá Ngựa — "Toy Box" UI/UX Redesign Brief

Status: **target design direction, not yet implemented**. Saved verbatim from
the user's brief on 2026-07-26 for reference during the redesign. The current
implementation (as of this writing) is a functional Tailwind/daisyUI
LiveView UI — clean and correct, but built for desktop portrait layout with a
plain card-based sidebar, not the toy-box/landscape experience described
below.

When implementing against this brief, treat it as the source of truth for
tone, palette, layout, and asset direction. Re-read it before making any
visual decision.

---

You are an award-winning Senior Game UI/UX Designer and Senior Frontend Engineer.

Your task is to design and implement a modern HTML/CSS/JS interface for a Vietnamese Horse Race board game (Cờ Cá Ngựa).

## Project Goal

This is NOT an online multiplayer game.

This is NOT a casino game.

This is NOT an esports game.

The game is played on ONE shared device by family members.

Typical players:
- Parent + child
- 2–4 family members
- Friends sitting together
- Turn-based (Pass & Play)

The experience should feel like opening a beautiful physical board game on a table.

The emotions should be:

- Warm
- Friendly
- Playful
- Premium
- Easy for children
- Relaxing
- Delightful

Never create a gambling feeling.

Never create a dark cyberpunk feeling.

Never imitate casino UI.

---

## Design Philosophy

The UI should feel inspired by:

• modern children's board games
• wooden toys
• Monopoly GO polish
• premium mobile casual games
• Apple-level spacing
• Nintendo friendliness

The interface should feel like a premium toy instead of software.

---

## Visual Style

Overall style:

50% Toy Box
30% Modern Flat
20% Storybook

Everything should have:

- large rounded corners
- soft shadows
- vibrant but not oversaturated colors
- subtle gradients
- glossy toy-like pieces
- clean typography
- generous whitespace

Avoid visual clutter.

---

## Color Palette

Primary Blue
Primary Red
Primary Yellow
Primary Green

Use cream (#FFF8EE) instead of pure white.

Backgrounds should be light.

Avoid:

- black backgrounds
- neon
- gold casino themes
- metallic UI
- sci-fi HUD
- dark gradients

---

## Typography

Friendly rounded font.

Large text.

Children should be able to read it easily.

Avoid condensed fonts.

---

## Buttons

Buttons should look like toy buttons.

Requirements:

- rounded
- thick
- colorful
- soft shadow
- press animation
- hover animation
- active animation

Buttons should feel touchable.

---

## Board

The board is always the hero.

It occupies around 70–75% of the screen.

Everything else is secondary.

Never shrink the board to make room for unnecessary UI.

---

## Horse Pieces

Horse pieces should look like collectible plastic toys.

Requirements:

- glossy
- colorful
- slightly oversized
- subtle highlights
- cute proportions

Not realistic horses.

---

## Dice

The dice is the most exciting interaction.

Make it:

- large
- centered during rolling
- bouncing animation
- satisfying

Dice should feel magical for children.

---

## Player Panels

Each player has:

- avatar
- name
- horse color
- horses home count
- horses finished
- current turn indicator

Current player should be immediately obvious.

Use:

- glow
- bounce
- highlight
- animated border

Inactive players should be slightly muted.

---

## Layout

Landscape only.

16:9 optimized.

Example layout

```
---------------------------------------------------------
Top Bar
---------------------------------------------------------

Player        Board        Player

Player        Board        Player

---------------------------------------------------------
Bottom Action Bar
---------------------------------------------------------

Roll Dice
Undo
Settings

---------------------------------------------------------
```

The board should remain centered.

---

## Animation

Everything should feel alive.

Examples:

horse hop

dice bounce

button squash

confetti

sparkles

turn indicator pulse

winner celebration

Use animation sparingly.

Never overwhelm users.

Animation duration:

150–350ms

Use easing.

---

## UX

Children must understand the interface without reading instructions.

Every important action should have:

visual feedback

motion

sound placeholder

highlight

---

## Accessibility

Large touch targets.

Minimum 48x48 px.

High color contrast.

Readable fonts.

Color should never be the only indicator.

---

## Code Requirements

Generate production-quality code.

Use:

HTML

CSS

Vanilla JavaScript

or React if requested.

Componentize everything.

Separate concerns.

Write clean code.

No unnecessary dependencies.

---

## Design Quality

Every screen should look like it belongs in a polished commercial game released in 2026.

Do not create generic dashboard layouts.

Think like a game UI artist, not a web app designer.

Every pixel should contribute to delight.

Whenever making a design decision, ask yourself:

"Would a 6-year-old smile when seeing this, while the parent also feels it is premium?"

If the answer is no, redesign it.

Always prioritize:

1. Joy
2. Clarity
3. Simplicity
4. Delight
5. Polish

over adding more features.

# Asset Generation Rules

When existing assets are missing, create new ones that are visually consistent with the game's art direction.

Never mix multiple illustration styles.

Every generated asset must look like it belongs to the same game.

The visual language should remain consistent across all screens.

---

## Art Direction

Theme:

Premium Family Board Game

Mood:

Warm
Playful
Friendly
Colorful
Relaxing
Toy-like

Avoid:

Realistic
Dark
Horror
Cyberpunk
Casino
Military
Sci-fi
Heavy textures
Sharp edges

---

## Illustration Style

Everything should resemble high-quality 3D toy illustrations.

Reference style:

• Monopoly GO
• Royal Match
• Coin Master
• Nintendo
• Disney mobile games

Characteristics:

- rounded
- soft
- chunky
- glossy
- colorful
- expressive
- simplified geometry

Never use realistic rendering.

---

## Lighting

Soft daylight.

Top-left lighting.

Very soft shadows.

Soft ambient occlusion.

Subtle highlights.

No dramatic lighting.

No harsh contrast.

---

## Materials

Plastic toys

Painted wood

Soft rubber

Paper

Cardboard

Fabric

Never use:

Steel

Chrome

Rust

Concrete

Carbon fiber

---

## Color Rules

Use vibrant colors but avoid oversaturation.

Preferred palette:

Blue
Green
Yellow
Red
Orange
Cream

Avoid:

Pure black

Pure white

Neon

Fluorescent colors

---

## Stroke Rules

Rounded shapes.

Minimal outlines.

No comic thick black outline.

Instead use:

soft edge

subtle shadow

inner highlight

---

## Perspective

Slight 3/4 view.

Never perfectly flat.

Everything should feel touchable.

---

## Asset Quality

Every asset should be exportable as production-ready game art.

Requirements:

1024px minimum

Transparent background

Centered

Consistent padding

No cropped edges

No watermark

No text embedded

---

## Character Rules

If characters are needed:

Friendly

Cute

Big eyes

Simple face

Large head

Small body

Never scary.

Never realistic anatomy.

---

## Horse Design

Horse pieces should resemble collectible toy horses.

Requirements:

Rounded body

Short legs

Cute face

Bright saddle

Glossy finish

Large eyes

Soft smile

Do not create realistic horses.

---

## Dice Design

Rounded cube.

Glossy plastic.

Black circular pips.

Cream-white body.

Friendly proportions.

---

## Trophy Design

Gold toy trophy.

Rounded handles.

Blue ribbon.

Glossy finish.

Simple silhouette.

---

## Coin Design

Large gold coin.

Embossed horse icon.

Soft gradient.

No realistic engraving.

---

## Gem Design

Large crystal.

Blue or green.

Simple facets.

Strong highlight.

---

## Button Assets

Rounded capsule.

Soft shadow.

Subtle gradient.

Hover state.

Pressed state.

Disabled state.

Never use flat rectangles.

---

## Icon Style

Icons should be:

filled

rounded

minimal

friendly

consistent stroke weight

Examples:

Home

Settings

Undo

Dice

Horse

Sound

Music

Exit

Restart

Help

Every icon must belong to the same icon family.

---

## Background Rules

Backgrounds should never distract from gameplay.

Examples:

light wood table

soft fabric

pastel gradient

playroom

park

children's room

Avoid highly detailed scenery.

---

## Animation Rules

Generated assets should support animation.

Design with clear silhouettes.

Avoid tiny decorative details.

Animations:

bounce

wiggle

pop

jump

celebration

spin

confetti

---

## Consistency Rules

Before generating any new asset, compare it against previously generated assets.

Match:

lighting

materials

color palette

corner radius

shadow softness

illustration style

Do not introduce a new style mid-project.

---

## Asset Naming

Use consistent names.

Examples:

horse_red.png

horse_blue.png

horse_green.png

horse_yellow.png

dice_idle.png

dice_roll_01.png

button_primary.png

button_secondary.png

coin_gold.png

gem_blue.png

trophy_gold.png

board_background.png

avatar_frame.png

---

## If Unsure

When multiple design choices are possible:

Choose the option that looks more like a premium family board game sold in a toy store rather than a competitive online game.

Children should immediately think:

"I want to play with this."

Parents should think:

"This looks beautiful and easy to understand."

# Design Review Checklist

Before completing any screen, review it against this checklist.

□ Is the board still the primary focus?

□ Can a 5-year-old understand what to press?

□ Is the current player's turn immediately obvious?

□ Is every button at least 48px?

□ Are colors harmonious?

□ Does everything look like the same art style?

□ Is there enough whitespace?

□ Is any element visually distracting?

□ Would this look at home in Monopoly GO or a Nintendo family game?

If any answer is "No", improve the design before returning it.

---

## Gap notes vs. current implementation (as of 2026-07-26)

Recorded so a future redesign session knows exactly what changes:

- **Layout**: current is portrait-friendly (`max-w-6xl` centered column,
  board + sidebar stack on narrow screens). Brief wants forced landscape
  16:9 with players flanking the board left/right, board fixed at
  70-75% of screen.
- **Palette**: current uses plain white/zinc cards + an indigo UI accent.
  Brief wants cream (`#FFF8EE`) surfaces, no indigo — accent should come
  from the 4 player colors plus warm neutrals.
- **Horse pieces**: existing generated assets (`priv/static/images/assets/horse_*.png`)
  are glossy chess-knight-head pieces. Brief describes a *cuter, rounder*
  toy-horse silhouette (short legs, big eyes, saddle, soft smile) — closer
  to a Monopoly GO mascot than a chess piece. These likely need to be
  regenerated via the chatgpt-image skill, not reused.
- **Dice**: existing dice PNGs (`die_1.png`..`die_6.png`) already match the
  brief reasonably well (cream body, black pips, glossy) — can likely be
  reused or lightly touched up rather than regenerated from scratch.
- **Buttons**: current buttons are flat Tailwind rounded-xl with a solid
  fill. Brief wants thick toy-capsule buttons with press/hover/active states
  and soft drop shadow — needs a small button component system (CSS only,
  no new assets required necessarily).
- **Player panels**: current sidebar list is compact and text-only (color
  dot + name + finished count). Brief wants a fuller panel per player
  (avatar, glow/bounce on active turn, muted when inactive) positioned
  flanking the board rather than in a side list.
- **New assets likely needed**: avatar frames, confetti/sparkle sprites,
  a trophy for the win screen, background texture (light wood table /
  pastel), button capsule assets or CSS-only equivalent.
- **Engine/rules**: unaffected. This is a pure UI/visual layer redesign —
  `GameHub.Games.CoCaNgua.Board` and `Layout` stay as-is; only
  `GameHubWeb.CoCaNgua.GameLive` (and possibly `SetupLive`/`HomeLive`)
  templates, CSS, and static assets change.
