# ai-training

Uplift Education's staff AI training modules, built as **SCORM 2004 4th Edition** packages for
**PowerSchool Professional Learning**. [README.md](README.md) is the full guide: the LMS delivery
flow, naming, the testing checklist, content guidance and the approved-tools table. Read it before
making content or structure decisions. This file covers only what Claude needs on top of it.

To build or update a module, follow [AGENTS.md](AGENTS.md) (the model-agnostic instructions for any
IDE assistant) and the module-building docs in [documentation/](documentation/README.md), starting
from [templates/module-starter/](templates/module-starter/).

@AGENTS.md

## Current state

- Layout is `modules/<module-name>/`. The first module is `modules/foundations/`. Its source deck
  (`sources/00 - Foundations AI Literacy and Ethics.pptx`) is a local working copy and is gitignored.
  Its HTML source (`sources/00 - Foundations AI Literacy and Ethics/index.html` + `assets/`) is
  tracked in git.
- Remote: `git@github.com:Uplift-Education/ai-training.git`, default branch `main`.
- Background: `../documentation/ppt-to-scorm-handoff.md` and `../documentation/foundations-call-10-20.md`.

## SCORM rules

- Always target SCORM 2004 4th Edition. Never use SCORM 1.2 or an earlier 2004 edition.
- Set `cmi.completion_status` **and** `cmi.success_status`. When there's an assessment, set both
  `cmi.score.scaled` (-1 to 1) and `cmi.score.raw`.
- Keep manifest sequencing simple unless a module really needs gating.
- Package name: `<module-name>-v<major>.<minor>-scorm.zip`. Module folders use `kebab-case`.
- Git holds finished `*-scorm.zip` packages, `README.md` files and hand-written HTML module
  sources (`modules/*/sources/*/index.html` and `assets/`). The `.gitignore` is an allowlist that
  ignores every other file inside folders. Never commit other source files (`.pptx`, `.story`,
  `.cptx`, iSpring projects, media), and don't loosen the allowlist without asking me.
- Before committing an HTML source or its assets, check they hold no real student or staff
  names, photos or data. Use made-up examples only.
  Build scratch folders (`dist/`, `build/` etc.) stay ignored.
- New modules are packaged with `tools/module.ps1 package` (see AGENTS.md). Foundations is the model
  the starter was built from, but it's maintained on its own track: nothing in `documentation/`
  or `tools/` applies to the existing Foundations package (v3.3 and later). Don't change it unless
  I ask. Its README records how it was packaged with the `scorm` MCP tools.
  If those tools are available, `scorm_validate` is an optional extra check on any package.

## Content rules

- All content must follow the Uplift AI Guidebook (June 2026, v1), which is linked in the README.
- The key learner message: student PII goes only into **Uplift Education** tools (district Copilot
  and Claude), never into **Uplift CMO** or unapproved tools. Don't soften or contradict it.
  - Foundations v2.0 to v3.2 named **only Microsoft Copilot**. From v3.4 it also teaches
    **Claude for Educators** (shown as "Uplift EDU Pilot"), with one line saying the Uplift CMO
    workspace is not for scholar data. Its message is "Microsoft Copilot or Claude for Educators,
    signed in with your Uplift account, never a personal or free account", and its cards say
    "Compliant with FERPA". See its approved-tools table in `modules/foundations/README.md`.
- Use made-up names and data in every scenario, example, quiz and screenshot.
- Meet WCAG 2.1 AA: captions or transcripts, alt text, keyboard navigation and contrast.
  Assessments must not depend only on color or timing. Drag-and-drop is fine, but don't over-rely on it
  (these aren't compliance trainings), and give every drag activity a keyboard and tap alternative.
- Write for teachers and staff: plain language, practical classroom and office examples.

## Never

- Commit LMS exports, completion reports or tracking data (`*.csv`, `*.xlsx`, `reports/` etc.).
  Only `**/sample-data/*.csv` with made-up data is allowed.
- Commit LMS or SCORM Cloud credentials.
- Upload packages that contain learner data to external testing services without my approval.

## When updating a module

Bump its version, commit the new package next to the earlier ones (don't delete old versions),
update its `README.md` version history and source location, and flag whether the LMS upload should
**replace** the existing package (keeping learner progress) or create a new course (resetting
completions).
