# 05 UX/UI guide

Every Uplift module shares one **core**: the same frame, controls, behaviors and accessibility. That way staff always know how to move through a module. Each module adds its own **theme** on top: colors, art, icons and motion that fit its topic. This guide explains both layers.

Markup, class names and data attributes for everything below are in the [starter README](../templates/module-starter/README.md).

---

## Design principles

1. **Learners always know where they are.** That means a visible progress bar, a menu that shows sections reached, and clear headings.
2. **Learners always know what to do next.** Every activity has an instruction, and a locked Next explains why it's locked.
3. **One idea per slide.** Detail goes in fold boxes, not walls of text.
4. **Doing beats reading.** Each section has at least one thing to do.
5. **Theme supports content.** A theme can make a module memorable, but it must never slow learners down or hide information.
6. **Works for everyone.** Mouse, keyboard, touch, screen reader, small screens, reduced motion. No exceptions (see [06 Accessibility](06-accessibility.md)).

## The shell (core, don't change)

```
┌──────────────────────────────────────────────────────────────────────────┐
│ [Logo] Module title                 42%  [Menu] [Resources ▾] [Settings ▾] │  ← top bar (theme: --brand)
├──────────────────────────────────────────────────────────────────────────┤  ← progress bar (--accent on --brand-2)
│ (tip strip: full screen and animation tips, optional)                    │
├────────────┬─────────────────────────────────────────────────────────────┤
│ Menu       │                                                             │
│ ✓ Welcome  │      Slide (max width 1140px, fits the screen height)       │
│ ✓ Section 1│                                                             │
│ ▸ Section 2│                                                             │
│ 🔒 …       │                                                             │
├────────────┴─────────────────────────────────────────────────────────────┤
│                        [ Previous ]      [ Next ]                         │  ← nav bar
└──────────────────────────────────────────────────────────────────────────┘
```

| Part | Behavior |
|---|---|
| **Top bar** | Uplift logo, module title (hidden on phones), % complete, Menu, Resources, Settings |
| **Progress bar** | Share of milestones reached, matching what the LMS gets |
| **Menu** | Lists sections and slides. Only slides already reached can be opened. Ticks a section once it's complete. Beside the slide on wide screens (remembers open or closed), over the slide on phones. |
| **Resources** | The module's links (policy, guides, contact email). Set in the brief. |
| **Settings** | Sound effects (off by default) and Viewing tips, both remembered in that browser |
| **Previous / Next** | Next is locked until the slide's activity is done (see [Locked Next](#locked-next)) |
| **Fit to screen** | Slides fit the screen height on most laptops. Bars get slimmer on short screens. Phones and zoomed-in views scroll. |

### Screen sizes

| Width | Layout |
|---|---|
| Over 1140px | Menu beside the slide, cards up to 4 across |
| 761–1140px | Cards 2 × 2 instead of 3 + 1 |
| 760px or less | Menu opens over the slide, button labels in the top bar are hidden (kept for screen readers) |
| 520px or less | One column, course title hidden |

### Locked Next

When a slide has an activity (a *gate*), unopened fold boxes or unplayed demos, Next stays locked:

1. The instruction says what unlocks Next, before the learner tries.
2. Selecting the locked Next the **first time** makes the instruction bold.
3. Selecting it **again** also outlines each place the learner still needs to act.
4. Slides already passed are never locked again.

---

## Color tokens: core and theme

Colors are CSS variables in the starter's `:root`. Change **theme** tokens only.

### Core tokens (same in every module)

| Token | Value | Used for |
|---|---|---|
| `--ink` | `#1a1a1a` | Body text |
| `--muted` | `#4b5563` | Secondary text |
| `--bg` | `#ffffff` | Content background |
| `--surface` | `#f2f6fa` | Cards, panels |
| `--line` | `#d6e2ee` | Decorative borders (not the only edge of a control) |
| `--good` / `--good-tint` | `#166534` / `#e8f5ec` | Correct answers |
| `--bad` / `--bad-tint` | `#9f1239` / `#fdecef` | Wrong answers |

Right and wrong always come with an icon and words too, never color alone.

### Theme tokens (set for each module)

| Token | Uplift default | Used for | Must pass |
|---|---|---|---|
| `--brand` | `#0d2b45` | Top bar, headings | `--on-brand` on it ≥ 4.5:1. On `--bg` ≥ 4.5:1 if used for text. |
| `--brand-2` | `#163a5c` | Top-bar hover, progress track | `--on-brand` on it ≥ 4.5:1 |
| `--on-brand` | `#ffffff` | Text and icons on `--brand` | |
| `--primary` | `#1b6fb5` | Buttons | `--on-primary` on it ≥ 4.5:1 |
| `--on-primary` | `#ffffff` | Text and icons on `--primary` | Use dark text if `--primary` is light |
| `--primary-dark` | `#155a94` | Links, emphasis text | On `--bg`, `--surface` and `--primary-tint` ≥ 4.5:1 |
| `--primary-tint` | `#e6f0fa` | Selected states, light highlights | |
| `--accent` | `#ffc000` | Progress fill, highlights **on dark backgrounds only** | On `--brand` ≥ 3:1. **Never text on white.** |
| `--accent-tint` | `#fff4cc` | Soft highlight behind dark text | `--ink` on it ≥ 4.5:1 |
| `--accent-2` | `#c2410c` | A second accent (tags, bars) | On `--bg` ≥ 4.5:1 if used for text, otherwise ≥ 3:1 |
| `--focus` | two-tone ring | Keyboard focus | ≥ 3:1 against every background it appears on |
| `--stage-bg` | `var(--bg)` | Slide backdrop (a theme may use a gradient or art) | Text on it must still pass. Put text on a solid panel if needed. |

### Measured contrast for the Uplift default

| Pair | Ratio | Result |
|---|---|---|
| `--ink` on `--bg` | 17.40 | ✅ AA |
| `--muted` on `--bg` / `--surface` | 7.56 / 6.96 | ✅ AA |
| `--on-brand` on `--brand` / `--brand-2` | 14.50 / 11.71 | ✅ AA |
| `--on-primary` on `--primary` | 5.27 | ✅ AA |
| `--primary-dark` on `--bg` / `--surface` / `--primary-tint` | 7.19 / 6.62 / 6.23 | ✅ AA |
| `--accent` on `--brand` | 8.83 | ✅ AA |
| `--ink` on `--accent` | 10.60 | ✅ AA |
| `--accent-2` on `--bg` | 5.18 | ✅ AA |
| `--good` on `--good-tint`, `--bad` on `--bad-tint` | 6.35, 7.03 | ✅ AA |
| `--accent` on `--bg` | 1.64 | ❌ Never use gold text or a gold focus ring on white |
| `#155a94` focus ring on `--brand` | 2.02 | ❌ A one-color blue ring fails on the top bar, so the ring has two tones |

### Choosing theme colors

There's no full Uplift brand guide yet, so each module's colors are **proposed from its theme** and **checked before use**. The assistant does this during the [design questionnaire](02-design-questionnaire.md):

1. **Start from the brief.** Use the theme, three mood words (D2) and any colors to use or avoid (D3).
2. **Propose one set of theme tokens.** Usually that's a dark `--brand`, a mid-tone `--primary`, a darker `--primary-dark` for text, a bright `--accent` for dark backgrounds, and tints. Stay close to Uplift navy, blue and gold unless the theme gives a reason not to, so every module still feels like Uplift.
3. **Calculate every ratio** in the "Must pass" column with the WCAG formula below. **Calculate, don't estimate.** Show the table.
4. **Fix any failure** by darkening or lightening that color, then recalculate.
5. **Check color-blind safety.** Right and wrong must never depend on red versus green alone (they don't in the core, which adds icons and words).
6. The designer approves, and the tokens go into the brief.

**WCAG contrast formula.** For each color, convert each sRGB channel *c* (0–1) to linear: *c* ≤ 0.03928 ? *c*/12.92 : ((*c*+0.055)/1.055)^2.4. Luminance *L* = 0.2126 R + 0.7152 G + 0.0722 B. Ratio = (*L*lighter + 0.05) / (*L*darker + 0.05).
**AA targets:** body text ≥ 4.5:1, large text (24px, or 19px bold) ≥ 3:1, icons, control edges and focus rings ≥ 3:1.

---

## Typography

| | Rule |
|---|---|
| Font | System stack: `"Segoe UI", Calibri, system-ui, -apple-system, Roboto, Arial, sans-serif`. Modules must run offline, so a theme font has to be embedded in `assets/` and licensed for it. Use one only for headings, if at all. |
| Body | 18px, line height 1.6 |
| Headings | Bold, sentence case, color `--brand` or `--ink` |
| Line length | Full slide width is fine. Fold boxes and cards keep lines short naturally. |
| Never | Text in images (except logos), all-caps paragraphs, text under 14px |

## Icons and illustrations

- **Icons** are inline SVG, outline style, 2px stroke, rounded caps, using `currentColor` so they follow the theme. The brief can change the style (filled, duotone), but use one style per module.
- **Decorative** icons and art get `aria-hidden="true"`. **Meaningful** images get alt text that says what matters, not what it looks like.
- **Illustrations** follow one rule written in the brief (for example "flat shapes, rounded outlines, two theme colors plus ink").
- **Never** use photos of real students. Avoid stock photos of people. Logos only as the policy allows.
- All art is local (in `assets/` or inline). There are no external images.

## Motion

| Level | What's allowed |
|---|---|
| **None** | Instant changes only |
| **Subtle** (default) | Fades, small slides, progress fills, count-ups. 150–400 ms. |
| **Playful** | Characters, journeys, scene animations (like Foundations' rocket). Each needs a still version. |

Rules for every level:

- **`prefers-reduced-motion`** shows the finished state straight away, and the module still works fully.
- Anything that moves for **more than 5 seconds** has Pause or stops by itself.
- Demos start paused or play once, with **Pause** and **Replay**, and have a text version for screen readers.
- Nothing flashes more than 3 times a second.
- Animation never hides content the learner needs, and never makes them wait to read.

## Sound

Optional, set in the brief. If a module offers sound, it uses short effects only (click, right, wrong), they're **off by default** under Settings, and the same feedback is always shown on screen. Narration needs captions or a transcript.

---

## Component catalog

Pick components that fit the content. Details and markup are in the [starter README](../templates/module-starter/README.md).

| Component | Use it for | Gate? |
|---|---|---|
| **Section start** | Opening each section: title, what's in it, how many slides | No |
| **Card grid** (2–4 cards) | Parallel ideas, examples, comparisons | No |
| **Fold boxes** | Detail behind a heading. Each box must be opened. | Yes (each opened) |
| **Side-by-side cards** | Do and don't, weak and strong, approved and not approved | No |
| **Role picker** | Showing an example for the learner's role. The choice carries to later slides. | Optional |
| **Select the parts** | Highlighting the parts of an example (for example CRAFT in a prompt) | Yes (all selected) |
| **Sort activity** | Putting examples into categories. Drag, or select then place (keyboard and tap). | Yes (all sorted) |
| **Scenario question** | Applying a rule to a realistic situation, with feedback | Yes (answered) |
| **Section check** | One multiple-choice question per slide, pass mark, Try again | Yes (passed) |
| **Animated demo** | Showing a tool or process working. Pause, Replay, text version. | Yes (played) |
| **Big number** | A sourced statistic, with optional count-up | No |
| **Key takeaways** | Wrap-up cards | Optional |
| **Reflection** | An open question. Nothing typed is saved or sent. | No |
| **Finish slide** | Says whether the learner is done, and if not, what's left. Close this window button. | No |

Use drag-and-drop sparingly. These aren't games, and every drag needs a keyboard and tap alternative.

---

## Themes

A theme is a layer you add to the starter. It **may** change:

- Theme color tokens (after contrast checks)
- `--stage-bg` and decorative art on section-start, welcome, checkpoint and finish slides
- Icon and illustration style
- Motion level, and a small set of themed animations (each with a still version)
- Theme names for parts, for example "Mission checkpoint" for the section-check intro, as long as the standard interface words stay

A theme **may not** change:

- The shell layout, the interface words, or how Next locks
- Completion, scoring or milestone behavior
- Focus rings, contrast, keyboard support or reduced-motion behavior
- Text readability (put text on solid panels over busy art)

### Worked example: Foundations' space theme

Foundations uses a space-mission metaphor: a starry stage, planets for sections, a rocket that flies between them, "Mission checkpoint" before each check and a capsule splashdown on the finish slide. The core is unchanged underneath: same shell, gates, checks and tracking. It belongs to Foundations, so don't reuse it unless the new module is part of the same series. Its source is a reference for how far a theme can go: `modules/foundations/sources/`.
