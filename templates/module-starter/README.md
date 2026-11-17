# Module starter template

A working, theme-neutral Uplift training module you copy to start a new one. It's the Foundations v3.3 shell with all of the space theme and the AI-literacy content taken out. It runs as one SCORM 2004 4th Edition SCO, fully offline, and every piece of text you need to write is marked `[[PLACEHOLDER: ...]]`.

It's 14 slides, laid out like this:

| # | Section (`data-section`) | Slide | What it shows you how to build |
|---|---|---|---|
| 1 | `welcome` | Welcome | Title panel, three objectives, the finish rule |
| 2 | `s1` | Section start | Section banner |
| 3 | `s1` | Card grid | `g3` card grid with icons, plus a "Show more" reveal |
| 4 | `s1` | Fold boxes | `g4` row of fold boxes, plus a callout |
| 5 | `s1` | Sort activity | Drag-and-drop sort, with select-then-place for keyboard and touch |
| 6–7 | `s1` | Check, 2 questions | Section check (1 of 2 to pass) |
| 8 | `s2` | Section start | Section banner |
| 9 | `s2` | Role example | Role picker (Teacher, Campus staff, Central office) |
| 10–11 | `s2` | Check, 2 questions | Section check (1 of 2 to pass) |
| 12 | `practice` | Practice scenario | One scenario for each role, not scored |
| 13 | `wrapup` | Key takeaways | Numbered fold cards |
| 14 | `wrapup` | Finish | What's left to do, or the finish message and **Close this window** |

## What the shell does for you

You don't need to touch any of this, just know it's there:

- **Top bar** with the Uplift logo, course name, % complete, progress bar, **Menu**, **Resources** and **Settings**. Settings holds Sound effects (off by default) and Viewing tips. On phones, Menu shrinks to an icon.
- **Viewing tips strip.** It shows on the first slide with full-screen and animation steps for PC and Mac. The learner's choice to show or hide it is remembered in their browser.
- **Menu.** It's built automatically from your slides. Slides the learner hasn't reached are locked, and each section gets a tick once it's done. On screens 900px wide or narrower, it opens over the slide.
- **Previous and Next**, with a slide counter and a hint saying why Next is locked. Selecting a locked Next once makes the hint bold. Selecting it again outlines what's left to do.
- **Fit to screen.** Bars and spacing shrink on short screens. Phones and zoomed-in views scroll. Tested with no sideways scrolling at 390px and 320px wide.
- **Tracking:** milestones, resuming where the learner left off, score, and passed status (see [Tracking](#tracking-and-milestones)).
- **Accessibility built in:** skip link, focus moves to each new slide's heading, live regions for feedback, keyboard support everywhere, a two-tone focus ring, and support for reduced motion. Sound is never the only signal.

## Start a new module

1. Copy this folder (`index.html` and `assets/`) to `modules/<module-name>/sources/<source-name>/`. Leave the template itself unchanged.
2. In `index.html`:
   - Set `<title>`, the course name in the top bar (`.course`) and the Welcome `<h1>`.
   - Change `MODULE_KEY` at the top of the script, for example to `"uplift-ai-data-privacy"`. This keeps this module's browser settings separate from other modules.
   - Update `SECTIONS`, `CHECK_TOTAL` and the milestones (see below).
   - Replace the **Resources** links. Every link that opens a new tab keeps its `<span class="sr-only"> (opens in a new tab)</span>`.
   - Rewrite the header comment so it describes your module and its source.
3. Apply the theme from the design brief (see [Theme](#theme-tokens)).
4. Replace every `[[PLACEHOLDER: ...]]`. With `DEV = true`, the browser console warns you if any are left. Before packaging, search the file for `[[PLACEHOLDER`: there must be none.
5. Use fictional names and data only. No real student or staff names, photos or records.

## Theme tokens

`:root` has two layers:

- **Core tokens** (`--ink`, `--muted`, `--bg`, `--surface`, `--line`, `--good`, `--bad` and their tints, plus `--radius`, `--max`, `--top-h` and `--font`) are the same in every Uplift module. **Don't change them for a theme.** Learners rely on the right and wrong colors being the same everywhere.
- **Theme tokens** come from the module's design brief:

| Token | Used for | Default (Uplift) |
|---|---|---|
| `--brand` | Top bar, Welcome and section banners, headings on light backgrounds | `#0d2b45` |
| `--brand-2` | Top-bar hover, progress track, tip strip | `#163a5c` |
| `--on-brand` | Text and icons on `--brand` and `--brand-2` | `#ffffff` |
| `--primary` | Buttons, selected states, icon circles | `#1b6fb5` |
| `--on-primary` | Text and icons on `--primary` (use dark text if `--primary` is light) | `#ffffff` |
| `--primary-dark` | Links, labels, button hover (text on light backgrounds) | `#155a94` |
| `--primary-tint` | Hover and selected backgrounds, notices | `#e6f0fa` |
| `--accent` | Progress fill, highlights on `--brand` only. **Never text on light backgrounds.** | `#ffc000` |
| `--accent-tint` | Callouts | `#fff4cc` |
| `--accent-2` | A second accent for tags and decorative bars | `#c2410c` |
| `--focus` | Keyboard focus ring (it has a white halo, so it shows on light and dark) | `#155a94` |
| `--stage-bg` | Backdrop behind the slides (a color, gradient or image) | `var(--bg)` |

**Contrast rules.** Every theme must pass these before it ships:

- **4.5:1** for body text: `--ink`, `--muted`, `--brand` and `--primary-dark` on `--bg`, `--surface` and `--primary-tint`; `--on-brand` on `--brand` and `--brand-2`; `--on-primary` on `--primary`, and white on `--primary-dark`; `--accent` on `--brand` and `--brand-2`.
- **3:1** for large text and for borders and icons people need to see: `--primary` on `--bg` (the outlines on the sort cards and role buttons), and `--focus` on `--bg`.

The default theme passes every pair. The lowest is `--on-primary` on `--primary`, at 5.27:1.

**Using a dark or image `--stage-bg`.** Slide text is `--ink`, so put the text on cards or `.hero` panels, or add a theme rule that changes the text color on the stage. Then check the contrast again.

Keep the Uplift logo in the top bar and the sunburst mark on the Welcome slide in their own colors, whatever the theme.

## Components

Each component below lists its markup and how it gates **Next**.

### Slide

```html
<section class="slide" data-section="s1" data-title="Menu name for this slide" data-gate="sort">
  <p class="sec-label"><span class="num" aria-hidden="true">1</span> Section one</p>
  <h2>Heading that states the main idea</h2>
  ...
</section>
```

- `data-section` is the id of the section the slide belongs to (from `SECTIONS`). Slides in a section must sit next to each other.
- `data-title` is the slide's name in the menu.
- `data-gate` is optional: `sort`, `practice` or `check`. Next stays locked until the activity is done.
- Every slide needs an `h1` or `h2`, because focus moves to it when the slide opens.

### Title and section banner

Use `.hero > .hero-inner` (`--brand` background). It can hold `.eyebrow`, `h1` or `h2`, `.sec-label`, paragraphs and lists. It doesn't gate Next.

### Card grid

Use `.grid.g2`, `.g3` or `.g4` with `.card` children. `.g4` fits four cards across, then two by two, then one column. `.card.brand` is a dark card. Inside a card, use `.icon > svg` (decorative, `aria-hidden="true"`), then `h3` and `p` (h3, because the slide title is h2). Tags are `.tag`, `.tag.accent`, `.tag.red` and `.tag.green`. It doesn't gate Next.

### Fold box

Add `fold` to a `.card`. Everything up to and including the first `h3` (or `h4`, or `[data-fold-head]`, or `.tag`) stays visible. The script turns that heading into a + button and hides the rest. Add `fold-row` to the grid, so opening one box doesn't stretch the others.

**Gate:** Next stays locked until every fold box on the slide has been opened. Boxes for roles that aren't showing don't count.

### Reveal

```html
<details class="reveal"><summary>See an example</summary><div class="body">...</div></details>
```

**Gate:** it must be opened, the same as a fold box. Remove it if opening it shouldn't be required.

### Callout and quote

`.callout` is an `svg` plus a `p`, for the one thing to remember. `.quote` is a `p` plus a `cite`. Neither gates Next.

### Big numbers (optional)

```html
<div class="stat-row"><div class="card"><p class="stat">90%</p><p>What it measures</p><p class="fineprint">Source</p></div></div>
```

A whole number, optionally followed by %, counts up when the slide opens. It shows straight away with reduced motion, and screen readers hear only the final number. Only use real figures, and always give the source.

### Sort activity

The sort is `data-gate="sort"`. Use one `[data-sort]` block per slide, and copy slide 5. Each `.sort-card` has:

- `data-answer`, which matches one `.sort-bin`'s `data-bin`
- `data-why`, the feedback shown when the card goes in the right box

Learners drag a card to a box, or select the card and then a box (keyboard and touch). A wrong box shakes the card back and plays the wrong sound. **Gate:** every card must be in the right box. Once they all are, the optional `.sort-after` callout fades up.

To change the number of cards, also change the hint text in `gateText()`.

### Role picker

```html
<div class="persona" role="group" aria-label="Choose your role">
  <span class="persona-label" aria-hidden="true">I work as:</span>
  <button type="button" class="persona-btn" aria-pressed="true" data-persona="teacher">Teacher</button>
  <button type="button" class="persona-btn" aria-pressed="false" data-persona="campus">Campus staff</button>
  <button type="button" class="persona-btn" aria-pressed="false" data-persona="central">Central office</button>
</div>
<div data-persona="teacher">...</div>
<div data-persona="campus" hidden>...</div>
<div data-persona="central" hidden>...</div>
```

There's one role for the whole module, so a role picked on any slide applies to every later slide. Elements with `data-persona` show only for the chosen role. The picker doesn't gate Next on its own.

### Practice (not scored)

The practice slide is `data-gate="practice"`. Use one `form.practice` for each role, with `data-persona` and `data-answer` (the best option's letter). The feedback element carries `data-why`. Learners see whether they were right, which answer is best and why.

**Gate:** the scenario for the learner's role must be answered. It's never scored and never sent to the LMS.

### Section check

The check is `data-gate="check"`, with one question per slide:

```html
<form class="check" data-check="s1" data-pass="1" novalidate>
  <fieldset class="q" data-answer="B">
    <legend>Question</legend>
    <label class="opt"><input type="radio" name="s1-q1" value="A"><span class="letter">A</span><span>Option</span></label>
    ...
    <button type="submit" class="btn small">Check my answer</button>
    <div class="feedback" hidden aria-live="polite"></div>
  </fieldset>
  <!-- last question of the check only: -->
  <div class="result check-result" tabindex="-1" hidden></div>
</form>
```

- Every question in a check uses the same `data-check` (the section id) and `data-pass` (how many right answers are needed).
- Radio `name`s must be unique across the module.
- **Check my answer** marks the correct answer, and the learner's answer if it was wrong. It gives no explanation. Screen readers hear the result in one line.
- The last question shows the check's result. A learner who misses the pass mark gets **Try again**, which clears the answers and goes back to question 1.
- **Gate:** each question must be answered, and Next stays locked on the last question until the check is passed. A check can't be skipped, even when coming back to it.

### Finish slide

The finish slide must be the last slide. Keep `#finish-status` and `#close-row`. The script lists anything left to do, with a button to go to the first check that hasn't been passed. Once everything is done, it shows the finish message and **Close this window**.

## Tracking and milestones

These parts of the script must agree with each other:

- **`SECTIONS`** lists every section in order, as `{ id, n, name }`. `n` is the number shown in the menu, and `name` is used in the menu, the resume message and the finish slide.
- **Milestones** sit in the hidden block before `</main>`. Add one `<span data-jalon="<id>" data-trigger="click">` for each section, and one `check-<id>` for each section that has a check.
- **`CHECK_TOTAL`** is the number of questions across all checks. The score is out of this number.

When milestones are reached:

- A section without a check is reached when its last slide is shown.
- A section with a check is reached when its check is passed and the learner moves on to the next section.
- `check-<id>` is reached when that check is passed.

LMS fields:

- `cmi.completion_status` becomes `completed` once every milestone is reached.
- The score is reported through `window.SCORM2004.score(raw, 0, CHECK_TOTAL)`.
- Once every check is passed, the script sets `cmi.success_status` to `passed` itself. Nothing ever sets `failed`.
- A returning learner resumes at the first section they haven't reached, or at the first check they haven't passed.

**To add a section:**

1. Add its slides with a new `data-section`.
2. Add it to `SECTIONS`.
3. Add its `data-jalon`.

**To give it a check:**

1. Add the question slides with `data-check="<section id>"`.
2. Add the `check-<id>` milestone.
3. Raise `CHECK_TOTAL`.
4. Update the finish rule on the Welcome slide.

**Never rename a milestone ID once a version is live.** Learners would lose their progress.

**A module with no checks** works as is. Delete the check slides and the `check-*` milestones, and set `CHECK_TOTAL = 0`. The module then reports completion only. Package it without a mastery score, and remove the "pass both section checks" wording from the Welcome slide.

## DEV mode

Set `var DEV = true;` at the top of the script while testing:

- Every slide opens from the menu.
- Next is never locked.
- Animations are skipped.
- A **Dev mode** badge shows in the top bar.
- The console warns about any `[[PLACEHOLDER` markers left in the file.

**Set it back to `false` before packaging.**

## Package it

1. Set `title`, `identifier` and `version` in the **module settings** block at the top of `index.html` (`<script type="application/json" id="uplift-module">`). Keep the `identifier` the same in every version, so the LMS can replace the package. `"interactions": true` turns on question-level answers. It's off by default.
2. Run `tools/module.ps1 package <module-name>`, or ask your AI assistant to. It checks, builds, writes a correct manifest, zips, verifies and says **Replace** or **New course**. No manual manifest edits. See [documentation/07](../../documentation/07-assessment-and-scorm.md#packaging).
3. Test in SCORM Cloud or the LMS sandbox, using the testing checklist in the root README.
4. Commit the package next to the module's other versions, and update the module README.

The tracking code ([templates/core/scorm-runtime.js](../core/scorm-runtime.js)) is added at build time, so it isn't in this file. `tools/module.ps1 preview <module-name>` builds a copy with a Test LMS panel for trying it in a browser.
