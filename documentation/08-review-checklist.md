# 08 Review checklist

Use this before every pull request and LMS upload. The builder ticks it first, then the reviewer checks it. Copy it into the pull request description.

Mark each item ✅, or write **N/A** with a reason.

## Privacy and data (FERPA)

- [ ] No real student names, IDs, photos, grades or records anywhere: text, images, alt text, comments, file names
- [ ] No real staff names or photos, except public contacts meant to be shared
- [ ] Every example and scenario is fictional
- [ ] No LMS exports, completion reports, `.csv` or `.xlsx` files staged in git
- [ ] No `.env`, credentials or keys staged in git
- [ ] The source deck, PDF or Word file is **not** committed, and its location is in the module README
- [ ] Messages about which tools are approved for scholar data match current policy

## Content

- [ ] Matches the policy basis named in the brief (for example the Uplift AI Guidebook, June 2026, v1)
- [ ] The content owner has reviewed the facts and rules
- [ ] Every statistic has a source and date
- [ ] Goals start with a verb and are all covered by the content
- [ ] The most important message is clear and appears in a check
- [ ] Follows the [style guide](04-style-guide.md): plain language, sentence case, standard interface words, "Select" not "Click"
- [ ] No `[[PLACEHOLDER` text left (search for it)
- [ ] All links work and go to pages staff can reach

## Design

- [ ] Theme tokens match the approved brief, and every required pair passes contrast
- [ ] Shell, interface words and locked-Next behavior unchanged from the starter
- [ ] One icon style and one illustration style throughout
- [ ] Text over art is readable

## Accessibility

See [06 Accessibility](06-accessibility.md) for how to test.

- [ ] Full keyboard pass, start to finish
- [ ] Screen reader pass on one section and one check
- [ ] 200% zoom and phone width
- [ ] Reduced motion: everything works, nothing needed is lost
- [ ] Every drag activity has a select-then-place alternative
- [ ] Alt text on meaningful images, decorative images hidden
- [ ] Demos have Pause, Replay and a text version
- [ ] Sound off by default and never the only feedback
- [ ] Automated checker run, issues fixed or explained

## Activities and checks

- [ ] Each activity unlocks Next when done, and its instruction says so
- [ ] Each check: right pass mark, Check my answer, Try again, Next locked until passed
- [ ] Check questions are answerable from the module and test applying the idea

## SCORM and LMS

- [ ] `var DEV = false;`
- [ ] SCORM 2004 4th Edition. Package named `<module-name>-v<major>.<minor>-scorm.zip`.
- [ ] Same `identifier` as earlier versions
- [ ] Built with `tools/module.ps1 package` with no failures (it checks the manifest and verifies the zip)
- [ ] Previewed with the Test LMS panel, then tested in SCORM Cloud or the LMS sandbox: launch, completion, passed, score, resume
- [ ] Question-level answers (`"interactions"`) on only if someone will use them
- [ ] Tested in Chrome, Edge, Safari, and on a phone or tablet
- [ ] Earlier packages kept, not deleted

## Release

- [ ] Module README updated: version, summary, completion table, source locations, version history row
- [ ] Version history says **Replace** or **New course** for the LMS upload, and why
- [ ] Pull request opened for content, accessibility and data-privacy review
