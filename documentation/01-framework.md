# 01 Framework: from source file to LMS course

This is the repeatable process for building an Uplift training module. Each phase has a goal, the steps, who leads the conversation with the AI assistant, and a **done when** check. Don't move on until the check is met.

```
 0 Set up  →  1 Intake  →  2 Design interview  →  3 Outline  ║  4 Build  →  5 Review  →  6 Package & test  →  7 Release
 └──────────── Assistant leads: it asks and proposes ────────┘║└──────────── You lead: you direct, it builds ────────────┘
                                                     Outline sign-off (handoff)
```

---

## Who leads the conversation

Working with an AI assistant goes best when it's clear who is steering. The framework switches once, at **outline sign-off**.

### Phases 1–3: the assistant leads

You may not know yet what to ask for, so the assistant drives:

- It asks questions in small groups (no more than 4 at a time), with a suggested answer for each, so you can just say "yes" or adjust.
- It proposes options and recommends one, briefly saying why.
- It ends each turn with **2–3 suggested next prompts** written for this module, so you can copy, edit or ignore them. (See [Prompt library: proposed prompts](09-prompt-library.md#how-proposed-prompts-work).)
- It writes every decision into the module brief as it goes.

### Phases 4–7: you lead

Once the outline is approved, you know exactly what you want, and the assistant follows:

- It does what you ask, in the scope you asked for. If a request would change something outside that scope (another slide, the theme, tracking), it asks first.
- It doesn't redesign, rewrite or "improve" things you didn't mention. It can point out a problem in one line, but doesn't fix it unless you say so.
- It ends each turn with a short **what changed** list, not suggested prompts. Ask it for suggestions any time and it will give them.
- Two exceptions always apply: it must speak up about anything that breaks [accessibility](06-accessibility.md), FERPA or the [assessment and SCORM rules](07-assessment-and-scorm.md), even when you're leading.

You can switch any time. Say **"you lead"** or **"I'll lead"**.

---

## Phase 0: Set up

**Goal:** a safe place to work.

1. Open the `ai-training` repo in your IDE and create a branch: `module/<module-name>-v1.0`.
   Module names are `kebab-case`, for example `ai-and-student-data`.
2. Ask the assistant to **set up the module**. It runs `tools/module.ps1 new <module-name>`, which copies the starter to `modules/<module-name>/sources/<module-name>/`, fills in the module's settings, and creates `README.md` and `BRIEF.md` (a working file that isn't committed). You don't need to run anything yourself. See [tools/README.md](../tools/README.md) if you're curious.
3. **Check your AI assistant.** Only the district **Uplift Education** tools (Microsoft Copilot and Claude, signed in with your Uplift account) are approved for student data. Whatever assistant you use, the source you give it must contain **no student or staff personal information** (see Phase 1).

**Done when:** the branch exists, the starter and brief are in place, and the assistant has read [AGENTS.md](../AGENTS.md).

## Phase 1: Intake (the assistant leads)

**Goal:** a clean source file and a clear reason for the module.

1. **De-identify the source *before* the assistant sees it.** Remove or replace real student and staff names, IDs, photos, emails and records. Swap in fictional ones. If you're not sure, ask your supervisor or `ai@uplifteducation.org` before you go on.
2. Put the source file in the module folder. `.pptx`, `.pdf` and `.docx` files are ignored by git automatically, so they stay local. Note in the brief where the master copy lives (usually SharePoint).
3. The assistant reads the source and gives you an **inventory**: each slide or page, what it teaches, and a suggestion to keep, cut, rewrite or turn into an activity. See [03 Source conversion](03-source-conversion.md).
4. The assistant confirms the **policy basis**, for example the Uplift AI Guidebook (June 2026, v1), and flags anything in the source that disagrees with it or is out of date.

**Done when:** the source has no real personal information, the inventory is in the brief, and policy conflicts are listed.

## Phase 2: Design interview (the assistant leads)

**Goal:** a filled-in module brief.

1. The assistant runs the [design questionnaire](02-design-questionnaire.md), one group at a time: audience, goals, theme and look, iconography, tone, interactions, assessment and length.
2. From your theme answers, it **proposes a color palette** with a contrast table, as described in the [UX/UI guide](05-ux-ui-guide.md#choosing-theme-colors). Every required pair must pass WCAG AA before you approve it.
3. It writes your answers into the brief and reads back a one-paragraph summary.

**Done when:** every questionnaire section is answered, and the palette is approved with all contrast checks passing.

## Phase 3: Outline (the assistant leads, and you sign off)

**Goal:** a slide-by-slide plan you agree with.

1. The assistant proposes the outline in the brief: sections, then slides in each section with slide type, activity, gate and milestone, then the check questions and pass marks.
2. Start from the **default structure** (below) unless the brief says otherwise.
3. Review it. Ask for changes until it's right.
4. Say **"outline approved"**. That's the handoff: from now on, you lead.

**Done when:** you've approved the outline and it's recorded in the brief, with the date.

### Default module structure

Foundations' structure works well, so it's the default. Change it when the brief gives a reason.

| Part | Default | Common options |
|---|---|---|
| Length | About 20–25 minutes, self-paced, resumable | Micro-module of 5–10 minutes with one section |
| Welcome | Title, why it matters, 3–4 goals that start with a verb, the finish rule | Combine onto one slide for micro-modules |
| Sections | 3–5 sections, each opening with a short section-start slide | 1–2 for micro-modules |
| Activities | At least one hands-on activity per section | |
| Section checks | 2–3 multiple-choice questions after each teaching section, retry until passed | No scored checks (completion only), or one final check |
| Practice | Role-based scenarios (Teacher, Campus staff, Central office), not scored | Skip if the topic isn't role-specific |
| Wrap-up | Key takeaways, a short reflection (nothing typed is saved), then the finish slide | |
| Completion | Every section reached **and** every check passed | See [07](07-assessment-and-scorm.md) |

## Phase 4: Build (you lead)

**Goal:** a working module.

1. **Apply the theme first.** Set the theme color tokens and add theme art (see the [UX/UI guide](05-ux-ui-guide.md)). Check the empty shell before adding content.
2. **Build one section at a time.** For each: slides, activities, then the check. The assistant runs `check` after each step and fixes what it finds. Ask it to **preview** the module to click through it in your browser, with a Test LMS panel showing what the LMS would receive. Set `DEV = true` to skip locks while you test, and set it back to `false` afterward (packaging refuses otherwise).
3. Use the [prompt library's build prompts](09-prompt-library.md#phase-4-build), or your own.
4. Keep the brief up to date when you change your mind about something.

**Done when:** every slide in the outline exists, every activity and check works, and the module runs start to finish with `DEV = false`.

## Phase 5: Review (you lead)

**Goal:** a module that's correct, accessible and safe.

1. Self-review with the [review checklist](08-review-checklist.md). The assistant runs `check`, which covers the items a script can check: contrast, alt text, headings, leftover placeholders, offline assets, milestones, interface words, real-looking emails and IDs. You and a reviewer cover the rest.
2. Ask a content owner to review the facts and policy, and a colleague to try it as a learner.
3. Fix, then review again.

**Done when:** every checklist item is ticked or has a written reason it doesn't apply.

## Phase 6: Package and test (you lead)

**Goal:** a SCORM package that reports correctly.

1. Ask the assistant to **package the module**. It checks everything, builds `<module-name>-v1.0-scorm.zip` (SCORM 2004 4th Edition), verifies it, and tells you whether the upload should **replace** or be a **new course**. See [07 Assessment and SCORM](07-assessment-and-scorm.md#packaging).
2. Test in SCORM Cloud or the LMS sandbox: launch, completion, score, pass, resume.
3. Test in Chrome, Edge and Safari, and on a phone or tablet.

**Done when:** the testing checklist in the [root README](../README.md#testing-checklist) is complete.

## Phase 7: Release (you lead)

1. Commit the package next to any earlier versions (never delete old ones), plus the HTML source and the module README. Don't commit the brief, the source deck or any LMS data.
2. Fill in the module README: summary, audience, how completion works, source locations and version history.
3. Open a pull request. Reviewers use the [review checklist](08-review-checklist.md).
4. After approval, an LMS admin uploads the package. For an update, say whether it should **replace** the current package (keeps learner progress) or be a **new course** (resets completions).

**Done when:** the PR is merged and the LMS course is live.

---

## Updating a module later

Start a branch (`module/<module-name>-v1.1`), bump the version, and follow phases 4–7. Keep the same SCORM `identifier` so the LMS can replace the package without losing learner progress. Record every change in the module README's version history.

## What's in git and what isn't

| In git | Not in git |
|---|---|
| `*-scorm.zip` packages | Source decks, PDFs and Word files (they stay on SharePoint) |
| `README.md` files | The working module brief (`BRIEF.md`) |
| HTML source (`sources/*/index.html` and `assets/`) | LMS exports, completion reports, anything with learner data |
| These documents and the starter template | `.env` files and credentials |
