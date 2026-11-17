# AGENTS.md: instructions for AI assistants

This file is for any AI coding assistant working in this repo (Claude Code, GitHub Copilot, Cursor, Codex and others). It works with any model. Read it before you do anything else. The people you're helping are Uplift Education staff, often not developers.

## What this repo is

Uplift Education's staff training modules: single-SCO **SCORM 2004 4th Edition** packages for **PowerSchool Professional Learning**, hand-written as one offline `index.html` per module. See [README.md](README.md).

## Read these first

| When | Read |
|---|---|
| The builder is new or stuck on setup | [00 Getting started](documentation/00-getting-started.md) |
| Always | [documentation/README.md](documentation/README.md) and [documentation/01-framework.md](documentation/01-framework.md) |
| Starting a module | [02 Design questionnaire](documentation/02-design-questionnaire.md), [03 Source conversion](documentation/03-source-conversion.md), [templates/module-brief.md](documentation/templates/module-brief.md) |
| Writing text | [04 Style guide](documentation/04-style-guide.md) |
| Building or theming | [05 UX/UI guide](documentation/05-ux-ui-guide.md), [06 Accessibility](documentation/06-accessibility.md), [templates/module-starter/README.md](templates/module-starter/README.md) |
| Checks, tracking, packaging | [07 Assessment and SCORM](documentation/07-assessment-and-scorm.md) |
| Reviewing | [08 Review checklist](documentation/08-review-checklist.md) |
| Suggesting or using prompts | [09 Prompt library](documentation/09-prompt-library.md) |

If a module has a `BRIEF.md`, read it. It holds that module's decisions.

## Tools: you run them, the builder doesn't

Builders shouldn't need to touch a terminal. **You** run these, read the output, and explain the results in plain language. They need nothing installed: Windows PowerShell 5.1 (built into Windows) or PowerShell 7 (Mac and Linux). On Windows, run them as `powershell -NoProfile -ExecutionPolicy Bypass -File tools/module.ps1 <command> ...`. That bypass applies to this one run only and needs no admin rights. On Mac or Linux, use `pwsh tools/module.ps1 <command> ...`.

| Command | When to run it |
|---|---|
| `new <module-name>` | Phase 0: copies the starter, sets the module's settings, creates its README and BRIEF.md |
| `slides <module>` / `slides <module> <n or title>` / `slides <module> -Section <id>` | **Before reading index.html.** Lists slides with line ranges, or prints just one slide or section. Read only what you need, never the whole file. |
| `check <module>` | After every build step. Lint and contrast. Fix every FAIL. Mention WARNs to the builder. |
| `contrast <module>` | When proposing or changing theme colors |
| `preview <module>` | When the builder wants to try it. Opens it in the browser with a test LMS panel. |
| `package <module>` | Phase 6. Strict check, build, manifest, zip, verify, and **Replace vs. New course**. |

Never hand-edit a built package or its `imsmanifest.xml`. Change the source and package again. The tracking code is `templates/core/scorm-runtime.js`. The tools add it, so it's never pasted into a module. Foundations is the model the starter was built from, but this framework doesn't apply to it: the existing Foundations package (v3.3 and later) is maintained on its own track. Don't change it unless asked, and don't run these tools on it.

## Who leads

- **Phases 1–3 (intake, design interview, outline): you lead.** Ask up to 4 questions at a time, each with a suggested answer. Recommend one option when you offer choices. Write decisions into `BRIEF.md`. End every turn with **2–3 suggested next prompts** specific to this module (see [how proposed prompts work](documentation/09-prompt-library.md#how-proposed-prompts-work)).
- **After the designer says "outline approved": the designer leads.** Do what they ask, in the scope they ask. Ask before changing anything outside it. Don't redesign or rewrite unasked. End each turn with a short **what changed** list. Suggest prompts only when asked.
- The designer can switch at any time with "you lead" or "I'll lead".
- **Always speak up**, whoever leads, if a request would break accessibility, FERPA or the SCORM rules.

## Non-negotiable rules

**Privacy (FERPA)**
- Never read source files, exports or data that may contain real student or staff information without the user's explicit approval for that file. Ask first, and say what you'll look at and why.
- Never put real student or staff names, IDs, photos or records into a module. Use fictional data that doesn't look like a real person.
- Never send student or staff information to external services, APIs or web searches.
- Only the district **Uplift Education** tools are approved for student data. If the user seems about to share real student data with you, stop and point them to [Phase 1](documentation/01-framework.md#phase-1-intake-the-assistant-leads).

**Secrets and git**
- Never read, print or commit `.env` files, keys or credentials.
- The `.gitignore` is an allowlist. Don't loosen it without asking. Never commit source decks, PDFs, Word files, `BRIEF.md`, LMS exports, `*.csv` or `*.xlsx` files.
- Work on a branch. Don't commit to `main` or push unless asked. Check `git status` and the staged diff before committing.

**Build**
- Start new modules from [templates/module-starter/](templates/module-starter/). Change **theme** tokens only, never core tokens, the shell, interface words or tracking.
- Every module meets **WCAG 2.1 AA**. Calculate contrast ratios, don't estimate them.
- SCORM 2004 4th Edition only. Set `completion_status` and `success_status`, and a score when there are checks. Never rename milestone IDs or the `identifier` in a later version.
- `var DEV = false;` before packaging (`package` refuses otherwise).
- Modules run offline: no external fonts, scripts or images.

**Writing**
- Follow the [style guide](documentation/04-style-guide.md): plain language, sentence case, "scholars", "Select" not "Click", CRAFT order (Context, Role, Action, Format, Tone) for prompts.
- Write documentation for educators and staff, not just engineers.

## When updating a module

Bump its version, commit the new package next to earlier ones (never delete old ones), update its README version history, and say whether the LMS upload should **replace** the package (keeps progress) or create a **new course** (resets completions).
